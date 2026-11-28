@REF:browser-qa
§TRIG{post_deploy(staging|preview)∨verify_UI∨pre_ship∨FE_PR∨a11y_resp_audit;tools:MCP(`@playwright/mcp`|`chrome-devtools-mcp`|Playwright_Test_Agents)|CLI([playwright.md](playwright.md)|Puppeteer)}
§SAFE{default:READ_ONLY;¬mutating(checkout|payment|delete|mass-update)_on_prod⇒req(explicit_opt_in∧staging/preview_URL);creds:seeded_test_ONLY∧¬prod_logins;screenshots:redact(creds|tokens|PII)_pre_save}
§PHASE{
  P1_Smoke:nav→URL;console_errs(filter:analytics,3p);net(¬4xx∧¬5xx);screenshot(above_fold,desktop+mobile);CWV(web.dev;INP_replaced_FID):LCP≤2.5s∧CLS≤0.1∧INP≤200ms;
  P2_Interact:click_all_nav(¬dead);forms(valid⇒ok∧invalid⇒err);auth(login→protected→logout;test_creds_only,¬prod);journeys(checkout|onboarding|search;read_only_def;mutating⇔staging∧opt_in);
  P3_Visual:screenshot(@[375px,768px,1440px]);ARIA_tree_diff(`toMatchAriaSnapshot`)+pixel_diff(∅_baseline⇒INCONCLUSIVE,¬silent_PASS);flag(shift>5px∨missing_el∨overflow);check(dark_mode?);
  P4_A11y:`@axe-core/playwright`4.x|`axe-core`(∀page,tags:`wcag2a,wcag2aa,wcag22aa`);flag(WCAG_2.2_AA:contrast,labels,focus_order,target_size);verify(E2E_kbd_nav);check(SR_landmarks);caveat:axe≈30-40%_WCAG⇒necessary¬sufficient⇒manual_req(kbd,focus,SR)∧¬claim_"accessible"_auto_alone
}
§OUT{
  tpl:`## QA Report — [URL] — [timestamp]`
  sections:Smoke(console_critical/warn,net_200/304,CWV[LCP,CLS,INP]);Interactions([✓|✗] nav,forms,auth);Visual([✓|✗] 375/768/1440_overflow/shift,ARIA_diff,dark_mode);Accessibility(WCAG_2.2_AA_count+violations+manual_kbd_SR);
  Verdict:SHIP|SHIP WITH FIXES|DO NOT SHIP (<n> issues,<n> blockers);INCONCLUSIVE⇔no_visual_baseline
}
§REL{[playwright.md](playwright.md):Playwright;[canary-watch](../../web-quality-audit/references/canary-watch.md):post_deploy_watch}
