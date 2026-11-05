using System.Runtime.CompilerServices;
using System.Security;
using System.Security.Cryptography;
using System.Text;
using CubeAntivirus.Models;

namespace CubeAntivirus.Core;

/// <summary>
/// Read-only recursive scanner. It never edits or deletes scanned files.
/// </summary>
public sealed class FileScanner
{
    private static readonly HashSet<string> ScriptExtensions =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ".txt", ".bat", ".cmd", ".ps1", ".vbs", ".js", ".py"
        };

    private static readonly string[] Indicators =
    {
        "malicious_trojan_downloader_script",
        "powershell.exe -nop -w hidden",
        "Invoke-Expression",
        "FromBase64String"
    };

    private const long MaxScriptSize = 2_000_000;
    private readonly HashDatabase _database;
    private readonly SemaphoreSlim _gate = new(4, 4);

    public FileScanner(HashDatabase database) =>
        _database = database ?? throw new ArgumentNullException(nameof(database));

    public async Task<ScanResult> ScanFileAsync(
        string path,
        CancellationToken cancellationToken = default)
    {
        await _gate.WaitAsync(cancellationToken).ConfigureAwait(false);

        try
        {
            await using var stream = new FileStream(
                path,
                FileMode.Open,
                FileAccess.Read,
                FileShare.Read,
                81920,
                FileOptions.Asynchronous | FileOptions.SequentialScan);

            var digest = await SHA256.HashDataAsync(stream, cancellationToken)
                .ConfigureAwait(false);
            var hash = Convert.ToHexString(digest);

            if (_database.Contains(hash))
                return new ScanResult(path, ScanStatus.Threat,
                    "SHA-256 signature match", hash);

            if (ScriptExtensions.Contains(Path.GetExtension(path)) &&
                stream.Length <= MaxScriptSize)
            {
                stream.Position = 0;
                using var reader = new StreamReader(
                    stream, Encoding.UTF8, detectEncodingFromByteOrderMarks: true,
                    bufferSize: 4096, leaveOpen: true);

                var content = await reader.ReadToEndAsync(cancellationToken)
                    .ConfigureAwait(false);

                var indicator = Indicators.FirstOrDefault(value =>
                    content.Contains(value, StringComparison.OrdinalIgnoreCase));

                if (indicator is not null)
                    return new ScanResult(path, ScanStatus.Warning,
                        $"Review required: heuristic indicator '{indicator}'", hash);
            }

            return new ScanResult(path, ScanStatus.Clean,
                "No known indicators found", hash);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException
                                   or SecurityException or ArgumentException)
        {
            return new ScanResult(path, ScanStatus.Error,
                $"Could not inspect file: {ex.Message}");
        }
        finally
        {
            _gate.Release();
        }
    }

    public async IAsyncEnumerable<ScanResult> ScanDirectoryAsync(
        string root,
        [EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(root))
            throw new ArgumentException("A folder path is required.", nameof(root));

        if (!Directory.Exists(root))
        {
            yield return new ScanResult(root, ScanStatus.Error, "Folder does not exist.");
            yield break;
        }

        var pending = new Stack<string>();
        pending.Push(Path.GetFullPath(root));

        while (pending.Count > 0)
        {
            cancellationToken.ThrowIfCancellationRequested();
            var directory = pending.Pop();

            string[] files;
            string? listingError = null;
            try
            {
                files = Directory.EnumerateFiles(directory).ToArray();
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException
                                       or SecurityException)
            {
                files = Array.Empty<string>();
                listingError = ex.Message;
            }

            if (listingError is not null)
            {
                yield return new ScanResult(directory, ScanStatus.Error,
                    $"Cannot list folder: {listingError}");
                continue;
            }

            foreach (var file in files)
            {
                cancellationToken.ThrowIfCancellationRequested();
                yield return await ScanFileAsync(file, cancellationToken)
                    .ConfigureAwait(false);
            }

            string[] childDirectories;
            listingError = null;
            try
            {
                childDirectories = Directory.EnumerateDirectories(directory).ToArray();
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException
                                       or SecurityException)
            {
                childDirectories = Array.Empty<string>();
                listingError = ex.Message;
            }

            if (listingError is not null)
            {
                yield return new ScanResult(directory, ScanStatus.Error,
                    $"Cannot list subfolders: {listingError}");
                continue;
            }

            foreach (var child in childDirectories)
            {
                cancellationToken.ThrowIfCancellationRequested();
                bool isReparsePoint;
                string? attributeError = null;

                try
                {
                    isReparsePoint =
                        (File.GetAttributes(child) & FileAttributes.ReparsePoint) != 0;
                }
                catch (Exception ex) when (ex is IOException or UnauthorizedAccessException
                                           or SecurityException)
                {
                    isReparsePoint = true;
                    attributeError = ex.Message;
                }

                if (attributeError is not null)
                {
                    yield return new ScanResult(child, ScanStatus.Error,
                        $"Cannot inspect folder: {attributeError}");
                }
                else if (!isReparsePoint)
                {
                    pending.Push(child);
                }
            }
        }
    }
}
