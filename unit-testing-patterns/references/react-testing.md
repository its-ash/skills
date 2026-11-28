@REF:react-testing
§SCOPE{RTL16+React19+Vitest5(Node/Browser_Mode)/Jest30+MSW3+axe;react_components,hooks,pages}
§VER{
  React:19.x(`act`∈`'react'`);
  RTL:`@testing-library/react`16.x+`@testing-library/user-event`14.x;
  Vitest:5.1.x(Node≥22.12,Vite≥6.4,`clearMocks:true`_default,`.vitest/`_artifacts,`test.projects`,Browser_Mode+failure-only_Trace_View);
  Browser_Mode:`@vitest/browser-playwright`+`vitest-browser-react`(real_Chromium/Firefox/WebKit);
  Jest:30.x(Node≥18,`jsdom`26,TS≥5.4);
  MSW:3.x(ESM_only,Node≥22,TS≥5.9,TCP/TLS_intercept,subpath_imports,`onUnhandledFrame`);
  axe:`@chialab/vitest-axe`|`vitest-axe`(Vitest)⊕`jest-axe`11.x(Node≥22.13,Jest)⊕`@axe-core/playwright`4.x(real_browser)
}
§USE{new_tests|legacy_cov|migrate(Enzyme/class→RTL)|setup(Vitest5/Browser_Mode/Jest30)|mock_HTTP(MSW3)|a11y_assert|lane_split(RTL|Vitest_Browser|PlaywrightCT|E2E)}
§R{
  user_centric:test(visible_UI∧user_action∧observable_effects(cb,req))¬impl_details;
  ¬inspect:{state,child_props,hook_calls,render_count,non_user_DOM};¬mock:React|framework_hooks;
  runner_1:pick_1(Vitest5|Jest30);split_unit_vs_real_browser_via_Vitest_`test.projects`¬dueling_runners;
  query_prio:1[getByRole,getByLabelText,getByPlaceholderText,getByText,getByDisplayValue]>2[getByAltText,getByTitle]>3[getByTestId];
  query_var:{getBy*:throws_0,queryBy*:null(assert_absent),findBy*:Promise(async)};
  userEvent:setup_once_per_test(`const user=userEvent.setup()`)∧always(`await`)∧prefer(`userEvent`>`fireEvent`);
  async:¬`setTimeout`;use(`findBy*`|`waitFor`|`waitForElementToBeRemoved`|`expect.element`∈Browser_Mode);
  msw3:TCP/TLS_network_mock;subpath_imports(`msw/http`,`msw/graphql`,`msw/utils`);`onUnhandledFrame:"error"`(v2:`onUnhandledRequest`);cookies∈resolver_`{cookies}`(¬`request.headers.get("cookie")`⇒`null`);fake_timers⇒manually_advance_for_`delay()`;
  providers:wrap_once(`test-utils.tsx`→`renderWithProviders`)∧`QueryClient({defaultOptions:{queries:{retry:false}}})`;
  hooks:`renderHook`+`act`(from`'react'`)∧public_API_only∧`QueryClient`_OUTSIDE_wrapper_closure(survives_rerender);
  a11y:`axe(container)`∈every_interactive_comp_test;JSDOM_contrast=inline_only⇒real_contrast∈Vitest_Browser_Mode∨Playwright(`@axe-core/playwright`);
  snapshots:¬rendered_DOM(fragile,impl_detail);ok[pure_serialization,gen_cfg];UI_struct⇒`toMatchAriaSnapshot()`;visual_diff⇒Playwright|Vitest_Browser|Chromatic;
  boundary:{hook|presentational|logic_form⇒RTL(JSDOM/happy-dom),layout|CSS|non_JSDOM_API(flex/grid/viewport/anim/scroll/dnd/clipboard/iframe/popup/download)⇒Vitest_Browser_Mode(`vitest-browser-react`)⊕PlaywrightCT,multi_page_flow⇒Playwright_E2E};
  tdd:RED→GREEN→REFACTOR→REPEAT;new_comp:[1:props_sig,2:simplest_fail,3:verify_fail_reason,4:min_pass,5:next_case,6:refactor@3rd_similar]
}
§RUNNERS{
  Vitest5_Node:Vite/Next/Remix/modern_default(fast,ESM,`clearMocks:true`,Jest_API);
  Vitest5_Browser:real_browser_component_tests(`@vitest/browser-playwright`+`vitest-browser-react`,Trace_View_on_fail);
  Jest30:React_Native/legacy_default;
  PlaywrightCT:real_browser_comp_lane_when_¬Vitest;
  CypressCT:real_browser_if_Cypress_already_in_repo
}
§CFG{
  vitest_projects(`vitest.config.ts`):
  ```ts
  import { defineConfig } from "vitest/config";
  import { playwright } from "@vitest/browser-playwright";
  export default defineConfig({
    test: {
      projects: [
        { test: { name: "unit", environment: "jsdom", include: ["src/**/*.test.ts(x)?"], exclude: ["src/**/*.browser.test.tsx"] } },
        { test: { name: "browser", include: ["src/**/*.browser.test.tsx"], browser: { enabled: true, headless: true, provider: playwright(), instances: [{ browser: "chromium" }] } } },
      ],
      coverage: { provider: "v8", reporter: ["text", "html", "lcov"], thresholds: { lines: 80, functions: 80, branches: 70, statements: 80 } },
    },
  });
  ```
}
§PAT{
  queries:`screen.getByRole("button",{name:/save/i})`;`screen.getByLabelText("Email")`;`screen.getByTestId("save-btn")`;
  userEvent:`const user=userEvent.setup();await user.type(screen.getByLabelText("Email"),"user@example.com");await user.click(screen.getByRole("button",{name:/save/i}));`;
  browser_mode(`vitest-browser-react`):`import{render}from"vitest-browser-react";const screen=render(<Counter/>);await screen.getByRole("button",{name:"Increment"}).click();await expect.element(screen.getByText("Count: 1")).toBeInTheDocument();`;
  async:`expect(await screen.findByText("Loaded")).toBeInTheDocument()`;`await waitFor(()=>expect(saveSpy).toHaveBeenCalled())`;`await waitForElementToBeRemoved(()=>screen.queryByText("Loading"))`;
  msw3_setup:`import{setupServer}from"msw/node";import{http,HttpResponse}from"msw/http";const server=setupServer(http.get("/api/users/:id",({params,cookies})=>HttpResponse.json({id:params.id,name:"Alice",sid:cookies.sid??null})),http.post("/api/users",async({request})=>HttpResponse.json({id:"new-id",...(await request.json())},{status:201})));beforeAll(()=>server.listen({onUnhandledFrame:"error"}));afterEach(()=>server.resetHandlers());afterAll(()=>server.close());`;
  msw3_override:`server.use(http.get("/api/users/:id",()=>new HttpResponse(null,{status:500})));`;
  test_utils:`export function renderWithProviders(ui:React.ReactElement,options?:RenderOptions){const qc=new QueryClient({defaultOptions:{queries:{retry:false}}});return render(<QueryClientProvider client={qc}><ThemeProvider theme={lightTheme}><MemoryRouter>{ui}</MemoryRouter></ThemeProvider></QueryClientProvider>,options);}export * from "@testing-library/react";`;
  hook:`import{act}from"react";const{result}=renderHook(()=>useCounter(0));act(()=>result.current.increment());`;
  hook_rq:`const qc=new QueryClient({defaultOptions:{queries:{retry:false}}});const wrapper=({children}:{children:React.ReactNode})=><QueryClientProvider client={qc}>{children}</QueryClientProvider>;const{result}=renderHook(()=>useUser("1"),{wrapper});await waitFor(()=>expect(result.current.isSuccess).toBe(true));`;
  axe:`import{axe}from"vitest-axe";/*or jest-axe v11*/const{container}=render(<UserCard user={mockUser}/>);expect(await axe(container)).toHaveNoViolations();`;
  err_boundary:`const spy=vi.spyOn(console,"error").mockImplementation(()=>{});try{render(<ErrorBoundary fallback={<div>Something went wrong</div>}><Broken/></ErrorBoundary>);expect(screen.getByText("Something went wrong")).toBeInTheDocument();}finally{spy.mockRestore();}`;
  suspense:`renderWithProviders(<Suspense fallback={<div>Loading...</div>}><UserDetail id="1"/></Suspense>);expect(screen.getByText("Loading...")).toBeInTheDocument();expect(await screen.findByText("Alice")).toBeInTheDocument();`
}
§COV{
  targets:{pure_util:≥90%,custom_hook:≥85%,presentational:≥80%(behavior¬lines),container:≥70%(golden+err),page:E2E+smoke_min};
  artifacts:Vitest5_defaults_reports_to_`.vitest/`(update_CI_upload_paths)
}
§ANTI{
  `container.querySelector`(bypasses_a11y);assert_render_count(impl);`vi.mock("react")`/`jest.mock("react")`(refactor_instead);
  MSW3_root_import(`import{http}from"msw"`)|`onUnhandledRequest`|`request.headers.get("cookie")`(v3_breaking);
  `browser.name`/`providerOptions`(Vitest_legacy⇒use_`provider:playwright()`+`instances`);
  mock_child_default(only_if_heavy_side_effects);ignore_`act`_warnings(unmount_update|missing_async);
  shared_mutable_state(order_flake);passes_without_`it.skip`(false_assert)
}
§CMD{
  vitest:`npx vitest` | `npx vitest run` | `npx vitest run --project=browser` | `npx vitest run --coverage` | `CI=true npx vitest run --coverage`;
  jest:`npx jest --watch` | `npx jest --coverage` | `npx jest path/to/file.test.tsx`
}
§REL{
  ../../frontend-development/SKILL.md:React_patterns;
  ../../web-quality-audit/references/web-accessibility.md:full_a11y_playbook;
  playwright.md:PlaywrightCT+E2E;
  test-driven-development.md:TDD_cycle
}
