using System.Collections.ObjectModel;
using System.Windows;
using Microsoft.Win32;
using CubeAntivirus.Core;
using CubeAntivirus.Models;
using CubeAntivirus.Modules;

namespace CubeAntivirus;

public partial class MainWindow : Window
{
    private readonly FileScanner _scanner = new(new HashDatabase());
    private readonly ThreatLogger _logger = new();
    private readonly HoneyPotManager _honeyPot = new();
    private readonly QuarantineManager _quarantine = new();
    private readonly ObservableCollection<ScanResult> _results = new();
    private readonly ObservableCollection<ProcessEntry> _processes = new();
    private readonly ObservableCollection<QuarantineRecord> _quarantineItems = new();
    private CancellationTokenSource? _scanCts;
    private int _scanned, _threats, _warnings;

    public MainWindow()
    {
        InitializeComponent();
        ResultsGrid.ItemsSource = _results;
        ProcessesGrid.ItemsSource = _processes;
        QuarantineGrid.ItemsSource = _quarantineItems;
        PathBox.Text = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        _honeyPot.ActivityDetected += HoneyPot_ActivityDetected;
        Loaded += async (_, _) =>
        {
            await RefreshQuarantineAsync();
            await ReloadLogAsync();
            await _logger.WriteAsync("Cube Antivirus started.");
        };
        Closed += (_, _) =>
        {
            _scanCts?.Cancel();
            _scanCts?.Dispose();
            _honeyPot.ActivityDetected -= HoneyPot_ActivityDetected;
            _honeyPot.Dispose();
        };
    }

    private async void HoneyPot_ActivityDetected(object? sender, string message)
    {
        await _logger.WriteAsync("HoneyPot activity: " + message);
        await Dispatcher.InvokeAsync(() =>
        {
            ActivityLog.AppendText($"[{DateTimeOffset.Now:O}] HONEYPOT: {message}{Environment.NewLine}");
            ActivityLog.ScrollToEnd();
        });
    }

    private void Browse_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFolderDialog { Title = "Choose a folder to scan" };
        if (dialog.ShowDialog(this) == true) PathBox.Text = dialog.FolderName;
    }

    private async void Scan_Click(object sender, RoutedEventArgs e)
    {
        var root = PathBox.Text.Trim();
        if (!Directory.Exists(root))
        {
            MessageBox.Show("The selected folder does not exist.", "Cube Antivirus",
                MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        _scanCts?.Cancel();
        _scanCts?.Dispose();
        _scanCts = new CancellationTokenSource();
        var token = _scanCts.Token;
        _results.Clear();
        _scanned = _threats = _warnings = 0;
        UpdateCounters();
        CancelScanButton.IsEnabled = true;
        ScanStatusText.Text = "Scanning…";

        try
        {
            await foreach (var result in _scanner.ScanDirectoryAsync(root, token))
            {
                _results.Add(result);
                _scanned++;
                if (result.Status == ScanStatus.Threat) _threats++;
                if (result.Status == ScanStatus.Warning) _warnings++;
                UpdateCounters();
                ScanStatusText.Text = $"Scanned {_scanned:N0} items…";
                await _logger.WriteAsync($"{result.Status}: {result.Path} — {result.Details}", token);
            }
            ScanStatusText.Text = $"Scan complete. {_scanned:N0} items checked.";
            await _logger.WriteAsync($"Scan completed: {_scanned} items, {_threats} threats, {_warnings} warnings.");
        }
        catch (OperationCanceledException)
        {
            ScanStatusText.Text = $"Scan cancelled after {_scanned:N0} items.";
            await _logger.WriteAsync(ScanStatusText.Text);
        }
        catch (Exception ex)
        {
            ScanStatusText.Text = "Scan failed: " + ex.Message;
            await _logger.WriteAsync("Scan error: " + ex);
        }
        finally
        {
            CancelScanButton.IsEnabled = false;
        }
    }

    private void CancelScan_Click(object sender, RoutedEventArgs e) => _scanCts?.Cancel();

    private void UpdateCounters()
    {
        ScannedCount.Text = _scanned.ToString("N0");
        ThreatCount.Text = _threats.ToString("N0");
        WarningCount.Text = _warnings.ToString("N0");
    }

    private async void QuarantineSelected_Click(object sender, RoutedEventArgs e)
    {
        if (ResultsGrid.SelectedItem is not ScanResult selected ||
            selected.Status is not (ScanStatus.Threat or ScanStatus.Warning))
        {
            MessageBox.Show("Select a file marked Threat or Warning first.", "Cube Antivirus",
                MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }

        var confirm = MessageBox.Show(
            $"Create an isolated copy of this file? The original will remain unchanged.\n\n{selected.Path}",
            "Confirm quarantine", MessageBoxButton.YesNo, MessageBoxImage.Warning);
        if (confirm != MessageBoxResult.Yes) return;

        try
        {
            var stored = await _quarantine.CopyToQuarantineAsync(selected.Path);
            await _logger.WriteAsync($"Quarantined copy created: {selected.Path} -> {stored}");
            await RefreshQuarantineAsync();
            MessageBox.Show("An isolated copy was created. The original file was not changed.",
                "Cube Antivirus", MessageBoxButton.OK, MessageBoxImage.Information);
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.Message, "Quarantine failed", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void Processes_Click(object sender, RoutedEventArgs e)
    {
        _processes.Clear();
        foreach (var process in ProcessManager.GetProcesses()) _processes.Add(process);
    }

    private async void RefreshQuarantine_Click(object sender, RoutedEventArgs e) => await RefreshQuarantineAsync();

    private async Task RefreshQuarantineAsync()
    {
        _quarantineItems.Clear();
        foreach (var item in await _quarantine.GetItemsAsync()) _quarantineItems.Add(item);
        QuarantineCount.Text = _quarantineItems.Count.ToString("N0");
    }

    private async void RestoreSelected_Click(object sender, RoutedEventArgs e)
    {
        if (QuarantineGrid.SelectedItem is not QuarantineRecord item)
        {
            MessageBox.Show("Select a quarantine entry first.", "Cube Antivirus",
                MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }

        var dialog = new SaveFileDialog
        {
            Title = "Restore quarantined copy",
            FileName = Path.GetFileName(item.OriginalPath),
            Filter = "All files|*.*",
            OverwritePrompt = true
        };
        if (dialog.ShowDialog(this) != true) return;

        try
        {
            await _quarantine.RestoreCopyAsync(item, dialog.FileName);
            await _logger.WriteAsync($"Restored copy: {item.Id} -> {dialog.FileName}");
            MessageBox.Show("The file was restored as a copy. The quarantine entry remains available.",
                "Cube Antivirus", MessageBoxButton.OK, MessageBoxImage.Information);
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.Message, "Restore failed", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private async void ReloadLog_Click(object sender, RoutedEventArgs e) => await ReloadLogAsync();

    private async Task ReloadLogAsync()
    {
        ActivityLog.Text = await _logger.ReadAllAsync();
        ActivityLog.ScrollToEnd();
    }
}