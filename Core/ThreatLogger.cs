namespace CubeAntivirus.Core;

public sealed class ThreatLogger
{
    private readonly string _path = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "CubeAntivirus", "Logs", "events.log");
    private readonly SemaphoreSlim _gate = new(1, 1);

    public async Task WriteAsync(string message, CancellationToken token = default)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(_path)!);
        await _gate.WaitAsync(token);
        try { await File.AppendAllTextAsync(_path, $"[{DateTimeOffset.Now:O}] {message}{Environment.NewLine}", token); }
        finally { _gate.Release(); }
    }

    public async Task<string> ReadAllAsync(CancellationToken token = default)
    {
        if (!File.Exists(_path)) return "No activity has been recorded yet.";
        await _gate.WaitAsync(token);
        try { return await File.ReadAllTextAsync(_path, token); }
        finally { _gate.Release(); }
    }
}