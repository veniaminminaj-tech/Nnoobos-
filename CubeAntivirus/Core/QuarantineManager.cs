using System.Security.Cryptography;

namespace CubeAntivirus.Core;

/// <summary>
/// Copies a file into a private quarantine folder. The source is never deleted or moved.
/// </summary>
public sealed class QuarantineManager
{
    public string Folder { get; } = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "CubeAntivirus",
        "IsolatedSandbox");

    public QuarantineManager() => Directory.CreateDirectory(Folder);

    public async Task<string> CopyToQuarantineAsync(
        string source,
        CancellationToken cancellationToken = default)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(source);

        if (!File.Exists(source))
            throw new FileNotFoundException("File not found.", source);

        await using var input = new FileStream(
            source, FileMode.Open, FileAccess.Read, FileShare.Read,
            81920, FileOptions.Asynchronous | FileOptions.SequentialScan);

        var hash = Convert.ToHexString(
            await SHA256.HashDataAsync(input, cancellationToken));

        input.Position = 0;

        var destination = Path.Combine(
            Folder, $"{hash}_{Guid.NewGuid():N}.quarantine");

        await using var output = new FileStream(
            destination, FileMode.CreateNew, FileAccess.Write, FileShare.None,
            81920, FileOptions.Asynchronous | FileOptions.SequentialScan);

        await input.CopyToAsync(output, cancellationToken);
        await output.FlushAsync(cancellationToken);

        return destination;
    }
}
