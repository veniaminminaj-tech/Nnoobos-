using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Text.Json;
using CubeAntivirus.Core;
using CubeAntivirus.Modules;
using CubeAntivirus.Models;

const string Version = "1.5.0";
var dataDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "CubeAntivirus");
Directory.CreateDirectory(dataDir);
var historyPath = Path.Combine(dataDir, "scan-history.json");
var trustedPath = Path.Combine(dataDir, "trusted-sha256.txt");
var honeyLogPath = Path.Combine(dataDir, "Logs", "honeypot-worker.log");

void Help()
{
    Console.WriteLine($"Cube Antivirus CLI {Version}");
    Console.WriteLine("Commands:");
    Console.WriteLine("  scan <file-or-folder> [--exclude <folder>] [--json <report.json>] [--csv <report.csv>]");
    Console.WriteLine("  history                         Show previous scan sessions");
    Console.WriteLine("  trust add <file>                Trust a file by its SHA-256 hash");
    Console.WriteLine("  trust list                      List trusted SHA-256 hashes");
    Console.WriteLine("  signature <file>                Show embedded signing-certificate details");
    Console.WriteLine("  large <folder> [MB]             Find files at least this large (default 100 MB)");
    Console.WriteLine("  types <folder>                  List files with executable/script extensions");
    Console.WriteLine("  processes                       Read-only process inventory");
    Console.WriteLine("  honeypot-log                    Show HoneyPot worker log");
    Console.WriteLine("  help");
    Console.WriteLine("All scanning is read-only. A certificate being present does not mean it is trusted.");
}

static string Csv(string? value) => """ + (value ?? "").Replace(""", """") + """;
static async Task SaveTextAsync(string path, string content) =>
    await File.WriteAllTextAsync(Path.GetFullPath(path), content, new UTF8Encoding(false));

if (args.Length == 0 || args[0] is "help" or "--help" or "-h" or "/?")
{
    Help();
    return;
}

using var cancellation = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) => { e.Cancel = true; cancellation.Cancel(); Console.WriteLine("\nCancellation requested..."); };

try
{
    switch (args[0].ToLowerInvariant())
    {
        case "scan":
        {
            if (args.Length < 2) { Help(); Environment.ExitCode = 2; return; }
            var target = Path.GetFullPath(args[1]);
            if (!File.Exists(target) && !Directory.Exists(target))
                throw new FileNotFoundException("The selected file or folder does not exist.", target);
            var exclusions = new List<string>();
            string? jsonOut = null, csvOut = null;
            for (var i = 2; i < args.Length; i++)
            {
                if (args[i] == "--exclude" && i + 1 < args.Length) exclusions.Add(Path.GetFullPath(args[++i]));
                else if (args[i] == "--json" && i + 1 < args.Length) jsonOut = args[++i];
                else if (args[i] == "--csv" && i + 1 < args.Length) csvOut = args[++i];
                else throw new ArgumentException($"Unknown or incomplete option: {args[i]}");
            }

            var scanner = new FileScanner(new HashDatabase());
            var results = new List<ScanResult>();
            var trusted = File.Exists(trustedPath)
                ? (await File.ReadAllLinesAsync(trustedPath)).Where(x => x.Length == 64).ToHashSet(StringComparer.OrdinalIgnoreCase)
                : new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            Console.WriteLine($"Scanning: {target}");
            Console.WriteLine("Read-only mode. No files will be modified.");
            if (File.Exists(target))
                results.Add(await scanner.ScanFileAsync(target, cancellation.Token));
            else
                await foreach (var item in scanner.ScanDirectoryAsync(target, cancellation.Token, exclusions))
                    results.Add(item);

            foreach (var result in results)
            {
                var isTrusted = result.Sha256 is not null && trusted.Contains(result.Sha256);
                var label = isTrusted ? "[TRUSTED]" : result.Status switch
                {
                    ScanStatus.Threat => "[THREAT]", ScanStatus.Warning => "[REVIEW]",
                    ScanStatus.Error => "[ERROR]", _ => "[CLEAN]"
                };
                Console.WriteLine($"{label} {result.Path}");
                if (result.Status != ScanStatus.Clean || isTrusted) Console.WriteLine($"        {result.Details}");
                if (result.Sha256 is not null) Console.WriteLine($"        SHA-256: {result.Sha256}");
            }

            var session = new { Date = DateTimeOffset.Now, Target = target, Excluded = exclusions,
                Total = results.Count, Threats = results.Count(x => x.Status == ScanStatus.Threat),
                Warnings = results.Count(x => x.Status == ScanStatus.Warning),
                Errors = results.Count(x => x.Status == ScanStatus.Error), Results = results };
            var history = new List<JsonElement>();
            if (File.Exists(historyPath))
            {
                try { history = JsonSerializer.Deserialize<List<JsonElement>>(await File.ReadAllTextAsync(historyPath)) ?? new(); }
                catch (JsonException) { history = new(); }
            }
            history.Add(JsonSerializer.SerializeToElement(session));
            await File.WriteAllTextAsync(historyPath, JsonSerializer.Serialize(history, new JsonSerializerOptions { WriteIndented = true }));
            if (jsonOut is not null)
                await SaveTextAsync(jsonOut, JsonSerializer.Serialize(session, new JsonSerializerOptions { WriteIndented = true }));
            if (csvOut is not null)
            {
                var csv = new StringBuilder("Path,Status,Details,SHA256\r\n");
                foreach (var x in results) csv.AppendLine($"{Csv(x.Path)},{Csv(x.Status.ToString())},{Csv(x.Details)},{Csv(x.Sha256)}");
                await SaveTextAsync(csvOut, csv.ToString());
            }
            Console.WriteLine($"Summary: {session.Total} checked · {session.Threats} threats · {session.Warnings} warnings · {session.Errors} errors");
            Console.WriteLine($"History saved: {historyPath}");
            if (jsonOut is not null) Console.WriteLine($"JSON report: {Path.GetFullPath(jsonOut)}");
            if (csvOut is not null) Console.WriteLine($"CSV report: {Path.GetFullPath(csvOut)}");
            if (session.Threats + session.Warnings + session.Errors > 0) Environment.ExitCode = 1;
            break;
        }
        case "history":
            if (!File.Exists(historyPath)) Console.WriteLine("No scan history yet.");
            else Console.WriteLine(await File.ReadAllTextAsync(historyPath));
            break;
        case "trust":
            if (args.Length < 2) { Help(); Environment.ExitCode = 2; return; }
            if (args[1].Equals("list", StringComparison.OrdinalIgnoreCase))
            {
                if (File.Exists(trustedPath)) Console.WriteLine(await File.ReadAllTextAsync(trustedPath));
                else Console.WriteLine("Trusted list is empty.");
            }
            else if (args[1].Equals("add", StringComparison.OrdinalIgnoreCase) && args.Length >= 3)
            {
                var path = Path.GetFullPath(args[2]);
                if (!File.Exists(path)) throw new FileNotFoundException("File not found.", path);
                await using var stream = File.OpenRead(path);
                var hash = Convert.ToHexString(await System.Security.Cryptography.SHA256.HashDataAsync(stream));
                var existing = File.Exists(trustedPath) ? await File.ReadAllLinesAsync(trustedPath) : Array.Empty<string>();
                if (!existing.Contains(hash, StringComparer.OrdinalIgnoreCase))
                    await File.AppendAllTextAsync(trustedPath, hash + Environment.NewLine);
                Console.WriteLine($"Added SHA-256 to local trust list: {hash}");
                Console.WriteLine("Only use this for files you have independently verified.");
            }
            else { Help(); Environment.ExitCode = 2; }
            break;
        case "signature":
        {
            if (args.Length < 2) { Help(); Environment.ExitCode = 2; return; }
            var path = Path.GetFullPath(args[1]);
            if (!File.Exists(path)) throw new FileNotFoundException("File not found.", path);
            try
            {
                using var cert = new X509Certificate2(X509Certificate.CreateFromSignedFile(path));
                Console.WriteLine("Embedded signing certificate found.");
                Console.WriteLine($"Subject: {cert.Subject}");
                Console.WriteLine($"Issuer: {cert.Issuer}");
                Console.WriteLine($"Valid: {cert.NotBefore:u} to {cert.NotAfter:u}");
                Console.WriteLine("NOTE: This only reads the embedded certificate. It does not validate the signature or certificate trust chain.");
            }
            catch (System.Security.Cryptography.CryptographicException)
            {
                Console.WriteLine("No readable embedded Authenticode certificate was found.");
                Environment.ExitCode = 1;
            }
            break;
        }
        case "large":
        {
            if (args.Length < 2 || !Directory.Exists(args[1])) { Help(); Environment.ExitCode = 2; return; }
            var minBytes = (args.Length >= 3 ? double.Parse(args[2], System.Globalization.CultureInfo.InvariantCulture) : 100) * 1024 * 1024;
            foreach (var path in Directory.EnumerateFiles(args[1], "*", SearchOption.AllDirectories))
            {
                cancellation.Token.ThrowIfCancellationRequested();
                try { var info = new FileInfo(path); if (info.Length >= minBytes) Console.WriteLine($"{info.Length / 1048576d,10:N1} MB  {info.FullName}"); }
                catch (IOException) { }
                catch (UnauthorizedAccessException) { }
            }
            break;
        }
        case "types":
        {
            if (args.Length < 2 || !Directory.Exists(args[1])) { Help(); Environment.ExitCode = 2; return; }
            var extensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
                { ".exe", ".dll", ".scr", ".com", ".bat", ".cmd", ".ps1", ".vbs", ".js", ".hta", ".msi", ".jar", ".py" };
            foreach (var path in Directory.EnumerateFiles(args[1], "*", SearchOption.AllDirectories))
                if (extensions.Contains(Path.GetExtension(path)))
                    Console.WriteLine($"{Path.GetExtension(path),-8} {path}");
            Console.WriteLine("An extension is only a file-type hint, not evidence of malware.");
            break;
        }
        case "processes":
            foreach (var p in ProcessManager.GetProcesses())
                Console.WriteLine($"{(p.IsMiner ? "[REVIEW]" : "[INFO]")} PID {p.Pid,-7} {p.Name} — {p.Status}");
            Console.WriteLine("Read-only listing; no processes were stopped.");
            break;
        case "honeypot-log":
            if (File.Exists(honeyLogPath)) Console.WriteLine(await File.ReadAllTextAsync(honeyLogPath));
            else Console.WriteLine("No HoneyPot worker log exists yet.");
            break;
        default:
            Console.Error.WriteLine($"Unknown command: {args[0]}");
            Help();
            Environment.ExitCode = 2;
            break;
    }
}
catch (OperationCanceledException) { Console.WriteLine("Operation cancelled."); Environment.ExitCode = 130; }
catch (Exception ex) { Console.Error.WriteLine($"Error: {ex.Message}"); Environment.ExitCode = 2; }
