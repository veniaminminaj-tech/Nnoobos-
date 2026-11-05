using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using CubeAntivirus.Core;
using CubeAntivirus.Models;
using CubeAntivirus.Modules;

namespace CubeAntivirus;

public partial class MainWindow : Window
{
    private readonly FileScanner _scanner = new(new HashDatabase());
    private readonly TerminalManager _terminal = new();
    private readonly ThreatLogger _logger = new();
    private readonly HoneyPotManager _honeyPot = new();
    private CancellationTokenSource? _scanCts;

    public MainWindow()
    {
        InitializeComponent();
        TerminalOutput.Text = "Cube Antivirus 1.1.0 initialized.\n.NET 10 · Ready.\n";

        _honeyPot.ActivityDetected += async (_, message) =>
        {
            await _logger.WriteAsync("HoneyPot: " + message);
            await Dispatcher.InvokeAsync(() =>
                ResultsList.Items.Insert(0,
                    MakeResult("HONEYPOT", message, ScanStatus.Warning)));
        };

        Closed += (_, _) =>
        {
            _scanCts?.Cancel();
            _scanCts?.Dispose();
            _honeyPot.Dispose();
        };
    }

    private async void Scan_Click(object sender, RoutedEventArgs e)
    {
        var root = PathBox.Text.Trim();

        if (!Directory.Exists(root))
        {
            MessageBox.Show("Folder does not exist.", "Cube Antivirus",
                MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        _scanCts?.Cancel();
        _scanCts?.Dispose();
        _scanCts = new CancellationTokenSource();
        ResultsList.Items.Clear();

        try
        {
            await foreach (var result in _scanner.ScanDirectoryAsync(root, _scanCts.Token))
            {
                ResultsList.Items.Add(MakeResult(
                    result.Status.ToString().ToUpperInvariant(),
                    result.Path + " — " + result.Details,
                    result.Status));

                await _logger.WriteAsync(
                    $"{result.Status}: {result.Path} — {result.Details}",
                    _scanCts.Token);
            }
        }
        catch (OperationCanceledException)
        {
            ResultsList.Items.Insert(0,
                MakeResult("CANCELLED", "Scan was cancelled.", ScanStatus.Warning));
        }
        catch (Exception ex)
        {
            ResultsList.Items.Insert(0,
                MakeResult("ERROR", ex.Message, ScanStatus.Error));
        }
    }

    private static System.Windows.Controls.ListBoxItem MakeResult(
        string title, string details, ScanStatus status)
    {
        var color = status switch
        {
            ScanStatus.Clean => Colors.LightGreen,
            ScanStatus.Threat => Colors.IndianRed,
            ScanStatus.Warning => Colors.Orange,
            _ => Colors.LightGray
        };

        return new System.Windows.Controls.ListBoxItem
        {
            Content = title + "  " + details,
            Foreground = new SolidColorBrush(color),
            Padding = new Thickness(6)
        };
    }

    private void Processes_Click(object sender, RoutedEventArgs e)
    {
        ResultsList.Items.Clear();

        foreach (var process in ProcessManager.GetProcesses())
        {
            var details = $"PID {process.Pid} · {process.Status}";
            if (!string.IsNullOrWhiteSpace(process.ExecutablePath))
                details += $" · {process.ExecutablePath}";

            ResultsList.Items.Add(MakeResult(
                process.IsMiner ? "REVIEW PROCESS" : "PROCESS",
                $"{process.Name} · {details}",
                process.IsMiner ? ScanStatus.Warning : ScanStatus.Clean));
        }
    }

    private async void RunCommand_Click(object sender, RoutedEventArgs e) =>
        await RunCommandAsync();

    private async void CommandBox_KeyDown(object sender, KeyEventArgs e)
    {
        if (e.Key == Key.Enter)
            await RunCommandAsync();
    }

    private async Task RunCommandAsync()
    {
        var command = CommandBox.Text.Trim();
        if (command.Length == 0)
            return;

        CommandBox.Clear();
        TerminalOutput.AppendText($"> {command}\n");

        try
        {
            var output = await _terminal.ExecuteAsync(command);
            TerminalOutput.AppendText(output + Environment.NewLine);
        }
        catch (Exception ex)
        {
            TerminalOutput.AppendText("ERROR: " + ex.Message + Environment.NewLine);
        }

        TerminalOutput.ScrollToEnd();
    }
}
