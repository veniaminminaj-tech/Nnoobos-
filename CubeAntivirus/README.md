# Cube Antivirus 1.5.0

Windows x64 defensive utility.

## Included
- WPF desktop app: scanner, process inventory, quarantine, activity log and HoneyPot.
- Console app: scanning, JSON/CSV reports, scan history, local trusted-hash list, certificate inspection, large-file listing, executable/script inventory and HoneyPot worker log.
- Visible HoneyPot worker, packaged with the GUI.
- All-in-one Inno Setup installer.

## Console commands
```text
CubeAntivirus.CLI.exe help
CubeAntivirus.CLI.exe scan "C:\Users\Public" --exclude "C:\Users\Public\Temp" --json report.json --csv report.csv
CubeAntivirus.CLI.exe scan "C:\Windows\notepad.exe"
CubeAntivirus.CLI.exe history
CubeAntivirus.CLI.exe trust add "C:\Path\verified-file.exe"
CubeAntivirus.CLI.exe trust list
CubeAntivirus.CLI.exe signature "C:\Path\file.exe"
CubeAntivirus.CLI.exe large "C:\Users\Public" 250
CubeAntivirus.CLI.exe types "C:\Users\Public"
CubeAntivirus.CLI.exe processes
CubeAntivirus.CLI.exe honeypot-log
```

## Notes
The scanner is read-only and uses SHA-256 plus a small set of simple script indicators. Heuristic matches are warnings, not proof. The trust list is local and only affects display labels; it does not alter scan results. Only add hashes for files independently verified by you.

The signature command reads embedded certificate metadata only; it does not validate Authenticode integrity, revocation, or Windows trust. Extension listing and file size are informational signals only.

The HoneyPot creates synthetic decoy files in `%LOCALAPPDATA%\CubeAntivirus\HoneyPotDisk` and can map the folder as a temporary SUBST drive. It is not a physical disk. FileSystemWatcher records changes but cannot detect reads or reliably identify the process responsible. The test worker is an ordinary user-mode process with no hidden startup, persistence, self-restart or tamper protection.

This is not a replacement for Microsoft Defender or a commercial antivirus engine.
