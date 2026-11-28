@REF:playwright
§VER{Playwright:1.65.x(Node22/24/26,Node20_dropped);axe:`@axe-core/playwright`4.x;GHA:`checkout@v7`,`setup-node@v7`,`upload-artifact@v7`}
§TRIG{real_browser_auto(nav|forms|screenshots|extract);E2E_flows;POM|fixtures|ARIA_snapshots|visual_reg|page.clock;CI_shards+blob_merge;MCP_Test_Agents;Playwright>(Selenium|Cypress|Puppeteer)}
§CMD{
  detect_srv:`lsof -iTCP -sTCP:LISTEN -P -n`(reuse_or_configure_`webServer`∈`playwright.config.ts`);
  install:`npm i -D @playwright/test && npx playwright install --with-deps`;
  ci_install:`npx playwright install --with-deps chromium`;
  run:`npx playwright test` | `--only-failures` | `--bun` | `--update-snapshots`;
  flake:`npx playwright test tests/search.spec.ts --repeat-each=10` | `--retries=3`;
  shard:`npx playwright test --shard=${{ matrix.shard }}`;
  merge:`npx playwright merge-reports --reporter=html ./all-blob-reports`
}
§DIR{e2e/{.auth/(git-ignored storageState),fixtures.ts,pages/{login-page.ts,dashboard-page.ts},auth.setup.ts,*.spec.ts,playwright.config.ts}}
§CFG{
  `playwright.config.ts`:
  ```ts
  import { defineConfig, devices } from '@playwright/test';
  export default defineConfig({
    testDir:'./e2e', fullyParallel:true, forbidOnly:!!process.env.CI,
    retries:process.env.CI?2:0, workers:process.env.CI?1:undefined,
    reporter:process.env.CI?[['blob'],['github']]:[['html',{open:'on-failure'}]],
    use:{baseURL:process.env.BASE_URL||'http://localhost:3000',trace:'on-first-retry',screenshot:'only-on-failure',video:'retain-on-failure'},
    projects:[
      {name:'setup',testMatch:/.*\.setup\.ts/},
      {name:'chromium',use:{...devices['Desktop Chrome'],storageState:'e2e/.auth/user.json'},dependencies:['setup']},
      {name:'firefox',use:{...devices['Desktop Firefox'],storageState:'e2e/.auth/user.json'},dependencies:['setup']},
      {name:'mobile',use:{...devices['iPhone 15'],storageState:'e2e/.auth/user.json'},dependencies:['setup']},
    ],
    webServer:{command:'npm run dev',url:'http://localhost:3000',reuseExistingServer:!process.env.CI,timeout:120_000},
  });
  ```
  unsharded_CI:`[['html',{open:'never'}],['github']]`(+`junit`/`json`_if_parsed)
}
§PAT{
  auth_setup(`e2e/auth.setup.ts`):`test as setup`→`goto('/login')`→fill(`TEST_USER_EMAIL!`,`TEST_USER_PASSWORD!`)via`getByLabel`→`getByRole('button',{name:'Sign in'}).click()`→`waitForURL('/dashboard')`→`expect(getByRole('navigation')).toBeVisible()`→`page.context().storageState({path:'e2e/.auth/user.json'})`;
  POM(`e2e/pages/login-page.ts`):class_holds`Page`+`Locator`s(`getByLabel`,`getByRole('button',{name:'Sign in'})`,`getByRole('alert')`),`goto()`,`login(email,pw)`,`expectError(msg)`(`await expect(this.alert).toContainText(msg)`);
  fixtures(`e2e/fixtures.ts`):`ApiClient(baseURL,token?)`{`createResource(data)`:`POST /api/resources`+`Bearer`+throw_if_`!res.ok`;`deleteResource(id)`:`DELETE /api/resources/${id}`};`export const test=base.extend<Fixtures>({loginPage,dashboardPage,api})`+`export {expect}`;
  aria_snapshot:`await expect(page.getByRole('navigation')).toMatchAriaSnapshot(\`- navigation:\n  - link "Dashboard"\n  - link "Settings"\`)`(semantic_a11y_tree;update:`--update-snapshots`);
  visual(`e2e/visual.spec.ts`):`await page.goto('/dashboard');await expect(page.getByRole('heading',{name:'Dashboard'})).toBeVisible();await expect(page).toHaveScreenshot('dashboard.png',{maxDiffPixelRatio:0.01});`;
  clock:`await page.clock.install({time:new Date('2026-01-01T08:00:00Z')});await page.goto('/session');await page.clock.fastForward('1h');await expect(page.getByText('Expired')).toBeVisible();await page.clock.resume();`;
  a11y(`@axe-core/playwright`):`const res=await new AxeBuilder({page}).withTags(['wcag2a','wcag2aa','wcag22aa']).analyze();expect(res.violations).toEqual([]);`;
  screenshots:`page.screenshot({path:'artifacts/full-page.png',fullPage:true})` | `page.getByTestId('chart').screenshot({path:'artifacts/chart.png'})`;
  quarantine:`test.fixme(true,'Flaky - Issue #123')` | `test.skip(!!process.env.CI,'Flaky in CI - Issue #124')`
}
§AI{
  MCP:`@playwright/mcp`⇒LLM_browser_control_via_accessibility_tree_snapshots(fast,deterministic¬pixel_guessing);
  Test_Agents:built-in_chain[1:Planner(spec→test_plan),2:Generator(intent→semantic_TS_tests),3:Healer(broken_locator/state→patch)]
}
§ANTI{
  race:`page.click(sel)`∨`page.waitForSelector(sel)`⇒`locator`+web-first_`expect(loc).toBeVisible()`(auto-wait);
  net:`page.waitForTimeout(5000)`∨`page.waitForLoadState('networkidle')`(discouraged:polling/SSE_flake)⇒`waitForResponse(r=>r.url().includes('/api/data'))`∨web-first_locator;
  anim:click_mid_transition⇒web-first_actionability_checks∧`expect(loc).toBeVisible()`→click;
  selectors:¬brittle_CSS/XPath⇒`getByRole`,`getByLabel`,`getByPlaceholder`,`getByText`,`getByTestId`;
  timers:¬real_sleep_for_expiry⇒`page.clock`
}
§CI{
  GHA_shards(`ubuntu-latest`,matrix.shard:`[1/4,2/4,3/4,4/4]`):`actions/checkout@v7`→`actions/setup-node@v7`(node-version:24,cache:npm)→`npm ci`→`npx playwright install --with-deps chromium`→`npx playwright test --shard=${{ matrix.shard }}`(env:`BASE_URL=http://localhost:3000`,`TEST_USER_EMAIL/PASSWORD`∈`secrets`)→`actions/upload-artifact@v7`(`if:${{ !cancelled() }}`,name:`blob-report-${{ strategy.job-index }}`,path:`blob-report/`,retention-days:1);
  GHA_merge(`needs:[test]`,`if:${{ !cancelled() }}`):download_all_blob_artifacts→`./all-blob-reports`→`npx playwright merge-reports --reporter=html ./all-blob-reports`→`actions/upload-artifact@v7`(name:`playwright-report`,path:`playwright-report/`,retention-days:14)
}
§SCRIPTS{
  responsive:`chromium.launch({headless:false,slowMo:100})`;`TARGET_URL=process.env.TARGET_URL||'http://localhost:3000'`;vp∈{Desktop:1920x1080,Tablet:768x1024,Mobile:375x667}→`setViewportSize`→`goto`→`expect(page.locator('main')).toBeVisible()`→`screenshot({path,fullPage:true})`;
  login:`getByLabel('Email').fill(...)`→`getByLabel('Password').fill(...)`→`getByRole('button',{name:/sign in/i}).click()`→`waitForURL('**/dashboard')`;
  broken_links:`for(const l of await page.locator('a[href^="http"]').all()){const h=await l.getAttribute('href');if(!h)continue;const r=await page.request.head(h);r.ok()?ok++:broken.push({url:h,status:r.status()})}`
}
§WEB3{
  `context.addInitScript(()=>{(window as any).ethereum={isMetaMask:true,request:async({method}:{method:string})=>method==='eth_requestAccounts'?['0x1234567890123456789012345678901234567890']:method==='eth_chainId'?'0x1':undefined};})`
}
§CRIT{
  payments_trades:`test.skip(process.env.NODE_ENV==='production','Real money')`;wait_API_res+status_check(¬fixed_time);assert_preview_before_confirm;¬destructive_on_prod(dedicated_test_data)
}
§RPT{
  `# E2E Test Report` | Date,Duration,Status(`PASSING`/`FAILING`) | Summary(Total,Passed[%],Failed,Flaky,Skipped) | Failed(`file:line`,Error,Screenshot,Recommended fix) | Artifacts(`playwright-report/index.html`,`test-results/**/trace.zip`)
}
§CHK{
  detect_dev_srv∨`webServer`;install_once;cfg(retries,traces,workers,blob);auth(setup+storageState);user_locators;web-first_auto_wait(¬`waitForTimeout`¬`networkidle`¬`waitForSelector`);`page.clock`(time_deps);`toMatchAriaSnapshot`+`toHaveScreenshot`;`@axe-core/playwright`;isolate_context;CI_shard+`merge-reports`;¬destructive_prod
}
§REL{
  [`web-vulnerability-testing`](../../secure-coding/references/web-vulnerability-testing.md):OWASP_vuln;
  [`web-performance`](../../web-quality-audit/references/web-performance.md):CWV_perf;
  [`web-accessibility`](../../web-quality-audit/references/web-accessibility.md):WCAG_2.2_POUR_ARIA;
  [`typescript`](../../typescript/SKILL.md):TS_monorepo;
  [`web-scraping-apis`](../../web-scraping-apis/SKILL.md):Firecrawl_Tavily_CF_Xquik;
  [`performance`](../../web-quality-audit/references/performance.md):Chrome_DevTools_CWV
}
