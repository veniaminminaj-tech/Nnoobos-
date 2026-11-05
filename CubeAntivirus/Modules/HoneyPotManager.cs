namespace CubeAntivirus.Modules;

/// <summary>
/// Creates synthetic decoy files and reports filesystem change events.
/// FileSystemWatcher does not reliably report reads or identify the process responsible.
/// </summary>
public sealed class HoneyPotManager : IDisposable
{
    private readonly FileSystemWatcher _watcher;
    public string Root { get; }
    public event EventHandler<string>? ActivityDetected;

    public HoneyPotManager()
    {
        Root = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "CubeAntivirus", "HoneyPot");
        Directory.CreateDirectory(Root);
        CreateDecoy("passwords-demo.txt", "DECOY ONLY — synthetic data. No real credentials.");
        CreateDecoy("crypto-keys-demo.dat", "DECOY ONLY — synthetic test content.");

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

    private void CreateDecoy(string name, string content)
    {
        var path = Path.Combine(Root, name);
        if (!File.Exists(path)) File.WriteAllText(path, content);
    }

    private void OnChanged(object sender, FileSystemEventArgs e) =>
        ActivityDetected?.Invoke(this, $"{e.ChangeType}: {e.FullPath}");

    private void OnRenamed(object sender, RenamedEventArgs e) =>
        ActivityDetected?.Invoke(this, $"Renamed: {e.OldFullPath} -> {e.FullPath}");

    private void OnError(object sender, ErrorEventArgs e) =>
        ActivityDetected?.Invoke(this, $"Watcher warning: {e.GetException().Message}");

    public void Dispose() => _watcher.Dispose();
}