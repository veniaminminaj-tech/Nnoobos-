# Cube Antivirus Mobile

Android companion app written in Kotlin. It lets the user explicitly select a folder through Android's Storage Access Framework and performs a read-only SHA-256 inventory plus basic text-pattern triage.

## Build
Open this directory in Android Studio, or run:
`gradle assembleDebug`

APK output:
`app/build/outputs/apk/debug/app-debug.apk`

## Safety and limitations
- No broad storage permission; user selects a folder.
- Read-only: does not delete, modify, quarantine, or upload files.
- Pattern matches are warnings for manual review, not malware verdicts.
- No real-time protection or signature database yet; not a replacement for Google Play Protect.
