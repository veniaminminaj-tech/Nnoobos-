# Cube Antivirus 1.4.0

Windows x64 defensive utility with one all-in-one installer.

## Included in the installer
- **GUI:** CubeAntivirus.exe — WPF desktop interface with scanner, process inventory, quarantine, activity log and HoneyPot controls.
- **Console:** CubeAntivirus.CLI.exe — command-line scanner and read-only process inventory.
- **HoneyPot worker:** CubeAntivirus.HoneyPot.exe — visible test worker launched by the GUI HoneyPot tab.

## Console commands
Open Command Prompt in the installation folder (usually `C:\Program Files\Cube Antivirus`):
- `CubeAntivirus.CLI.exe help`
- `CubeAntivirus.CLI.exe scan "C:\Path\To\Folder"`
- `CubeAntivirus.CLI.exe processes`

The scanner is read-only. It calculates SHA-256 and checks the currently configured signature set plus simple script heuristics. A warning is not proof of malware. Process labels are advisory and no process is terminated.

## HoneyPot
The HoneyPot creates synthetic decoy files in `%LOCALAPPDATA%\CubeAntivirus\HoneyPotDisk` and can map that folder as a temporary SUBST drive. It is not a physical disk or partition. FileSystemWatcher records filesystem changes but cannot detect reads or reliably identify the process responsible.

The worker is an ordinary user-mode process. It has no hidden startup, persistence, self-restart or tamper protection. It can be ended through Task Manager or other authorized tools.

## Safety and limitations
This is not a replacement for Microsoft Defender or a commercial antivirus engine. The default signature database is empty unless trusted signatures are added. Heuristic matches can be false positives. The scanner does not alter scanned files; quarantine stores and verifies a copy and leaves the original untouched.
