using System.Windows;
using CubeAntivirus.Core;

namespace CubeAntivirus;

public partial class App : Application
{
    protected override async void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        if (e.Args.Any(a => string.Equals(a, "--honeypot-worker", StringComparison.OrdinalIgnoreCase)))
        {
            ShutdownMode = ShutdownMode.OnExplicitShutdown;
            var dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "CubeAntivirus", "Logs");
            Directory.CreateDirectory(dir);
            var log = Path.Combine(dir, "honeypot-worker.log");
            // Visible, harmless test worker: no persistence, hiding, self-restart or process protection.
            while (true)
            {
                await File.AppendAllTextAsync(log, $"[{DateTimeOffset.Now:O}] HoneyPot worker running.{Environment.NewLine}");
                await Task.Delay(TimeSpan.FromSeconds(10));
            }
        }
        ProcessProtection.Initialize();
        var window = new MainWindow();
        MainWindow = window;
        window.Show();
    }
}