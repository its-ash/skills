@REF:windows-desktop-e2e
§SCOPE{pywinauto(backend="uia")+Windows_UIA;targets:WPF,WinForms,Win32/MFC,Qt5.x/6.x}
§USE{win_native_GUI_E2E;suite_setup;flaky_debug;testability(AutomationId,accessible_names);CI(windows-latest)}
§SKIP{web⇒[playwright](../../unit-testing-patterns/references/playwright.md);Electron|CEF|WebView2⇒browser_automation(HTML_layer,¬UIA);mobile⇒UIAutomator|XCUITest;headless_unit/int⇒¬GUI}

§CORE{
  stack:test(Py)→pywinauto(UIA)→Windows_UIA_API→App_UIA_provider→.exe;
  uia:{WPF:5/5,Exc,"x:Name→AutomationId";WinForms:4/5,Good,"AccessibleName=AutomationId";UWP|WinUI3:5/5,Exc,"full_MS";Qt6.x:5/5,Exc,"a11y_on_default;cls=Qt6*";Qt5.15+:4/5,Good,"improved_a11y";Qt5.7-5.14:3/5,Fair,"req QT_ACCESSIBILITY=1;manual objectName";Win32|MFC:3/5,Fair,"rc_IDs;text_match"}
}

§SETUP{
  req:Python>=3.8∧Win;cli:`pip install pywinauto pytest pytest-html Pillow pytest-timeout`;
  opt_rec:ffmpeg∈PATH(https://ffmpeg.org/download.html);
  verify:`from pywinauto import Desktop; Desktop(backend="uia").windows()`;
  inspector:"Accessibility Insights for Windows"(MS,free)
}

§TESTABILITY{
  R:∀interactive_ctrl⇒stable AutomationId pre-test;
  WPF:`<TextBox x:Name="usernameInput"/><PasswordBox x:Name="passwordInput"/><Button x:Name="btnLogin" Content="Login"/><TextBlock x:Name="lblError"/>`;
  WinForms:`ctrl.AccessibleName="usernameInput"`(designer∨code);
  Win32_MFC:`// .rc ID→AutomationId str(IDC_EDIT_USERNAME→"1001"); SetWindowText→Name; +IAccessible`;
  Qt⇒§QT
}

§POM{
  tree:"tests/{conftest.py,pytest.ini,config.py,pages/{__init__.py,base_page.py,login_page.py,main_page.py},tests/{__init__.py,test_login.py,test_main_flow.py},artifacts/}";
  loc_prio:AutomationId(by_id)>Name(by_name)>ClassName+index(by_class,fragile)>XPath(last_resort);
  repl:`win.print_control_identifiers()`;`win.child_window(auto_id="groupBox1").print_control_identifiers()`;
  config_env:{APP_PATH:"",APP_TITLE:"→MAIN_WINDOW_TITLE",LAUNCH_TIMEOUT:15,ACTION_TIMEOUT:10,ARTIFACT_DIR:"<dir>/artifacts"};
  pytest_ini:`[pytest]\ntestpaths = tests\nmarkers =\n    smoke: fast smoke\n    flaky: known-unstable\naddopts = -v --tb=short --html=artifacts/report.html --self-contained-html`;
  LoginPage(BasePage):props{username:"usernameInput",password:"passwordInput",btn_login:"btnLogin",error_label:"lblError"}|login(u,p)|login_ok(u,p,main_title="Main Window")→wait_window|login_fail(u,p)→wait_visible(error_label)→get_text
}

```python
# base_page.py (core POM API + Qt5 keyboard fallback)
import os, sys, time, pywinauto.keyboard as kb
from pywinauto import Desktop
from config import ACTION_TIMEOUT, ARTIFACT_DIR
class BasePage:
    def __init__(self, w): self.window = w
    def by_id(self, id, **kw): return self.window.child_window(auto_id=id, **kw)
    def by_name(self, n, **kw): return self.window.child_window(title=n, **kw)
    def by_class(self, c, index=0, **kw): return self.window.child_window(class_name=c, found_index=index, **kw)
    def wait_visible(self, s, timeout=ACTION_TIMEOUT): s.wait("visible", timeout=timeout); return s
    def wait_gone(self, s, timeout=ACTION_TIMEOUT): s.wait_not("visible", timeout=timeout); return s
    def wait_window(self, t, timeout=ACTION_TIMEOUT):
        d = Desktop(backend="uia").window(title=t); d.wait("visible", timeout=timeout); return d
    def wait_until(self, fn, timeout=ACTION_TIMEOUT, interval=0.3):
        dl = time.time() + timeout
        while time.time() < dl:
            try:
                if fn(): return True
            except Exception: pass
            time.sleep(interval)
        raise TimeoutError(f"Condition not met within {timeout}s")
    def click(self, s): self.wait_visible(s); s.click_input()
    def type_text(self, s, text):
        self.wait_visible(s); c = s.wrapper_object()
        try: c.set_edit_text(text)
        except Exception as e:  # Qt 5.x ValuePattern incomplete
            print(f"[windows-desktop-e2e] set_edit_text failed ({e}), using keyboard fallback", file=sys.stderr)
            c.click_input(); kb.send_keys("^a"); kb.send_keys(text, with_spaces=True)
    def get_text(self, s):
        c = s.wrapper_object()
        for a in ("window_text", "get_value"):
            try:
                if v := getattr(c, a)(): return v
            except Exception: pass
        return ""
    def screenshot(self, name):
        os.makedirs(ARTIFACT_DIR, exist_ok=True); p = os.path.join(ARTIFACT_DIR, f"{name}.png")
        self.window.capture_as_image().save(p); return p
```

§ISOLATION{
  legacy_conftest:"Application(backend='uia').start(APP_PATH,timeout=LAUNCH_TIMEOUT); teardown: win.close()+proc.wait_for_process_exit(timeout=5) (NOT wait_for_process()) else proc.kill(); prefer Tier1";
  T1:"tmp_path env redirect"|FS|zero_cost|CI:always|"DEFAULT ∀tests";
  T2:"Job Object"|proc_tree|low_cost|CI:always|"prevent child escape; ¬FS_virt∧¬net_block(req AppContainer/Firewall/T3)";
  T3:"Windows Sandbox"|full_OS|med_cost|CI:Pro/Enterprise|"nightly clean-room; same session req; Win10/11 Pro/Ent+Virt";
  hang_guard:"pytest-timeout: timeout=60, timeout_method=thread in pytest.ini; thread ¬kills Qt subprocs on Win⇒`atexit.register(lambda:[p.kill() for p in psutil.Process().children(recursive=True)])` in conftest.py"
}

```python
# conftest.py — Tier 1 FS Sandbox
import os, shlex, subprocess, pytest
from pywinauto import Application
from config import APP_PATH, APP_ARGS, APP_TITLE, LAUNCH_TIMEOUT, ARTIFACT_DIR
@pytest.fixture(scope="function")
def app(request, tmp_path):
    if not APP_PATH: pytest.exit("APP_PATH not set", returncode=1)
    if not APP_TITLE: pytest.exit("APP_TITLE environment variable is not set", returncode=1)
    env = os.environ.copy(); env["QT_ACCESSIBILITY"] = "1"
    env["APPDATA"], env["LOCALAPPDATA"] = str(tmp_path/"AppData"/"Roaming"), str(tmp_path/"AppData"/"Local")
    env["TEMP"] = env["TMP"] = str(tmp_path/"Temp")
    for p in (env["APPDATA"], env["LOCALAPPDATA"], env["TEMP"]): os.makedirs(p, exist_ok=True)
    proc = subprocess.Popen([APP_PATH] + shlex.split(APP_ARGS), env=env)
    win = Application(backend="uia").connect(process=proc.pid, timeout=LAUNCH_TIMEOUT).window(title=APP_TITLE)
    win.wait("visible", timeout=LAUNCH_TIMEOUT); yield win
    if getattr(getattr(request.node, "rep_call", None), "failed", False):
        os.makedirs(ARTIFACT_DIR, exist_ok=True)
        try: win.capture_as_image().save(os.path.join(ARTIFACT_DIR, f"FAIL_{request.node.name}.png"))
        except Exception: pass
    try: win.close(); proc.wait(timeout=5)
    except Exception: proc.kill()
@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call): o = yield; setattr(item, f"rep_{o.get_result().when}", o.get_result())
```

```python
# Tier 2 Job Object: job = restrict_process(proc.pid) after Popen; keep job alive (GC kills proc)
import ctypes, ctypes.wintypes as wt
def restrict_process(pid: int):
    k = ctypes.windll.kernel32; job = k.CreateJobObjectW(None, None)
    hp = k.OpenProcess(0x0101, False, pid)  # SET_QUOTA(0x0100)|TERMINATE(0x0001)
    class JOBOBJECT_BASIC_LIMIT_INFORMATION(ctypes.Structure):  # LimitFlags at +16, not +44
        _fields_ = [("PerProcessUserTimeLimit", wt.LARGE_INTEGER), ("PerJobUserTimeLimit", wt.LARGE_INTEGER),
            ("LimitFlags", wt.DWORD), ("MinimumWorkingSetSize", ctypes.c_size_t), ("MaximumWorkingSetSize", ctypes.c_size_t),
            ("ActiveProcessLimit", wt.DWORD), ("Affinity", ctypes.c_size_t), ("PriorityClass", wt.DWORD), ("SchedulingClass", wt.DWORD)]
    i = JOBOBJECT_BASIC_LIMIT_INFORMATION(); i.LimitFlags = 0x00002000  # KILL_ON_JOB_CLOSE
    if not k.SetInformationJobObject(job, 2, ctypes.byref(i), ctypes.sizeof(i)): raise ctypes.WinError()
    k.AssignProcessToJobObject(job, hp); k.CloseHandle(hp); return job
```

```xml
<!-- Tier 3: e2e-sandbox.wsb | https://learn.microsoft.com/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview | WindowsSandbox.exe e2e-sandbox.wsb -->
<Configuration><MappedFolders>
  <MappedFolder><HostFolder>C:\path\to\your\build\Release</HostFolder><SandboxFolder>C:\app</SandboxFolder><ReadOnly>true</ReadOnly></MappedFolder>
  <MappedFolder><HostFolder>C:\path\to\your\e2e_test</HostFolder><SandboxFolder>C:\e2e_test</SandboxFolder><ReadOnly>false</ReadOnly></MappedFolder>
</MappedFolders><LogonCommand><Command>powershell -Command "winget install --id Python.Python.3.11 --silent --accept-package-agreements; $env:PATH += ';' + $env:LOCALAPPDATA + '\Programs\Python\Python311\Scripts'; cd C:\e2e_test; pip install -r requirements.txt; pytest tests\ -v"</Command></LogonCommand></Configuration>
```

§ARTIFACTS{
  shot:`page.screenshot("after_login")`;
  fullscreen_minimized:`import pyautogui; pyautogui.screenshot("artifacts/fullscreen.png")`;
  ffmpeg_rec:`p=Popen(["ffmpeg","-f","gdigrab","-framerate","10","-i","desktop","-y",f"artifacts/videos/{name}.mp4"],stdin=PIPE,stdout=DEVNULL,stderr=DEVNULL)`→stop:`p.stdin.write(b"q");p.stdin.flush();p.wait(timeout=10)`
}

§TRACE{
  mode:opt_in(default=OFF);cli:`E2E_TRACE=1 pytest tests/test_login.py -v`;`E2E_TRACE=1 E2E_TRACE_INCLUDE_TEXT=1 pytest ...`;
  impl:BasePage._step+=1→save `step_{idx:03d}_{action}.png`(swallow err)→append `artifacts/trace.jsonl` `{ts,step,action,locator:getattr(spec,"criteria",None),text:text if TRACE_INCLUDE_TEXT else ("<redacted>" if text else None)}`;wrap `click`(`click_before`/`click_after`)∧`type_text`(`type_before`/`type_after`);
  caveats:{PII:"¬E2E_TRACE_INCLUDE_TEXT=1 on login/payment";overhead:"50-200ms/action+1 PNG/step⇒¬default CI matrix, flake-repro only";bloat:"tens of MB⇒tune retention-days";rerun:"class counter+append⇒clear artifact dir pre-rerun∧per-worker dirs";gap:"raw pywinauto outside BasePage untraced"}
}

§FLAKE{
  quarantine:`@pytest.mark.skip(reason="Flaky: ... Issue #42")`;
  ci_skip:`@pytest.mark.skipif(os.environ.get("CI")=="true", reason="...")`;
  fixes:{not_ready⇒wait_visible(¬sleep);unfocused⇒`win.set_focus()`;anim⇒`wait_until(lambda: not loading_indicator.exists())`;dialog⇒`wait_window(title,timeout=15)`;ci_disp⇒`DISPLAY`∨virtual_desktop;NotImplementedError_edit⇒Qt5_ValuePattern_missing⇒`keyboard.send_keys`_fallback;wait_visible_timeout_exists⇒minimised/offscreen⇒`win.restore()`+`win.set_focus()`}
}

§CI{
  file:".github/workflows/e2e-desktop.yml";
  cfg:"runs-on: windows-latest (real GUI, ¬Xvfb); checkout@v4; setup-python@v5(3.11); pip install pywinauto pytest pytest-html Pillow; cmake --build build --config Release; env{APP_PATH:${{github.workspace}}\\build\\Release\\MyApp.exe, APP_TITLE:'My Application', CI:'true'}; pytest tests/ --html=artifacts/report.html --self-contained-html --junitxml=artifacts/results.xml -v; upload-artifact@v4(if:always(), name:e2e-artifacts, path:artifacts/, retention-days:14)"
}

§QT{
  uia_5x:`os.environ["QT_ACCESSIBILITY"]="1"` pre-launch(conftest∨CI;Qt6 default_on⇒skip);
  ids_cpp:`w->setObjectName(id); w->setAccessibleName(id);`(→UIA Name);`test_ids.h`:`#define TID_*`;
  QComboBox:`page.click(combo_spec); p=Desktop(backend="uia").window(class_name_re="Qt[56]QWindowIcon"); p.wait("visible",timeout=5); p.child_window(title=item_text).click_input()`(`Qt5QWindowIcon`|`Qt6QWindowIcon`,verify A11y Insights);
  QMessageBox|QDialog:`d=page.wait_window("Confirm"); d.child_window(title="OK").click_input()`;
  QTable:`t=page.by_id("tblUsers").wrapper_object(); t.cell(row=0,column=1).window_text()`;
  self_drawn:"paintEvent-only, QGraphicsView, QOpenGLWidget⇒UIA blind⇒§SCREENSHOT"
}

§SCREENSHOT{
  cli:`pip install pyautogui Pillow opencv-python`;
  dpi:{1:"capture at target scale; ¬PIL.Image.resize(cv2.matchTemplate fragile)";2:"pin CI: Set-DisplayResolution 1920 1080 -Force + disable per-monitor DPI scaling";3:"record GetDpiForWindow(hwnd)/96 in artifacts/<test>/metadata.json";warn:"SetProcessDpiAwarenessContext conflicts w/ Qt DPI⇒prefer same-scale+CI pin"};
  use:"sparingly(DPI/theme/occlusion); UIA first";
  api:`find_image_on_screen(tpl,confidence=0.85)`:cv2 RGB2BGR+`cv2.matchTemplate(...,cv2.TM_CCOEFF_NORMED)`+`minMaxLoc`→`(ml[0]+w//2,ml[1]+h//2)` if `mv>=confidence` else `None`;`click_image`:raises `RuntimeError` if `None` else `pyautogui.click(*pos)`;
  diag:`debug_match(tpl,out="artifacts/match_debug.png",confidence=0.85)`(diagnosis-only,¬test):`cv2.imread(tpl)`(raise `RuntimeError` if `None`),`TM_CCOEFF_NORMED`,box `(0,255,0)` if pass else `(0,0,255)`,text `f"score={mv:.3f} thr={confidence}"`(`FONT_HERSHEY_SIMPLEX`,0.7,2),`cv2.imwrite`,return `mv`
}

§ANTI{"time.sleep(3)"⇒wait_visible/wait_until;"by_class('Edit',index=2)"⇒by_id("usernameInput");"pixel coords(left==120)"⇒state/text(get_text,is_enabled);"scope='session' app"⇒scope='function'(∨class)}
§CMD{all:`pytest tests/ -v`;smoke:`pytest tests/ -m smoke -v`;file:`pytest tests/test_login.py -v`;env:`APP_PATH="C:\build\Release\MyApp.exe" APP_TITLE="MyApp" pytest tests/ -v`;flake:`pip install pytest-repeat && pytest tests/test_login.py --count=5 -v`}
§REL{../../unit-testing-patterns/references/playwright.md:"web E2E";../../cpp/references/cpp-testing.md:"C++ GoogleTest";../../cpp/SKILL.md:"C++ style"}
