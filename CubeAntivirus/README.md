# Cube Antivirus 1.3.0

Windows x64 WPF defensive utility targeting .NET 10.

## Features
- Recursive read-only file scan with SHA-256 and heuristic warnings.
- Copy-only quarantine with hash verification and restore protection.
- Read-only process inventory and advisory command-line indicators.
- Synthetic HoneyPot files in a dedicated local folder, optionally mapped as a temporary drive using Windows SUBST.
- HoneyPot filesystem change logging (created, changed, renamed, deleted).
- Optional visible HoneyPot worker process for Task Manager exit-detection tests.
- Local event log, portable self-contained EXE and Inno Setup installer.

## HoneyPot details and limitations
The virtual drive is a SUBST mapping to the local folder %LOCALAPPDATA%\CubeAntivirus\HoneyPotDisk. It is not a separate partition or physical disk and contains synthetic placeholders only. The mapping is temporary and can be detached in the HoneyPot tab.

The worker is an ordinary user-mode process named CubeAntivirus.HoneyPot.exe. It writes a heartbeat to the local log and can be ended in Windows Task Manager. It has no hidden startup, persistence, self-restart or process protection. Windows and other authorized tools can also end it; termination cannot technically be restricted to Task Manager alone.

FileSystemWatcher detects filesystem changes, not reads, and cannot reliably identify which process caused a change.

## Important
This is a local defensive utility, not a replacement for Microsoft Defender or a commercial antivirus engine. The signature set is empty unless trusted signatures are added. Heuristic matches can be false positives. Process command-line indicators are advisory. The scanner does not modify scanned files, and quarantine never moves or deletes originals.

## Build
Install the .NET 10 SDK on Windows. Run dotnet restore/build/publish for CubeAntivirus/CubeAntivirus.csproj. After publish, copy CubeAntivirus.exe to CubeAntivirus.HoneyPot.exe in the publish folder; the installer includes both executables.
