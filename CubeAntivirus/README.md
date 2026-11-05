# Cube Antivirus

WPF security diagnostics starter for Windows, targeting .NET 8.

Included: recursive SHA-256 scanner, script heuristic warnings, copy-based quarantine, process inventory, local HoneyPot decoys and event logging, asynchronous CMD terminal, administrator manifest.

Safety: this project does not freeze keyboard/mouse input, kill unrelated processes, install hidden watchdogs, impersonate system executables, or silently modify files. HoneyPot activity is logged for review. Quarantine copies files and leaves originals intact. The signature database starts empty; add only verified SHA-256 indicators.

Build with Visual Studio 2022 and the .NET 8 desktop workload, or run dotnet restore/build on CubeAntivirus.csproj.