using System.Windows;
using System.Windows.Threading;
using CubeAntivirus.Core;

namespace CubeAntivirus;

public partial class App : Application
{
    private static string LogPath => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "CubeAntivirus", "Logs", "startup.log");

    private static void WriteStartupLog(string message)
    {
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(LogPath)!);
            File.AppendAllText(LogPath, $"[{DateTimeOffset.Now:O}] {message}{Environment.NewLine}");
        }
        catch { /* Startup diagnostics must never prevent the app from opening. */ }
    }

    protected override async void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        DispatcherUnhandledException += (_, args) =>
        {
            WriteStartupLog("UI exception: " + args.Exception);
            MessageBox.Show("Cube Antivirus encountered an error. Details were saved to:\n" + LogPath +
                "\n\n" + args.Exception.Message, "Cube Antivirus error",
                MessageBoxButton.OK, MessageBoxImage.Error);
            args.Handled = true;
        };
        AppDomain.CurrentDomain.UnhandledException += (_, args) =>
            WriteStartupLog("Fatal exception: " + args.ExceptionObject);
        TaskScheduler.UnobservedTaskException += (_, args) =>
        {
            WriteStartupLog("Background task exception: " + args.Exception);
            args.SetObserved();
        };

        try
        {
            if (e.Args.Any(a => string.Equals(a, "--honeypot-worker", StringComparison.OrdinalIgnoreCase)))
            {
                ShutdownMode = ShutdownMode.OnExplicitShutdown;
                var dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "CubeAntivirus", "Logs");
                Directory.CreateDirectory(dir);
                var log = Path.Combine(dir, "honeypot-worker.log");
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
            WriteStartupLog("Main window shown successfully.");
        }
        catch (Exception ex)
        {
            WriteStartupLog("Startup failed: " + ex);
            MessageBox.Show("Cube Antivirus could not start. Diagnostic log:\n" + LogPath +
                "\n\n" + ex, "Cube Antivirus startup error",
                MessageBoxButton.OK, MessageBoxImage.Error);
            Shutdown(-1);
        }
    }
}
