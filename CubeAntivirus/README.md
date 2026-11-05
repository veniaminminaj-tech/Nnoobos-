# Cube Antivirus 1.1.0

A Windows x64 WPF security diagnostics application targeting **.NET 10 LTS**.

## Included
- Recursive, read-only file scanning with SHA-256 signatures.
- Script heuristic indicators for review (heuristics are not proof of malware).
- Thread-safe in-memory hash database.
- Copy-only quarantine: original files remain in place.
- Read-only process inventory with optional WMI command-line and executable-path data.
- Advisory mining-pool command-line indicators; detections never terminate processes.
- Local HoneyPot decoy files with change-event logging.
- Asynchronous CMD execution with cancellation of the command started by the app.
- Administrator manifest and self-contained Windows x64 installer workflow.

## Safety and limitations
- No keyboard/mouse lock, hidden watchdog, process impersonation, or indiscriminate process termination.
- The HoneyPot watcher reports file-system change events; it cannot reliably detect file reads.
- The SHA-256 database is empty by default. Add only verified hashes from trusted sources.
- Heuristic matches are warnings for manual review, not definitive malware verdicts.
- Quarantine copies files and never deletes or moves the original.
- Process command lines may be unavailable when Windows denies WMI access; the UI falls back to basic process inventory.

## Build
Install the .NET 10 SDK and the Windows Desktop workload, then run:

```powershell
dotnet restore CubeAntivirus/CubeAntivirus.csproj
dotnet build CubeAntivirus/CubeAntivirus.csproj -c Release
dotnet publish CubeAntivirus/CubeAntivirus.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -o artifacts/CubeAntivirus
```

GitHub Actions also builds a self-contained EXE and an Inno Setup installer on pushes affecting `CubeAntivirus/**`.
