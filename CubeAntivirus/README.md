# Cube Antivirus 1.2.0

Cube Antivirus is a Windows x64 WPF security utility targeting .NET 10 LTS.

## Features
- Dashboard counters for scanned files, detections, warnings and quarantine entries.
- Recursive asynchronous file scanning with SHA-256 calculation.
- Heuristic script indicators are reported as warnings, not definitive malware verdicts.
- Quarantine creates a separate copy, verifies its SHA-256, and records metadata.
- Restore verifies the quarantined copy and refuses to overwrite an existing destination.
- Read-only process inventory with optional WMI command-line indicators.
- Local synthetic HoneyPot files with filesystem change-event logging.
- Local activity log with reload support.
- Self-contained Windows x64 executable and Inno Setup installer through GitHub Actions.

## Important limitations
This is a local defensive utility, not a replacement for Microsoft Defender or a commercial antivirus engine. Its SHA-256 signature set is empty unless verified signatures are added from trusted sources. Heuristic matches can be false positives. Process command-line indicators are advisory. The HoneyPot watcher detects filesystem changes, not reads, and cannot reliably identify the responsible process.

The scanner does not modify scanned files. Quarantine does not move or delete originals. Restored files are copied out only after hash verification. No global input lock, hidden persistence, automatic process termination, or automatic system configuration changes are implemented.

## Build
Install the .NET 10 SDK on Windows:

```powershell
dotnet restore CubeAntivirus/CubeAntivirus.csproj
dotnet build CubeAntivirus/CubeAntivirus.csproj -c Release
dotnet publish CubeAntivirus/CubeAntivirus.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -o artifacts/CubeAntivirus
```

GitHub Actions builds a portable EXE and a Windows installer on pushes affecting `CubeAntivirus/**`.
