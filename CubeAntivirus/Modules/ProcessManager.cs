using System.Diagnostics;
using System.Management;

namespace CubeAntivirus.Modules;

public sealed record ProcessEntry(
    string Name,
    int Pid,
    string Status,
    string? ExecutablePath,
    string? CommandLine,
    bool IsMiner);

/// <summary>
/// Read-only process inventory. Detection labels are advisory and do not stop processes.
/// </summary>
public static class ProcessManager
{
    public static IReadOnlyList<ProcessEntry> GetProcesses()
    {
        var entries = new List<ProcessEntry>();

        try
        {
            using var searcher = new ManagementObjectSearcher(
                "SELECT Name, ProcessId, ExecutablePath, CommandLine FROM Win32_Process");
            using var collection = searcher.Get();

            foreach (ManagementObject item in collection)
            {
                using (item)
                {
                    var name = Convert.ToString(item["Name"]) ?? "Unknown";
                    var pid = Convert.ToInt32(item["ProcessId"]);
                    var path = Convert.ToString(item["ExecutablePath"]);
                    var commandLine = Convert.ToString(item["CommandLine"]);
                    var isMiner = LooksLikeMiner(commandLine);

                    entries.Add(new ProcessEntry(
                        name,
                        pid,
                        isMiner ? "Possible miner — review" : "Running",
                        path,
                        commandLine,
                        isMiner));
                }
            }
        }
        catch (Exception ex) when (ex is ManagementException
                                   or UnauthorizedAccessException
                                   or System.Runtime.InteropServices.COMException
                                   or InvalidOperationException)
        {
            return GetBasicProcessList();
        }

        return entries.OrderBy(entry => entry.Name, StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }

    public static bool LooksLikeMiner(string? commandLine)
    {
        if (string.IsNullOrWhiteSpace(commandLine))
            return false;

        string[] indicators =
        {
            "--stratum",
            "stratum+tcp://",
            "stratum+ssl://",
            "-o pool"
        };

        return indicators.Any(indicator =>
            commandLine.Contains(indicator, StringComparison.OrdinalIgnoreCase));
    }

    private static IReadOnlyList<ProcessEntry> GetBasicProcessList()
    {
        var entries = new List<ProcessEntry>();

        foreach (var process in Process.GetProcesses())
        {
            try
            {
                entries.Add(new ProcessEntry(
                    process.ProcessName,
                    process.Id,
                    "Running — command line unavailable",
                    TryGetPath(process),
                    null,
                    false));
            }
            catch (Exception ex) when (ex is InvalidOperationException
                                       or System.ComponentModel.Win32Exception)
            {
                // Process exited or access was denied while taking the snapshot.
            }
            finally
            {
                process.Dispose();
            }
        }

        return entries.OrderBy(entry => entry.Name, StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }

    private static string? TryGetPath(Process process)
    {
        try { return process.MainModule?.FileName; }
        catch (Exception ex) when (ex is InvalidOperationException
                                   or System.ComponentModel.Win32Exception
                                   or NotSupportedException)
        {
            return null;
        }
    }
}
