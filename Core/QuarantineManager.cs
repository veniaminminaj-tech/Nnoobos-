using System.Security.Cryptography;
using System.Text.Json;

namespace CubeAntivirus.Core;

public sealed record QuarantineRecord(
    string Id, string OriginalPath, string StoredPath, string Sha256, DateTimeOffset AddedAt);

/// <summary>
/// Stores verified copies and metadata. It never deletes or moves original files.
/// Restored copies are hash-checked and never overwrite an existing file.
/// </summary>
public sealed class QuarantineManager
{
    public string Folder { get; } = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "CubeAntivirus", "Quarantine");
    private string IndexPath => Path.Combine(Folder, "index.json");
    private readonly SemaphoreSlim _gate = new(1, 1);
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    public QuarantineManager() => Directory.CreateDirectory(Folder);

    public async Task<IReadOnlyList<QuarantineRecord>> GetItemsAsync(CancellationToken token = default)
    {
        await _gate.WaitAsync(token);
        try
        {
            if (!File.Exists(IndexPath)) return Array.Empty<QuarantineRecord>();
            var json = await File.ReadAllTextAsync(IndexPath, token);
            return JsonSerializer.Deserialize<List<QuarantineRecord>>(json) ?? new();
        }
        finally { _gate.Release(); }
    }

    public async Task<string> CopyToQuarantineAsync(string source, CancellationToken token = default)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(source);
        var fullSource = Path.GetFullPath(source);
        if (!File.Exists(fullSource)) throw new FileNotFoundException("File not found.", fullSource);

        await _gate.WaitAsync(token);
        try
        {
            await using var input = new FileStream(fullSource, FileMode.Open, FileAccess.Read, FileShare.Read,
                81920, FileOptions.Asynchronous | FileOptions.SequentialScan);
            var hash = Convert.ToHexString(await SHA256.HashDataAsync(input, token));
            input.Position = 0;
            var id = Guid.NewGuid().ToString("N");
            var destination = Path.Combine(Folder, id + ".quarantine");
            await using (var output = new FileStream(destination, FileMode.CreateNew, FileAccess.Write, FileShare.None,
                81920, FileOptions.Asynchronous | FileOptions.SequentialScan))
            {
                await input.CopyToAsync(output, token);
                await output.FlushAsync(token);
            }

            var storedHash = await HashFileAsync(destination, token);
            if (!StringComparer.Ordinal.Equals(hash, storedHash))
            {
                File.Delete(destination);
                throw new IOException("Quarantine verification failed: SHA-256 mismatch.");
            }

            var records = await ReadIndexUnsafeAsync(token);
            records.Add(new QuarantineRecord(id, fullSource, destination, hash, DateTimeOffset.Now));
            await WriteIndexUnsafeAsync(records, token);
            return destination;
        }
        finally { _gate.Release(); }
    }

    public async Task RestoreCopyAsync(QuarantineRecord item, string destination, CancellationToken token = default)
    {
        ArgumentNullException.ThrowIfNull(item);
        var fullDestination = Path.GetFullPath(destination);
        var fullStored = Path.GetFullPath(item.StoredPath);
        var quarantineRoot = Path.GetFullPath(Folder) + Path.DirectorySeparatorChar;
        if (!fullStored.StartsWith(quarantineRoot, StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("The selected entry is outside the quarantine folder.");
        if (!File.Exists(fullStored)) throw new FileNotFoundException("Quarantined copy is missing.", fullStored);
        if (File.Exists(fullDestination)) throw new IOException("Destination already exists. Choose another name.");

        var actualHash = await HashFileAsync(fullStored, token);
        if (!StringComparer.Ordinal.Equals(actualHash, item.Sha256))
            throw new IOException("Quarantine file failed integrity verification. Restore was stopped.");

        await using var input = new FileStream(fullStored, FileMode.Open, FileAccess.Read, FileShare.Read);
        await using var output = new FileStream(fullDestination, FileMode.CreateNew, FileAccess.Write, FileShare.None);
        await input.CopyToAsync(output, token);
        await output.FlushAsync(token);
    }

    private async Task<List<QuarantineRecord>> ReadIndexUnsafeAsync(CancellationToken token)
    {
        if (!File.Exists(IndexPath)) return new();
        var json = await File.ReadAllTextAsync(IndexPath, token);
        return JsonSerializer.Deserialize<List<QuarantineRecord>>(json) ?? new();
    }

    private async Task WriteIndexUnsafeAsync(List<QuarantineRecord> records, CancellationToken token)
    {
        var temp = IndexPath + ".tmp";
        await File.WriteAllTextAsync(temp, JsonSerializer.Serialize(records, JsonOptions), token);
        File.Move(temp, IndexPath, true);
    }

    private static async Task<string> HashFileAsync(string path, CancellationToken token)
    {
        await using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read,
            81920, FileOptions.Asynchronous | FileOptions.SequentialScan);
        return Convert.ToHexString(await SHA256.HashDataAsync(stream, token));
    }
}