#define MyAppName "OwlContext"
#define MyAppVersion "0.1.4-beta"
#define MyAppPublisher "OwlContext"
#define MyAppURL "https://example.com/"
#define MyAppExeName "OwlContext.exe"

[Setup]
; 应用程序基本信息
AppId={{7D1F1A20-1234-4A56-9B8C-ABC123DEF456}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=build-output
OutputBaseFilename=OwlContext-Setup-{#MyAppVersion}
SetupIconFile=frontend\build\icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

; 权限设置
PrivilegesRequired=poweruser
PrivilegesRequiredOverridesAllowed=dialog

; 卸载信息
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; 打包前端构建的应用程序
Source: "frontend\dist\win-unpacked\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Dirs]
Name: "{app}\config"

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
var
  AppPath: String;
  ExePath: String;
begin
  if CurStep = ssPostInstall then
  begin
    // 获取可执行文件完整路径
    ExePath := ExpandConstant('{app}\{#MyAppExeName}');
    
    // 验证文件是否存在
    if not FileExists(ExePath) then
    begin
      Log('错误: 可执行文件不存在: ' + ExePath);
      MsgBox('警告: 无法设置开机启动，因为找不到程序文件。' + #13#10 + 
             '路径: ' + ExePath, mbError, MB_OK);
      Exit;
    end;
    
    // Windows 启动项路径需要引号包裹以正确处理包含空格的路径
    // 添加 --hidden 参数使其在开机时直接在后台运行
    AppPath := '"' + ExePath + '" --hidden';
    
    // 写入注册表到 HKEY_CURRENT_USER，不需要管理员权限
    if RegWriteStringValue(HKEY_CURRENT_USER,
      'Software\Microsoft\Windows\CurrentVersion\Run',
      'OwlContext',
      AppPath) then
    begin
      Log('成功: 已添加开机启动注册表项');
      Log('  键名: OwlContext');
      Log('  路径: ' + AppPath);
    end
    else
    begin
      Log('错误: 无法写入开机启动注册表项');
      Log('  注册表路径: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run');
      Log('  尝试写入的值: ' + AppPath);
      MsgBox('警告: 无法设置开机启动项。' + #13#10 + 
             '请手动在应用程序设置中启用开机启动功能。', mbInformation, MB_OK);
    end;
  end;
end;

function InitializeUninstall(): Boolean;
begin
  // 卸载时删除开机启动项
    RegDeleteValue(HKEY_CURRENT_USER,
      'Software\Microsoft\Windows\CurrentVersion\Run',
      'OwlContext');
  Result := True;
end;

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\logs"
