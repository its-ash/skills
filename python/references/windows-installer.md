# Windows Installer (Nuitka + Inno Setup)

Ship a Python app as the smallest, fastest-starting Windows installer: Nuitka folder-mode (`dist`) compile, `dist` slimming, DLL size analysis, and Inno Setup packaging.

## When to use

- The user asks for advanced Python packaging on Windows: smallest size or fastest startup.
- You must slim a Nuitka `dist` folder, find large DLLs, or choose 32-bit vs 64-bit.
- You must make an Inno Setup installer with full metadata and a clean uninstall.
- Do not use for a basic one-file "script to exe" conversion.

## Core approach

Use **Nuitka folder mode (`--standalone`) + Inno Setup**. Do not make single-file builds. Do not show a console window.

## Workflow

1. **Confirm parameters with the user.** Do not fill defaults. Ask for each value and wait for a reply:

   | Parameter | Meaning | Example |
   |---|---|---|
   | App Name | Display name | `RedInk` |
   | Version | Semantic version | `1.0.0` |
   | Publisher | Name in Control Panel | `YourCompany` |
   | Exe Name | Main executable | `RedInk.exe` |
   | Source Dir | Absolute path of the Nuitka `dist` folder | `D:\project\dist\RedInk.dist` |
   | Output Dir | Where the installer goes | `D:\project\output` |
   | Icon Path | `.ico` file (optional, recommended) | `D:\project\icon.ico` |
   | URL | Optional Control Panel link | `https://example.com` |

2. **Check the source build.** Inno Setup only packages files; it cannot change how the program runs. Ask the user to confirm:
   - The build used `--windows-console-mode=disable` (else a console window shows).
   - The build used `--lto=yes` (else startup is slower).
   - The `dist` folder has the VC++ runtime, or the installer bundles it (else the app fails on a clean system).
3. **Compile with Nuitka** (module exclusions and plugins below).
4. **Slim `dist`** (debug symbols, caches, tests, docs). Keep runtime metadata.
5. **Analyze DLLs** and trim the largest ones.
6. **Package with Inno Setup**: LZMA2 ultra compression, full metadata, clean uninstall, VC++ redistributable that matches the build architecture.

## Reference case

Production PySide2 desktop app with OpenCV and Playwright: 323 MB total, 32-bit Python 3.8, 71 DLLs (93 MB).

| Component | Size | Share | Action |
|---|---|---|---|
| playwright | 76.7 MB | 24% | Remove if not needed |
| OpenCV | 62.4 MB | 19% | Use `opencv-python-headless` |
| PySide2 | 22.5 MB | 7% | Exclude WebEngine / 3D / Charts |
| Other | 161.4 MB | 50% | - |

Expected sizes:

| Project type | Nuitka raw | Optimized |
|---|---|---|
| Tkinter + stdlib | 150-250 MB | 80-120 MB |
| PyQt / PySide | 200-400 MB | 120-250 MB |
| With numpy / pandas | 300-600 MB | 180-350 MB |

## 32-bit vs 64-bit

32-bit builds are 20-30% smaller (for example `Qt5Core.dll` ~8 MB → ~5 MB, numpy ~30 MB → ~20 MB).

Use 32-bit when all are true:
- The app uses less than 2 GB of memory.
- The app does not process files larger than 2 GB.
- Target users have standard office PCs.

```bash
# 32-bit and 64-bit Python can be installed side by side
py -3.12-32 -m pip install -r requirements.txt
py -3.12-32 -m nuitka --standalone ...
```

## Module exclusions

Safe to exclude (not needed at runtime). Saves 30-50 MB:

```
unittest,test,pytest,_pytest,doctest,pdb,pdbpp,
setuptools,pip,distutils,pkg_resources,
email.mime,http.server,xmlrpc,pydoc
```

## Nuitka commands

### Tkinter (lightest)

```bash
nuitka --standalone --windows-console-mode=disable ^
    --lto=yes ^
    --jobs=8 ^
    --enable-plugin=tk-inter ^
    --enable-plugin=anti-bloat ^
    --noinclude-pytest-mode=nofollow ^
    --noinclude-setuptools-mode=nofollow ^
    --nofollow-import-to=unittest,test,pytest,_pytest,doctest,pdb,pdbpp ^
    --nofollow-import-to=setuptools,pip,distutils,pkg_resources ^
    --nofollow-import-to=email.mime,http.server,xmlrpc,pydoc ^
    --python-flag=no_docstrings ^
    --output-dir=dist ^
    --windows-icon-from-ico=icon.ico ^
    --remove-output ^
    main.py
```

Expected size: 80-120 MB.

### PyQt5 / PySide2

```bash
nuitka --standalone --windows-console-mode=disable ^
    --lto=yes ^
    --jobs=8 ^
    --enable-plugin=pyqt5 ^
    --enable-plugin=anti-bloat ^
    --noinclude-pytest-mode=nofollow ^
    --noinclude-setuptools-mode=nofollow ^
    --nofollow-import-to=unittest,test,pytest,_pytest,doctest,pdb ^
    --nofollow-import-to=setuptools,pip,distutils,pkg_resources ^
    --nofollow-import-to=PyQt5.QtWebEngine,PyQt5.QtWebEngineWidgets ^
    --nofollow-import-to=PyQt5.Qt3D,PyQt5.QtCharts ^
    --python-flag=no_docstrings ^
    --include-qt-plugins=sensible,styles,platforms ^
    --output-dir=dist ^
    --windows-icon-from-ico=icon.ico ^
    --remove-output ^
    main.py
```

Expected size: 120-250 MB.

## Build script (`build_optimized.bat`)

Save at the project root. Edit the three values at the top.

```batch
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set APP_NAME=YourApp
set MAIN_FILE=main.py
set ICON_FILE=icon.ico

REM Use the built-in variable. wmic is removed in Win11 22H2+, and a failed probe gives --jobs=0.
set CPU_CORES=%NUMBER_OF_PROCESSORS%
if not defined CPU_CORES set CPU_CORES=4
set /a BUILD_JOBS=%CPU_CORES%

set EXCLUDE_MODULES=unittest,test,pytest,_pytest,doctest,pdb,pdbpp
set EXCLUDE_MODULES=%EXCLUDE_MODULES%,setuptools,pip,distutils,pkg_resources
set EXCLUDE_MODULES=%EXCLUDE_MODULES%,email.mime,http.server,xmlrpc,pydoc

echo [1/4] Clean old build...
if exist dist rd /s /q dist
if exist build rd /s /q build

echo [2/4] Compile with Nuitka (%BUILD_JOBS% jobs)...
nuitka --standalone ^
    --windows-console-mode=disable ^
    --lto=yes ^
    --jobs=%BUILD_JOBS% ^
    --enable-plugin=anti-bloat ^
    --enable-plugin=tk-inter ^
    --noinclude-pytest-mode=nofollow ^
    --noinclude-setuptools-mode=nofollow ^
    --nofollow-import-to=%EXCLUDE_MODULES% ^
    --python-flag=no_docstrings ^
    --output-dir=dist ^
    --windows-icon-from-ico=%ICON_FILE% ^
    --remove-output ^
    %MAIN_FILE%

if %errorlevel% neq 0 (
    echo [ERROR] Build failed.
    exit /b 1
)

echo [3/4] Measure output...
for /f %%a in ('powershell -NoProfile -Command "(Get-ChildItem -LiteralPath 'dist\%APP_NAME%.dist' -Recurse -File | Measure-Object -Property Length -Sum).Sum"') do set TOTAL_SIZE=%%a
set /a SIZE_MB=%TOTAL_SIZE% / 1048576
echo - Size: %SIZE_MB% MB

echo [4/4] Slim dist...
powershell -ExecutionPolicy Bypass -File slim_dist.ps1 -DistPath "dist\%APP_NAME%.dist"
```

## Slim script (`slim_dist.ps1`)

Save next to `build_optimized.bat`. Saves 15-30%.

```powershell
param([Parameter(Mandatory)][string]$DistPath)

# Do not hide errors: a failed delete must show, so the result is not a false success.
$ErrorActionPreference = "Continue"

if (-not (Test-Path -LiteralPath $DistPath)) {
    Write-Host "[ERROR] Folder not found: $DistPath" -ForegroundColor Red
    exit 1
}

function Get-SizeMB($Path) {
    ((Get-ChildItem -LiteralPath $Path -Recurse -File | Measure-Object -Property Length -Sum).Sum) / 1MB
}

$initial = Get-SizeMB $DistPath

# Files: debug symbols, type stubs, bytecode
foreach ($pattern in "*.pdb", "*.pyi", "*.pyc") {
    $files = Get-ChildItem -LiteralPath $DistPath -Recurse -Include $pattern -File
    if ($files) {
        $mb = ($files | Measure-Object -Property Length -Sum).Sum / 1MB
        $files | Remove-Item -Force
        Write-Host ("{0}: removed {1} files, {2:N2} MB" -f $pattern, $files.Count, $mb)
    }
}

# Folders: caches, tests, docs, examples
$dirs = Get-ChildItem -LiteralPath $DistPath -Recurse -Directory |
    Where-Object { $_.Name -match '^(__pycache__|tests?|docs|examples|samples|demo)$' } |
    Sort-Object { $_.FullName.Length } -Descending
foreach ($dir in $dirs) {
    if (Test-Path -LiteralPath $dir.FullName) {
        Remove-Item -LiteralPath $dir.FullName -Recurse -Force
    }
}
Write-Host "Removed $($dirs.Count) cache/test/doc folders"

# .dist-info: remove only install-time records.
# Keep METADATA and entry_points.txt: importlib.metadata reads them at runtime (plugin discovery).
$count = 0
Get-ChildItem -LiteralPath $DistPath -Recurse -Directory -Filter "*.dist-info" | ForEach-Object {
    foreach ($name in "RECORD", "INSTALLER", "direct_url.json") {
        $f = Join-Path $_.FullName $name
        if (Test-Path -LiteralPath $f) { Remove-Item -LiteralPath $f -Force; $count++ }
    }
}
Write-Host "Removed $count .dist-info record files"

$final = Get-SizeMB $DistPath
$saved = $initial - $final
$pct = if ($initial -gt 0) { $saved / $initial * 100 } else { 0 }
Write-Host ("Initial {0:N2} MB -> final {1:N2} MB, saved {2:N2} MB ({3:N1}%)" -f $initial, $final, $saved, $pct)
```

## DLL analysis (`analyze_dlls.py`)

Lists the largest DLLs and gives a hint for each known type.

```python
import sys
from pathlib import Path

LARGE_BYTES = 3 * 1024 * 1024
HINTS = [
    (("openblas", "mkl"), "Math library (reference case: libopenblas 26.9 MB). Use a lighter build if you do not need fast linear algebra."),
    (("opencv", "ffmpeg"), "OpenCV (reference case: opencv_videoio_ffmpeg 18.5 MB). Use opencv-python-headless."),
    (("qt5", "qt6", "pyside"), "Qt library. Exclude unused modules (WebEngine, 3D, Charts)."),
    (("d3dcompiler",), "DirectX compiler (~3.5 MB)."),
    (("mfc140",), "MFC library (~4.9 MB)."),
]


def hint(name: str) -> str | None:
    if "opengl" in name and "sw" in name:
        return "Software OpenGL renderer (~15 MB). Usually safe to delete when hardware rendering is used."
    return next((msg for keys, msg in HINTS if any(k in name for k in keys)), None)


def analyze(dist_path: str) -> int:
    root = Path(dist_path)
    if not root.is_dir():
        print(f"[ERROR] Folder not found: {dist_path}", file=sys.stderr)
        return 1
    dlls = sorted(((p, p.stat().st_size) for p in root.rglob("*.dll")), key=lambda x: x[1], reverse=True)
    if not dlls:
        print("No DLL files found.")
        return 0

    total = sum(s for _, s in dlls)
    print(f"DLL count: {len(dlls)}, total: {total / 1048576:.2f} MB\n")

    for p, s in (d for d in dlls if d[1] > LARGE_BYTES):
        print(f"{s / 1048576:8.2f} MB  {p.name}  ({p.relative_to(root).parent})")
        if msg := hint(p.name.lower()):
            print(f"           {msg}")

    debug = [p.name for p, _ in dlls if p.stem.lower().endswith("d") and p.stem.lower()[:-1] in {q.stem.lower() for q, _ in dlls}]
    print("\nDebug DLLs (safe to delete): " + (", ".join(debug) if debug else "none"))

    vc = [p.name for p, _ in dlls if "vcruntime" in p.name.lower() or "msvcp" in p.name.lower()]
    if vc:
        print("VC++ runtime (required, keep): " + ", ".join(vc))

    print("\nTop 20:")
    for p, s in dlls[:20]:
        loc = str(p.relative_to(root).parent)
        print(f"{s / 1048576:10.2f}  {p.name:<30}  {'(root)' if loc == '.' else loc}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python analyze_dlls.py <dist folder>", file=sys.stderr)
        sys.exit(2)
    sys.exit(analyze(sys.argv[1]))
```

```bash
python analyze_dlls.py dist/YourApp.dist
```

## Act on the analysis

```bash
# OpenCV: switch to the headless build
pip uninstall opencv-python
pip install opencv-python-headless
```

```batch
REM Qt: add to the Nuitka command
--nofollow-import-to=PyQt5.QtWebEngine,PyQt5.Qt3D,PyQt5.QtCharts
```

```powershell
# Software renderer: delete only if the app does not need it (run in the dist folder)
Remove-Item "opengl32sw.dll" -Force
```

## VC++ runtime

Option 1, static link:

```bash
nuitka --static-libpython=yes ...
```

Option 2, bundle the redistributable (recommended for commercial releases). The redistributable architecture must match the Python/Nuitka build: `vc_redist.x86.exe` for 32-bit, `vc_redist.x64.exe` for 64-bit.

```iss
[Files]
Source: "{#MySourceDir}\..\vc_redist.x86.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Run]
Filename: "{tmp}\vc_redist.x86.exe"; Parameters: "/quiet /norestart"; StatusMsg: "Installing runtime..."; Flags: waituntilterminated
```

Download: [Microsoft Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist).

## Inno Setup template (6.x)

```iss
; Inno Setup 6.x: LZMA2 ultra compression, full metadata, clean uninstall

#define MyAppName        "{{APP_NAME}}"
#define MyAppVersion     "{{APP_VERSION}}"
#define MyAppPublisher   "{{PUBLISHER}}"
#define MyAppURL         "{{APP_URL}}"
#define MyAppExeName     "{{EXE_NAME}}"
#define MySourceDir      "{{SOURCE_DIR}}"
#define MyOutputDir      "{{OUTPUT_DIR}}"
;#define MyIconPath      "{{ICON_PATH}}"

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

; Set only for 64-bit Python builds. Keep commented for 32-bit builds,
; so the app installs as 32-bit and matches vc_redist.x86.exe.
;ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#MySourceDir}\*"; DestDir: "{app}"; Excludes: "_nuitka_temp.exe"; Flags: ignoreversion recursesubdirs createallsubdirs

[UninstallDelete]
Type: filesandordirs; Name: "{app}\*"

[Icons]
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent
```

For a localized wizard, add a `[Languages]` entry such as `Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"`.

| Placeholder | Meaning | Example |
|---|---|---|
| `{{APP_NAME}}` | Display name | `RedInk` |
| `{{APP_VERSION}}` | Version | `1.0.0` |
| `{{PUBLISHER}}` | Publisher | `MyCompany` |
| `{{APP_URL}}` | Website | `https://example.com` |
| `{{EXE_NAME}}` | Main executable | `RedInk.exe` |
| `{{SOURCE_DIR}}` | Nuitka `dist` folder | `D:\project\dist\RedInk.dist` |
| `{{OUTPUT_DIR}}` | Installer output folder | `D:\project\output` |
| `{{ICON_PATH}}` | Icon file | `D:\project\icon.ico` |
| `{{GENERATE_RANDOM_GUID}}` | A unique GUID | Inno Setup "Tools > Generate GUID" |

## Troubleshooting

| Problem | Fix |
|---|---|
| App does not start after install | Run the exe from `cmd` to see the error. Check the VC++ runtime. Check that the Nuitka build passed. |
| Missing `python3xx.dll` | Use `--standalone`. Make sure the DLL is in `dist`. Do not build a single file. |
| No response on click | Heavy imports block GUI startup. Import heavy modules when the feature is first used. Add logging. |
| Installer too large | 32-bit build, module exclusions, anti-bloat plugin, `slim_dist.ps1`, DLL analysis. |
| Nuitka + MinGW fails on a non-ASCII path | Copy the source to an ASCII-only path. Set `PYTHONIOENCODING=utf-8`. |
| Inno Setup warns `x64` is deprecated | Use `ArchitecturesInstallIn64BitMode=x64compatible` (64-bit builds only). |
| `--disable-console` is deprecated | Use `--windows-console-mode=disable`. |
| `_nuitka_temp.exe` in `dist` | Exclude it in `[Files]` (template does this). |
| Antivirus false positive | Submit to vendors for allowlisting. Sign the code (Sectigo, DigiCert). Do not use UPX. |
| "Windows protected your PC" | An EV code-signing certificate gives trust at once. A standard certificate gets trust as install count grows. |

## Expected results

| Change | Size reduction | Startup gain |
|---|---|---|
| `--lto=yes` | 5-10% | 10-20% |
| anti-bloat plugin | 15-25% | - |
| Module exclusions | 20-35% | 5% |
| `dist` slimming | 25-40% | - |
| 32-bit build | 40-60% | - |
| All combined | 45-65% | 15-25% |

Do not use UPX compression. It makes the installer smaller, but antivirus tools often flag UPX-packed files.
