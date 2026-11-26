@REF:react-testing
§SCOPE{RTL+Vitest/Jest+MSW+axe;react_components,hooks,pages}
§USE{new_tests|legacy_cov|migrate(Enzyme/class→RTL)|setup(Vitest/Jest)|mock_HTTP|a11y_assert|lane_split(RTL|PlaywrightCT|E2E)}
§R{
  user_centric:test(visible_UI∧user_action∧observable_effects(cb,req))¬impl_details;
  ¬inspect:{state,child_props,hook_calls,render_count,non_user_DOM};¬mock:React|framework_hooks;
  runner_1:pick_1(Vitest|Jest|PlaywrightCT|CypressCT);¬mix(RTL+Vitest,PlaywrightCT)∨explicit_lane_split;
  query_prio:1[getByRole,getByLabelText,getByPlaceholderText,getByText,getByDisplayValue]>2[getByAltText,getByTitle]>3[getByTestId];
  query_var:{getBy*:throws_0,queryBy*:null(assert_absent),findBy*:Promise(async)};
  userEvent:setup_once_per_test(const user=userEvent.setup())∧always(await)∧prefer(userEvent>fireEvent);
  async:¬setTimeout;use(findBy*|waitFor|waitForElementToBeRemoved);
  msw:network_layer_mock∧onUnhandledRequest:"error"(fail_loudly);
  providers:wrap_once(test-utils.tsx→renderWithProviders)∧QueryClient({defaultOptions:{queries:{retry:false}}});
  hooks:renderHook+act(state_Δ)∧public_API_only∧wrapper(QueryClient_OUTSIDE_wrapper_closure⇒survives_rerender);
  a11y:axe(container)∈every_interactive_comp_test;JSDOM_contrast=inline_only⇒visual_contrast∈Playwright;
  snapshots:¬rendered_DOM(fragile,impl_detail,rubber_stamped);ok[pure_serialization(formatInvoice),gen_cfg];visual_diff⇒Playwright|Cypress|Percy|Chromatic;
  boundary:{hook|presentational|logic_form⇒RTL,layout|non_JSDOM_API(flex/grid/viewport/anim/scroll/dnd/clipboard/iframe/popup/download/xorigin/devtools)⇒PlaywrightCT,multi_page_flow⇒E2E};
  tdd:RED→GREEN→REFACTOR→REPEAT;new_comp:[1:props_sig,2:simplest_fail,3:verify_fail_reason,4:min_pass,5:next_case,6:refactor@3rd_similar]
}
§RUNNERS{
  Vitest:Vite/Remix/modern(fast,ESM,Jest_API);
  Jest:Next.js/CRA/legacy_default;
  PlaywrightCT:real_browser_when_JSDOM_lacks;
  CypressCT:real_browser_if_Cypress_in_repo
}
§PAT{
  queries:`screen.getByRole("button",{name:/save/i})`;`screen.getByLabelText("Email")`;`screen.getByTestId("save-btn")`;
  userEvent:`const user=userEvent.setup();await user.type(screen.getByLabelText("Email"),"user@example.com");await user.click(screen.getByRole("button",{name:/save/i}));`;
  async:`expect(await screen.findByText("Loaded")).toBeInTheDocument()`;`await waitFor(()=>expect(saveSpy).toHaveBeenCalled())`;`await waitForElementToBeRemoved(()=>screen.queryByText("Loading"))`;
  msw_setup:`import{setupServer}from"msw/node";import{http,HttpResponse}from"msw";const server=setupServer(http.get("/api/users/:id",({params})=>HttpResponse.json({id:params.id,name:"Alice"})),http.post("/api/users",async({request})=>HttpResponse.json({id:"new-id",...(await request.json())},{status:201})));beforeAll(()=>server.listen({onUnhandledRequest:"error"}));afterEach(()=>server.resetHandlers());afterAll(()=>server.close());`;
  msw_override:`server.use(http.get("/api/users/:id",()=>new HttpResponse(null,{status:500})));`;
  test_utils:`export function renderWithProviders(ui:React.ReactElement,options?:RenderOptions){const qc=new QueryClient({defaultOptions:{queries:{retry:false}}});return render(<QueryClientProvider client={qc}><ThemeProvider theme={lightTheme}><MemoryRouter>{ui}</MemoryRouter></ThemeProvider></QueryClientProvider>,options);}export * from "@testing-library/react";`;
  hook:`const{result}=renderHook(()=>useCounter(0));act(()=>result.current.increment());`;
  hook_rq:`const qc=new QueryClient({defaultOptions:{queries:{retry:false}}});const wrapper=({children}:{children:React.ReactNode})=><QueryClientProvider client={qc}>{children}</QueryClientProvider>;const{result}=renderHook(()=>useUser("1"),{wrapper});await waitFor(()=>expect(result.current.isSuccess).toBe(true));`;
  axe:`import{axe,toHaveNoViolations}from"jest-axe";expect.extend(toHaveNoViolations);const{container}=render(<UserCard user={mockUser}/>);expect(await axe(container)).toHaveNoViolations();`;
  err_boundary:`const spy=vi.spyOn(console,"error").mockImplementation(()=>{});try{render(<ErrorBoundary fallback={<div>Something went wrong</div>}><Broken/></ErrorBoundary>);expect(screen.getByText("Something went wrong")).toBeInTheDocument();}finally{spy.mockRestore();}`;
  suspense:`renderWithProviders(<Suspense fallback={<div>Loading...</div>}><UserDetail id="1"/></Suspense>);expect(screen.getByText("Loading...")).toBeInTheDocument();expect(await screen.findByText("Alice")).toBeInTheDocument();`
}
§COV{
  targets:{pure_util:≥90%,custom_hook:≥85%,presentational:≥80%(behavior¬lines),container:≥70%(golden+err),page:E2E+smoke_min};
  vitest_cfg:`test:{coverage:{provider:"v8",reporter:["text","html","lcov"],thresholds:{lines:80,functions:80,branches:70,statements:80}}}`
}
§ANTI{
  container.querySelector(bypasses_a11y);assert_render_count(impl);jest.mock("react")(refactor_instead);
  mock_child_default(only_if_heavy_side_effects);ignore_act_warnings(unmount_update|missing_async);
  shared_mutable_state(order_flake);passes_without_it.skip(false_assert)
}
§CMD{
  vitest:watch(`vitest`),run(`vitest run`),cov(`vitest run --coverage`),file(`vitest run path/to/file.test.tsx`),ci(`CI=true vitest run --coverage`);
  jest:watch(`jest --watch`),cov(`jest --coverage`),file(`jest path/to/file.test.tsx`)
}
§REL{
  ../../frontend-development/SKILL.md:React_patterns;
  ../../web-quality-audit/references/web-accessibility.md:full_a11y_playbook;
  playwright.md:PlaywrightCT+E2E;
  test-driven-development.md:TDD_cycle
}
