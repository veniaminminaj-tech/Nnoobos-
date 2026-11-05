#define MyAppName "Cube Antivirus"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Cube Antivirus"

[Setup]
AppId={{8B3E5A76-3F1A-4D74-9D3B-5C2F3E8A1B90}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\Cube Antivirus
DefaultGroupName=Cube Antivirus
OutputDir=..\artifacts\installer
OutputBaseFilename=CubeAntivirus-Setup-x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\CubeAntivirus.exe
CloseApplications=yes
RestartApplications=no

[Files]
Source: "..\artifacts\CubeAntivirus\CubeAntivirus.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Cube Antivirus"; Filename: "{app}\CubeAntivirus.exe"
Name: "{autodesktop}\Cube Antivirus"; Filename: "{app}\CubeAntivirus.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Створити ярлик на робочому столі"; GroupDescription: "Додаткові параметри:"; Flags: unchecked

[Run]
Filename: "{app}\CubeAntivirus.exe"; Description: "Запустити Cube Antivirus"; Flags: postinstall nowait skipifsilent
