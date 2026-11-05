namespace CubeAntivirus.Core;

public static class ProcessProtection
{
    // Avoids disruptive policies that would disable the app terminal or child operations.
    public static void Initialize()
    {
        _ = Environment.ProcessId;
    }
}
