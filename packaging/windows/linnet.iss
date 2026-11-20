; Linnet's Windows installer, for Inno Setup 6.3 or later. The release
; workflow builds it from the app `skein package --windows` makes:
;
;   ISCC.exe /DAppVersion=0.1.0 /DArch=x64 /DSourceDir=C:\...\Linnet ^
;            /DOutputDir=C:\...\out packaging\windows\linnet.iss
;
; SourceDir is the zip's Linnet folder (bin\linnet.exe and lib\linnet\).
; Arch is x64 or arm64. The installer needs no administrator: it installs
; for the person running it, under %LOCALAPPDATA%\Programs\Linnet (or for
; everyone, if they choose so and can). Uninstalling leaves the library in
; %APPDATA%\Linnet, so reinstalling keeps her music's names and playlists.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef Arch
  #define Arch "x64"
#endif
#ifndef SourceDir
  #error Give the app's folder with /DSourceDir=...
#endif
#ifndef OutputDir
  #define OutputDir "."
#endif

[Setup]
; (one id for every version, so a new installer upgrades the old install)
AppId={{B112AF1A-2F03-4995-86EE-63F81D3680DF}
AppName=Linnet
AppVersion={#AppVersion}
AppVerName=Linnet {#AppVersion}
AppPublisher=Jessie Hughart
AppPublisherURL=https://github.com/crazymevt/linnet
AppSupportURL=https://github.com/crazymevt/linnet/issues
AppUpdatesURL=https://github.com/crazymevt/linnet/releases
VersionInfoVersion={#AppVersion}
DefaultDirName={autopf}\Linnet
DisableProgramGroupPage=yes
DisableDirPage=auto
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
#if Arch == "arm64"
ArchitecturesAllowed=arm64
ArchitecturesInstallIn64BitMode=arm64
#else
; (an x64 Linnet runs on ARM PCs too, emulated)
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
#endif
MinVersion=10.0
SetupIconFile=..\..\assets\linnet.ico
UninstallDisplayIcon={app}\bin\linnet.exe
UninstallDisplayName=Linnet
WizardStyle=modern
OutputDir={#OutputDir}
OutputBaseFilename=Linnet-{#AppVersion}-windows-{#Arch}-setup
Compression=lzma2/max
SolidCompression=yes
CloseApplications=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]
; (an upgrade replaces the app's files wholesale, so none are left from the old one)
Type: filesandordirs; Name: "{app}\lib"

[Icons]
Name: "{autoprograms}\Linnet"; Filename: "{app}\bin\linnet.exe"; WorkingDir: "{userdocs}"; AppUserModelID: "dev.skein.linnet"
Name: "{autodesktop}\Linnet"; Filename: "{app}\bin\linnet.exe"; WorkingDir: "{userdocs}"; AppUserModelID: "dev.skein.linnet"; Tasks: desktopicon

[Run]
Filename: "{app}\bin\linnet.exe"; Description: "{cm:LaunchProgram,Linnet}"; Flags: nowait postinstall skipifsilent
