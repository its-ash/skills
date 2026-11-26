@REF:playwright
§TRIG{real_browser_auto(nav|forms|screenshots|extract);E2E_flows;POM|fixtures|visual_reg;CI_shards+retries;Playwright>(Selenium|Cypress|Puppeteer)}
§CMD{
  note:cmds_from_project_root;adjust_if_layout_differs;
  detect_srv:`node -e "require('./lib/helpers').detectDevServers().then(s=>console.log(JSON.stringify(s)))"` (1⇒use_URL;>1⇒ask_user);
  install:`npm i -D @playwright/test && npx playwright install --with-deps`;
  ci_install:`npx playwright install --with-deps chromium`;
  visual:`npx playwright test visual.spec.ts`;
  flake:`npx playwright test tests/search.spec.ts --repeat-each=10` | `--retries=3`;
  shard:`npx playwright test --shard=${{ matrix.shard }}`
}
§DIR{e2e/{.auth/(git-ignored storageState),fixtures.ts,pages/{login-page.ts,dashboard-page.ts},auth.setup.ts,*.spec.ts,playwright.config.ts}}
§CFG{
  `playwright.config.ts`:
  ```ts
  import { defineConfig, devices } from '@playwright/test';
  export default defineConfig({
    testDir:'./e2e', fullyParallel:true, forbidOnly:!!process.env.CI,
    retries:process.env.CI?2:0, workers:process.env.CI?1:undefined,
    reporter:process.env.CI?[['html',{open:'never'}],['github']]:[['html',{open:'on-failure'}]],
    use:{baseURL:process.env.BASE_URL||'http://localhost:3000',trace:'on-first-retry',screenshot:'only-on-failure',video:'on-first-retry'},
    projects:[
      {name:'setup',testMatch:/.*\.setup\.ts/},
      {name:'chromium',use:{...devices['Desktop Chrome'],storageState:'e2e/.auth/user.json'},dependencies:['setup']},
      {name:'firefox',use:{...devices['Desktop Firefox'],storageState:'e2e/.auth/user.json'},dependencies:['setup']},
      {name:'mobile',use:{...devices['iPhone 14'],storageState:'e2e/.auth/user.json'},dependencies:['setup']},
    ],
    webServer:{command:'npm run dev',url:'http://localhost:3000',reuseExistingServer:!process.env.CI,timeout:120_000},
  });
  ```
  artifacts:also_`video:'retain-on-failure'`;add_`junit`∧`json`_reporters_next_to_`html`_for_CI_parsing
}
§PAT{
  auth_setup(`e2e/auth.setup.ts`):`test as setup`→`goto('/login')`→fill(`TEST_USER_EMAIL!`,`TEST_USER_PASSWORD!`)via`getByLabel`→`getByRole('button',{name:'Sign in'}).click()`→`waitForURL('/dashboard')`→`expect(getByRole('navigation')).toBeVisible()`→`page.context().storageState({path:'e2e/.auth/user.json'})`;
  POM(`e2e/pages/login-page.ts`):class_holds`Page`+`Locator`s(`getByLabel`,`getByRole('button',{name:'Sign in'})`,`getByRole('alert')`),`goto()`,`login(email,pw)`,`expectError(msg)`(`waitForSelector('.alert')`+`toContainText(msg)`);
  fixtures(`e2e/fixtures.ts`):`ApiClient(baseURL,token?)`{`createResource(data)`:`POST /api/resources`+`Bearer`+throw_if_`!res.ok`;`deleteResource(id)`:`DELETE /api/resources/${id}`};`export const test=base.extend<Fixtures>({loginPage,dashboardPage,api})`+`export {expect}`;
  visual(`e2e/visual.spec.ts`):`await page.goto('/dashboard');await page.waitForLoadState('networkidle');await expect(page).toHaveScreenshot('dashboard.png',{maxDiffPixelRatio:0.01});`;
  screenshots:`page.screenshot({path:'artifacts/full-page.png',fullPage:true})` | `page.locator('[data-testid="chart"]').screenshot({path:'artifacts/chart.png'})`;
  quarantine:`test.fixme(true,'Flaky - Issue #123')` | `test.skip(!!process.env.CI,'Flaky in CI - Issue #124')`
}
§ANTI{
  race:`page.click(sel)`⇒`page.locator(sel).click()`(auto-wait);
  net:`page.waitForTimeout(5000)`⇒`page.waitForResponse(r=>r.url().includes('/api/data'))`;
  anim:click_mid_transition⇒`locator.waitFor({state:'visible'})`→click;
  selectors:¬brittle_CSS/XPath⇒`getByRole`,`getByLabel`,`text=`
}
§CI{
  GHA(`ubuntu-latest`,matrix.shard:`[1/4,2/4,3/4,4/4]`):`actions/checkout@v4`→`actions/setup-node@v4`(node-version:20,cache:npm)→`npm ci`→`npx playwright install --with-deps chromium`→`npx playwright test --shard=${{ matrix.shard }}`(env:`BASE_URL=http://localhost:3000`,`TEST_USER_EMAIL/PASSWORD` from `secrets`)→`actions/upload-artifact@v4`(`if:${{ !cancelled() }}`,name:`playwright-report-${{ strategy.job-index }}`,path:`playwright-report/`,retention-days:14)
}
§SCRIPTS{
  responsive:`chromium.launch({headless:false,slowMo:100})`;`TARGET_URL=process.env.TARGET_URL||'http://localhost:3000'`;vp∈{Desktop:1920x1080,Tablet:768x1024,Mobile:375x667}→`setViewportSize`→`goto`→`waitForLoadState('networkidle')`→`screenshot({path,fullPage:true})`;
  login:`fill('input[name="email"]',...)`→`fill('input[name="password"]',...)`→`click('button[type="submit"]')`→`waitForURL('**/dashboard')`;
  broken_links:`for(const l of await page.locator('a[href^="http"]').all()){const h=await l.getAttribute('href');const r=await page.request.head(h);r.ok()?ok++:broken.push({url:h,status:r.status()})}`
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
  detect_dev_srv;install_once;cfg(retries,traces,workers);auth(setup+storageState);user_locators;auto_wait(¬waitForTimeout);isolate(reset_context);artifacts_on_fail;param(BASE_URL|TARGET_URL);CI_shard+upload;`toHaveScreenshot`+low_maxDiffPixelRatio;fix_flaky(`waitForSelector`,`waitForURL`,locators);¬destructive_prod
}
§REL{
  [`web-vulnerability-testing`](../../secure-coding/references/web-vulnerability-testing.md):OWASP_vuln;
  [`web-performance`](../../web-quality-audit/references/web-performance.md):CWV_perf;
  [`web-accessibility`](../../web-quality-audit/references/web-accessibility.md):WCAG_2.1_POUR_ARIA;
  [`typescript`](../../typescript/SKILL.md):TS_monorepo;
  [`web-scraping-apis`](../../web-scraping-apis/SKILL.md):Firecrawl_Tavily_CF_Xquik;
  [`performance`](../../web-quality-audit/references/performance.md):Chrome_DevTools_CWV
}
