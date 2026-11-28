@REF:windows-installer
§META{scope:Nuitka_4.x(--mode=standalone)+InnoSetup_6_Win_installer(min_size,fast_start)|Py3.12-3.14|¬onefile|¬console}
§D{use⇔adv_Win_pkg(min_size∨fast_start∨slim_dist∨DLL_audit∨32v64∨Inno_uninstall);¬use⇔basic_1file_exe}
§WF{
  1:ask_user(¬defaults;wait):APP_NAME(RedInk),APP_VERSION(1.0.0),PUBLISHER(YourCompany),EXE_NAME(RedInk.exe),SOURCE_DIR(D:\project\dist\RedInk.dist),OUTPUT_DIR(D:\project\output),ICON_PATH(opt,.ico,D:\project\icon.ico),APP_URL(opt,https://example.com);
  2:chk_src(Inno=packager_only):`--mode=standalone`∧`--windows-console-mode=disable`∧`--lto=yes`∧(VC++∈dist∨bundle_matching_arch);
  3:compile(nuitka+excl+plugins);4:slim_dist(keep_runtime_meta);5:analyze_dlls→trim;6:Inno6(lzma2/ultra64,meta,clean_uninstall,arch_VC++)
}
§BENCH{
  hist_ref(PySide2+OpenCV+Playwright,32b_Py3.8):323MB,71_DLLs(93MB){playwright:76.7MB(24%→rm),OpenCV:62.4MB(19%→headless),PySide2:22.5MB(7%→excl_WebEngine/3D/Charts),other:161.4MB(50%)};
  sizes(raw→opt):Tkinter:150-250→80-120MB|PySide6/PyQt6:200-400→120-250MB|numpy/pandas:300-600→180-350MB;
  gains(sz↓/boot↑):lto(-5-10%/+10-20%)|anti-bloat(-15-25%/-)|excl(-20-35%/+5%)|slim(-25-40%/-)|32b(-40-60%/-)|all(-45-65%/+15-25%)
}
§R{
  mode:Nuitka≥2.5/4.x⇒`--mode=standalone`¬deprecated `--standalone`(combining_both_errors);
  arch:64bit_default(modern_Win10/11+ARM64_emul);32bit⇔(mem<2GB∧file≤2GB∧legacy_office_PC)⇒-20-30%_sz(QtCore:8→5MB,numpy:30→20MB);
  excl(30-50MB):unittest,test,pytest,_pytest,doctest,pdb,pdbpp,setuptools,pip,distutils,pkg_resources,email.mime,http.server,xmlrpc,pydoc;
  ¬UPX(AV_false_pos)
}
§CMD{
  32b:`py -3.14-32 -m pip install -r requirements.txt && py -3.14-32 -m nuitka --mode=standalone ...`;
  nuitka_tk(80-120MB):`python -m nuitka --mode=standalone --windows-console-mode=disable --lto=yes --jobs=8 --enable-plugin=tk-inter,anti-bloat --noinclude-pytest-mode=nofollow --noinclude-setuptools-mode=nofollow --nofollow-import-to=unittest,test,pytest,_pytest,doctest,pdb,pdbpp,setuptools,pip,distutils,pkg_resources,email.mime,http.server,xmlrpc,pydoc --python-flag=no_docstrings --output-dir=dist --windows-icon-from-ico=icon.ico --remove-output main.py`;
  nuitka_qt(120-250MB):replace `tk-inter`→`pyside6`(or `pyqt6`)+`--include-qt-plugins=sensible,styles,platforms`+`--nofollow-import-to=...,PySide6.QtWebEngineCore,PySide6.QtWebEngineWidgets,PySide6.Qt3DCore,PySide6.QtCharts`;
  dll:`python analyze_dlls.py dist/YourApp.dist`;
  fix:{OpenCV:`uv remove opencv-python && uv add opencv-python-headless`,Qt:`--nofollow-import-to=PySide6.QtWebEngineCore,PySide6.QtWebEngineWidgets,PySide6.Qt3DCore,PySide6.QtCharts`,sw_gl:`Remove-Item "opengl32sw.dll" -Force`(if_unused)};
  vc_static:`python -m nuitka --static-libpython=yes ...`
}
§PAT:scripts{
  build_optimized.bat(root;¬wmic_Win11_22H2+→--jobs=0;use `%NUMBER_OF_PROCESSORS%` fallback 4):
  `chcp 65001 >nul`→rm `dist,build`→run `python -m nuitka --mode=standalone`(above flags,`--jobs=%BUILD_JOBS%`)→`if %errorlevel% neq 0 exit /b 1`→measure `dist\%APP_NAME%.dist`(`/1048576`)→`powershell -ExecutionPolicy Bypass -File slim_dist.ps1 -DistPath "dist\%APP_NAME%.dist"`;
  slim_dist.ps1(15-30%_saved):
```powershell
param([Parameter(Mandatory)][string]$DistPath)
$ErrorActionPreference="Continue"; if(!(Test-Path -LiteralPath $DistPath)){exit 1}
Get-ChildItem -LiteralPath $DistPath -Recurse -Include *.pdb,*.pyi,*.pyc -File|Remove-Item -Force
Get-ChildItem -LiteralPath $DistPath -Recurse -Directory|?{$_.Name -match '^(__pycache__|tests?|docs|examples|samples|demo)$'}|Sort {$_.FullName.Length} -Desc|%{if(Test-Path -LiteralPath $_.FullName){Remove-Item -LiteralPath $_.FullName -Recurse -Force}}
Get-ChildItem -LiteralPath $DistPath -Recurse -Directory -Filter *.dist-info|%{"RECORD","INSTALLER","direct_url.json"|%{$f=Join-Path $_.FullName $_;if(Test-Path -LiteralPath $f){Remove-Item -LiteralPath $f -Force}}} # Keep METADATA & entry_points.txt (importlib.metadata)
```
  analyze_dlls.py(flag>3MB[`3*1024*1024`];hints:{openblas/mkl:26.9MB_ref,opencv/ffmpeg:18.5MB_ref→headless,qt6/pyside6:excl_WebEngine/3D/Charts,d3dcompiler:~3.5MB,mfc140:~4.9MB,opengl+sw:~15MB_safe_del_if_HW};flag `*d.dll` if non-d stem exists;keep `vcruntime`/`msvcp`;print total+top20;exit(2) on bad argv,exit(1) if ¬dir)
}
§CFG:InnoSetup6{
  VC++_redist(rec_commercial;64b:`vc_redist.x64.exe`,32b:`vc_redist.x86.exe`;https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist):
  `[Files] Source: "{#MySourceDir}\..\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall`;
  `[Run] Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/quiet /norestart"; StatusMsg: "Installing runtime..."; Flags: waituntilterminated`;
  arch_64b:Inno6.4+⇒`ArchitecturesInstallIn64BitMode=x64compatible`(supports_x64+ARM64_emul)∨native_64b_installer:`SetupArchitecture=x64`(Inno≥6.5/7);
  template(placeholders:`{{APP_NAME}},{{APP_VERSION}},{{PUBLISHER}},{{APP_URL}},{{EXE_NAME}},{{SOURCE_DIR}},{{OUTPUT_DIR}},{{ICON_PATH}},{{GENERATE_RANDOM_GUID}}`[Tools>Generate GUID];32b_only:comment_out `ArchitecturesInstallIn64BitMode`;i18n:`Name:"chinesesimplified";MessagesFile:"compiler:Languages\ChineseSimplified.isl"`):
```iss
#define MyAppName "{{APP_NAME}}"
#define MyAppVersion "{{APP_VERSION}}"
#define MyAppPublisher "{{PUBLISHER}}"
#define MyAppURL "{{APP_URL}}"
#define MyAppExeName "{{EXE_NAME}}"
#define MySourceDir "{{SOURCE_DIR}}"
#define MyOutputDir "{{OUTPUT_DIR}}"
;#define MyIconPath "{{ICON_PATH}}"
[Setup]
AppId={{GENERATE_RANDOM_GUID}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableDirPage=no
DisableProgramGroupPage=no
PrivilegesRequired=admin
OutputDir={#MyOutputDir}
OutputBaseFilename=Setup_{#MyAppName}_v{#MyAppVersion}
WizardStyle=modern
#ifdef MyIconPath
SetupIconFile={#MyIconPath}
UninstallDisplayIcon={app}\{#MyAppExeName}
#endif
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes
ArchitecturesInstallIn64BitMode=x64compatible
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
[Files]
Source: "{#MySourceDir}\*"; DestDir: "{app}"; Excludes: "_nuitka_temp.exe"; Flags: ignoreversion recursesubdirs createallsubdirs
[UninstallDelete]
Type: filesandordirs; Name: "{app}\*"
[Icons]
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
```
}
§DBG{
  no_start⇒run_cmd∧chk_VC++∧chk_nuitka;
  missing_python3xx.dll⇒`--mode=standalone`∧∈dist(¬onefile);
  mode_conflict⇒`--mode=standalone`¬deprecated `--standalone`(Nuitka≥2.5/4.x);
  click_freeze⇒lazy_import+log;
  too_large⇒excl+anti-bloat+slim_dist+analyze_dlls(+32b_if_legacy);
  MinGW_nonASCII⇒ASCII_path∧PYTHONIOENCODING=utf-8;
  Inno_x64_warn⇒`ArchitecturesInstallIn64BitMode=x64compatible`∨`SetupArchitecture=x64`;
  `--disable-console`_depr⇒`--windows-console-mode=disable`;
  `_nuitka_temp.exe`⇒`Excludes:"_nuitka_temp.exe"`;
  AV_flag⇒allowlist+sign(Sectigo,DigiCert)+¬UPX;
  SmartScreen⇒EV_cert(instant)⊕std_cert(install_count)
}
