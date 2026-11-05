using System.Diagnostics;

namespace CubeAntivirus.Modules;

public sealed class HoneyPotManager : IDisposable
{
    private readonly FileSystemWatcher _watcher;
    public string Root { get; }
    public event EventHandler<string>? ActivityDetected;

    public HoneyPotManager()
    {
        Root = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "CubeAntivirus", "HoneyPotDisk");
        Directory.CreateDirectory(Root);
        CreateDecoy(Path.Combine("Documents", "passwords-demo.txt"), "DECOY ONLY — synthetic data. No real credentials.");
        CreateDecoy(Path.Combine("Wallets", "wallet-demo.dat"), "DECOY ONLY — not a real wallet or key.");
        CreateDecoy(Path.Combine("Backups", "admin-backup-demo.zip.txt"), "DECOY ONLY — synthetic backup placeholder.");
        CreateDecoy("read-me-first.txt", "Cube Antivirus HoneyPot. Synthetic files for defensive testing.");

        _watcher = new FileSystemWatcher(Root)
        {
            IncludeSubdirectories = true,
            NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite | NotifyFilters.Size,
            EnableRaisingEvents = true
        };
        _watcher.Changed += OnChanged;
        _watcher.Created += OnChanged;
        _watcher.Deleted += OnChanged;
        _watcher.Renamed += OnRenamed;
        _watcher.Error += OnError;
    }

    private void CreateDecoy(string relative, string content)
    {
        var path = Path.Combine(Root, relative);
        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        if (!File.Exists(path)) File.WriteAllText(path, content);
    }

    public string? FindMappedDrive()
    {
        using var p = Process.Start(new ProcessStartInfo
        {
            FileName = Path.Combine(Environment.SystemDirectory, "subst.exe"),
            UseShellExecute = false, RedirectStandardOutput = true, CreateNoWindow = true
        });
        if (p is null) return null;
        var output = p.StandardOutput.ReadToEnd();
        p.WaitForExit();
        foreach (var line in output.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries))
        {
            var i = line.IndexOf(" => ", StringComparison.Ordinal);
            if (i < 0) continue;
            var left = line[..i].Trim();
            var targetPart = line[(i + 4)..].Trim().Trim('"');
            var letter = left.FirstOrDefault(char.IsLetter);
            if (letter == default) continue;
            try
            {
                var target = Path.GetFullPath(targetPart).TrimEnd(Path.DirectorySeparatorChar);
                var root = Path.GetFullPath(Root).TrimEnd(Path.DirectorySeparatorChar);
                if (string.Equals(target, root, StringComparison.OrdinalIgnoreCase)) return $"{char.ToUpperInvariant(letter)}:";
            }
            catch { }
        }
        return null;
    }

    public async Task<string> CreateVirtualDriveAsync()
    {
        var current = FindMappedDrive();
        if (current is not null) return current;
        var used = DriveInfo.GetDrives().Select(d => d.Name.TrimEnd('\\').TrimEnd(':'))
            .Where(n => n.Length == 1).Select(n => char.ToUpperInvariant(n[0])).ToHashSet();
        var letter = Enumerable.Range('D', 'Z' - 'D' + 1).Select(n => (char)n).Reverse().FirstOrDefault(c => !used.Contains(c));
        if (letter == default) throw new InvalidOperationException("No free drive letter is available.");
        using var p = Process.Start(new ProcessStartInfo
        {
            FileName = Path.Combine(Environment.SystemDirectory, "subst.exe"),
            UseShellExecute = false, CreateNoWindow = true, ArgumentList = { $"{letter}:", Root }
        }) ?? throw new InvalidOperationException("Could not start Windows SUBST.");
        await p.WaitForExitAsync();
        if (p.ExitCode != 0) throw new InvalidOperationException($"SUBST failed with exit code {p.ExitCode}.");
        return $"{letter}:";
    }

    public async Task RemoveVirtualDriveAsync()
    {
        var drive = FindMappedDrive();
        if (drive is null) return;
        using var p = Process.Start(new ProcessStartInfo
        {
            FileName = Path.Combine(Environment.SystemDirectory, "subst.exe"),
            UseShellExecute = false, CreateNoWindow = true, ArgumentList = { "/D", drive }
        }) ?? throw new InvalidOperationException("Could not start Windows SUBST.");
        await p.WaitForExitAsync();
        if (p.ExitCode != 0) throw new InvalidOperationException($"SUBST detach failed with exit code {p.ExitCode}.");
    }

    private void OnChanged(object sender, FileSystemEventArgs e) => ActivityDetected?.Invoke(this, $"{e.ChangeType}: {e.FullPath}");
    private void OnRenamed(object sender, RenamedEventArgs e) => ActivityDetected?.Invoke(this, $"Renamed: {e.OldFullPath} -> {e.FullPath}");
    private void OnError(object sender, ErrorEventArgs e) => ActivityDetected?.Invoke(this, $"Watcher warning: {e.GetException().Message}");
    public void Dispose() => _watcher.Dispose();
}