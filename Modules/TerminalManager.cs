using System.Diagnostics;

namespace CubeAntivirus.Modules;

/// <summary>
/// Runs an explicitly entered command in a visible-to-the-app, non-persistent CMD session.
/// Cancellation stops only the child command process tree created for this invocation.
/// </summary>
public sealed class TerminalManager
{
    public async Task<string> ExecuteAsync(
        string command,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(command))
            return string.Empty;

        var startInfo = new ProcessStartInfo("cmd.exe")
        {
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        };

        startInfo.ArgumentList.Add("/d");
        startInfo.ArgumentList.Add("/s");
        startInfo.ArgumentList.Add("/c");
        startInfo.ArgumentList.Add(command);

        using var process = new Process { StartInfo = startInfo };

        if (!process.Start())
            throw new InvalidOperationException("Could not start cmd.exe.");

        var stdoutTask = process.StandardOutput.ReadToEndAsync(cancellationToken);
        var stderrTask = process.StandardError.ReadToEndAsync(cancellationToken);

        try
        {
            await process.WaitForExitAsync(cancellationToken).ConfigureAwait(false);
            await Task.WhenAll(stdoutTask, stderrTask).ConfigureAwait(false);
        }
        catch (OperationCanceledException)
        {
            try
            {
                if (!process.HasExited)
                    process.Kill(entireProcessTree: true);
            }
            catch (InvalidOperationException)
            {
                // The process exited between the check and Kill.
            }

            throw;
        }

        var output = await stdoutTask.ConfigureAwait(false);
        var error = await stderrTask.ConfigureAwait(false);

        return string.Join(
            Environment.NewLine,
            new[]
            {
                output.TrimEnd(),
                string.IsNullOrWhiteSpace(error) ? string.Empty : "[stderr] " + error.TrimEnd(),
                $"[exit code: {process.ExitCode}]"
            }.Where(value => !string.IsNullOrWhiteSpace(value)));
    }
}
