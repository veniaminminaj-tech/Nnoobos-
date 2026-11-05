using CubeAntivirus.Core;
using CubeAntivirus.Modules;
using CubeAntivirus.Models;

static void ShowHelp()
{
    Console.WriteLine("Cube Antivirus CLI 1.4.0");
    Console.WriteLine("Usage:");
    Console.WriteLine("  CubeAntivirus.CLI.exe scan <folder>");
    Console.WriteLine("  CubeAntivirus.CLI.exe processes");
    Console.WriteLine("  CubeAntivirus.CLI.exe help");
    Console.WriteLine();
    Console.WriteLine("Scanning is read-only. Heuristic findings are warnings, not proof of malware.");
}

if (args.Length == 0 || args[0].Equals("help", StringComparison.OrdinalIgnoreCase) ||
    args[0] is "--help" or "-h" or "/?")
{
    ShowHelp();
    return;
}

using var cancellation = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) =>
{
    e.Cancel = true;
    cancellation.Cancel();
    Console.WriteLine("\nCancellation requested...");
};

try
{
    if (args[0].Equals("scan", StringComparison.OrdinalIgnoreCase))
    {
        if (args.Length < 2)
        {
            Console.Error.WriteLine("Error: provide a folder path.");
            ShowHelp();
            Environment.ExitCode = 2;
            return;
        }

        var folder = Path.GetFullPath(string.Join(" ", args.Skip(1)));
        var scanner = new FileScanner(new HashDatabase());
        var totals = new Dictionary<ScanStatus, int>();
        Console.WriteLine($"Scanning: {folder}");
        Console.WriteLine("Read-only mode; original files will not be changed.");
        await foreach (var result in scanner.ScanDirectoryAsync(folder, cancellation.Token))
        {
            totals[result.Status] = totals.GetValueOrDefault(result.Status) + 1;
            var label = result.Status switch
            {
                ScanStatus.Threat => "[THREAT]",
                ScanStatus.Warning => "[REVIEW]",
                ScanStatus.Error => "[ERROR]",
                _ => "[CLEAN]"
            };
            Console.WriteLine($"{label} {result.Path}");
            if (result.Status != ScanStatus.Clean)
                Console.WriteLine($"        {result.Details}");
        }

        Console.WriteLine();
        Console.WriteLine("Scan summary:");
        foreach (var status in Enum.GetValues<ScanStatus>())
            Console.WriteLine($"  {status}: {totals.GetValueOrDefault(status)}");
        if (totals.GetValueOrDefault(ScanStatus.Threat) > 0 ||
            totals.GetValueOrDefault(ScanStatus.Warning) > 0 ||
            totals.GetValueOrDefault(ScanStatus.Error) > 0)
            Environment.ExitCode = 1;
        return;
    }

    if (args[0].Equals("processes", StringComparison.OrdinalIgnoreCase))
    {
        Console.WriteLine("Running processes (read-only inventory):");
        foreach (var item in ProcessManager.GetProcesses())
        {
            var marker = item.IsMiner ? "[REVIEW]" : "[INFO]";
            Console.WriteLine($"{marker} PID {item.Pid,-7} {item.Name} — {item.Status}");
            if (!string.IsNullOrWhiteSpace(item.ExecutablePath))
                Console.WriteLine($"         {item.ExecutablePath}");
        }
        Console.WriteLine("No processes were stopped or modified.");
        return;
    }

    Console.Error.WriteLine($"Unknown command: {args[0]}");
    ShowHelp();
    Environment.ExitCode = 2;
}
catch (OperationCanceledException)
{
    Console.WriteLine("Scan cancelled.");
    Environment.ExitCode = 130;
}
catch (Exception ex)
{
    Console.Error.WriteLine($"Error: {ex.Message}");
    Environment.ExitCode = 2;
}
