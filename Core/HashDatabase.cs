namespace CubeAntivirus.Core;

/// <summary>
/// Thread-safe in-memory SHA-256 signature set.
/// Populate it only with indicators from trusted security sources.
/// </summary>
public sealed class HashDatabase
{
    private readonly HashSet<string> _hashes =
        new(StringComparer.OrdinalIgnoreCase);

    private readonly ReaderWriterLockSlim _lock = new();

    public bool Contains(string hash)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(hash);

        _lock.EnterReadLock();
        try
        {
            return _hashes.Contains(hash);
        }
        finally
        {
            _lock.ExitReadLock();
        }
    }

    public void Add(string hash)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(hash);

        if (hash.Length != 64 || !hash.All(Uri.IsHexDigit))
            throw new ArgumentException("Expected a SHA-256 hex digest.", nameof(hash));

        _lock.EnterWriteLock();
        try
        {
            _hashes.Add(hash);
        }
        finally
        {
            _lock.ExitWriteLock();
        }
    }

    public void AddRange(IEnumerable<string> hashes)
    {
        ArgumentNullException.ThrowIfNull(hashes);

        foreach (var hash in hashes)
            Add(hash);
    }
}
