# Playwright End‑to‑End Testing & Browser Automation

Create fast, reliable, and maintainable browser tests. The skill covers project setup, test architecture, authentication handling, visual regression, CI integration, and common automation scripts.

## When to use
- You need to automate a real browser (navigation, form filling, screenshots, data extraction).
- You are building or improving an E2E test suite for critical user flows.
- You want to apply the Page Object Model, custom fixtures, or visual regression.
- You need to run tests in CI/CD with parallel shards and retries.
- You prefer Playwright over Selenium, Cypress, or Puppeteer.

## Planning & Project Setup
1. **Detect running dev servers** – run the helper before writing tests:
   ```bash
   node -e "require('./lib/helpers').detectDevServers().then(s=>console.log(JSON.stringify(s)))"
   ```
   - If one server is found, use its URL.
   - If multiple, ask the user which to test.
2. **Install Playwright** (once per project):
   ```bash
   npm i -D @playwright/test
   npx playwright install --with-deps
   ```
3. **Create a basic config** (`playwright.config.ts`).

## Directory structure
```
e2e/
├─ .auth/               # storageState files (git‑ignored)
├─ fixtures.ts          # custom fixtures, API client
├─ pages/               # Page Object Model classes
│  ├─ login-page.ts
│  └─ dashboard-page.ts
├─ auth.setup.ts        # global login to generate storageState
├─ *.spec.ts            # test suites
└─ playwright.config.ts
```

## Playwright configuration (example)
```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: process.env.CI
    ? [['html', { open: 'never' }], ['github']]
    : [['html', { open: 'on-failure' }]],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },
  projects: [
    { name: 'setup', testMatch: /.*\.setup\.ts/ },
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], storageState: 'e2e/.auth/user.json' },
      dependencies: ['setup'],
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'], storageState: 'e2e/.auth/user.json' },
      dependencies: ['setup'],
    },
    {
      name: 'mobile',
      use: { ...devices['iPhone 14'], storageState: 'e2e/.auth/user.json' },
      dependencies: ['setup'],
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
```

## Authentication state persistence
Create a global setup test (`auth.setup.ts`) that logs in once and saves cookies:
```typescript
import { test as setup, expect } from '@playwright/test';
const authFile = 'e2e/.auth/user.json';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill(process.env.TEST_USER_EMAIL!);
  await page.getByLabel('Password').fill(process.env.TEST_USER_PASSWORD!);
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/dashboard');
  await expect(page.getByRole('navigation')).toBeVisible();
  await page.context().storageState({ path: authFile });
});
```
All other projects reference `storageState: 'e2e/.auth/user.json'`.

## Page Object Model (example)
```typescript
// e2e/pages/login-page.ts
import { type Page, type Locator } from '@playwright/test';

export class LoginPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(private page: Page) {
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() { await this.page.goto('/login'); }
  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
  async expectError(msg: string) {
    await this.page.waitForSelector('.alert');
    await this.errorMessage.toContainText(msg);
  }
}
```
Create similar classes for each major page.

## Custom fixtures & API client
```typescript
// e2e/fixtures.ts
import { test as base, expect } from '@playwright/test';
import { LoginPage } from './pages/login-page';
import { DashboardPage } from './pages/dashboard-page';

class ApiClient {
  constructor(private baseURL: string, private token?: string) {}
  async createResource(data: Record<string, unknown>) {
    const res = await fetch(`${this.baseURL}/api/resources`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...(this.token ? { Authorization: `Bearer ${this.token}` } : {}) },
      body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error(`Seed failed: ${res.status}`);
    return res.json();
  }
  async deleteResource(id: string) {
    await fetch(`${this.baseURL}/api/resources/${id}`, { method: 'DELETE' });
  }
}

type Fixtures = { loginPage: LoginPage; dashboardPage: DashboardPage; api: ApiClient };

export const test = base.extend<Fixtures>({
  loginPage: async ({ page }, use) => use(new LoginPage(page)),
  dashboardPage: async ({ page }, use) => use(new DashboardPage(page)),
  api: async ({ baseURL }, use) => use(new ApiClient(baseURL!)),
});
export { expect };
```

## Writing tests
- Use **user‑facing locators**: `getByRole`, `getByLabel`, `text=`.
- Rely on Playwright’s **auto‑wait**; avoid `page.waitForTimeout`.
- Add **retries** and **traces** in the config.
- Keep each test **isolated**; use the `setup` project for shared login.

### Example test suite
```typescript
// e2e/dashboard.spec.ts
import { test, expect } from './fixtures';

test.describe('Dashboard', () => {
  test('shows resource list', async ({ dashboardPage }) => {
    await dashboardPage.goto();
    await expect(dashboardPage.heading).toHaveText('Dashboard');
    await expect(dashboardPage.resourceList).toBeVisible();
  });

  test('creates a new resource', async ({ dashboardPage }) => {
    await dashboardPage.goto();
    await dashboardPage.createResource('New Item');
    await dashboardPage.expectResourceVisible('New Item');
  });
});
```

## Visual regression (optional)
```typescript
// e2e/visual.spec.ts
import { test, expect } from './fixtures';

test('dashboard matches snapshot', async ({ page }) => {
  await page.goto('/dashboard');
  await page.waitForLoadState('networkidle');
  await expect(page).toHaveScreenshot('dashboard.png', { maxDiffPixelRatio: 0.01 });
});
```
Run with `npx playwright test visual.spec.ts`.

## CI/CD integration (GitHub Actions example)
```yaml
name: E2E Tests
on: [push, pull_request]
jobs:
  e2e:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1/4, 2/4, 3/4, 4/4]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test --shard=${{ matrix.shard }}
        env:
          BASE_URL: http://localhost:3000
          TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
          TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}
      - uses: actions/upload-artifact@v4
        if: ${{ !cancelled() }}
        with:
          name: playwright-report-${{ strategy.job-index }}
          path: playwright-report/
          retention-days: 14
```
Adjust `shard` count to match available CI workers.

## Common automation scripts (stand‑alone Playwright code)
### Basic page test (multiple viewports)
```javascript
// /tmp/playwright-responsive.js
const { chromium } = require('playwright');
const TARGET_URL = process.env.TARGET_URL || 'http://localhost:3000';

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 100 });
  const page = await browser.newPage();
  const viewports = [
    { name: 'Desktop', width: 1920, height: 1080 },
    { name: 'Tablet', width: 768, height: 1024 },
    { name: 'Mobile', width: 375, height: 667 },
  ];
  for (const vp of viewports) {
    await page.setViewportSize({ width: vp.width, height: vp.height });
    await page.goto(TARGET_URL);
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: `/tmp/${vp.name.toLowerCase()}.png`, fullPage: true });
    console.log(`✅ ${vp.name} screenshot saved`);
  }
  await browser.close();
})();
```
### Login flow
```javascript
// /tmp/playwright-login.js
const { chromium } = require('playwright');
const TARGET_URL = process.env.TARGET_URL || 'http://localhost:3000';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  await page.goto(`${TARGET_URL}/login`);
  await page.fill('input[name="email"]', 'test@example.com');
  await page.fill('input[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  await page.waitForURL('**/dashboard');
  console.log('✅ Login successful');
  await browser.close();
})();
```
### Broken‑link checker
```javascript
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  await page.goto('http://localhost:3000');
  const links = await page.locator('a[href^="http"]').all();
  const results = { ok: 0, broken: [] };
  for (const link of links) {
    const href = await link.getAttribute('href');
    try {
      const resp = await page.request.head(href);
      if (resp.ok()) results.ok++; else results.broken.push({ url: href, status: resp.status() });
    } catch (e) {
      results.broken.push({ url: href, error: e.message });
    }
  }
  console.log(`✅ Working: ${results.ok}, Broken: ${results.broken.length}`);
  console.dir(results.broken);
  await browser.close();
})();
```

## Flaky test patterns
### Find flakiness
```bash
npx playwright test tests/search.spec.ts --repeat-each=10
npx playwright test tests/search.spec.ts --retries=3
```

### Quarantine with a tracked issue
```typescript
test('complex search', async ({ page }) => {
  test.fixme(true, 'Flaky - Issue #123');
});

test('upload flow', async ({ page }) => {
  test.skip(!!process.env.CI, 'Flaky in CI - Issue #124');
});
```

### Common causes and fixes
| Cause | Bad | Good |
|-------|-----|------|
| Race condition | `page.click(sel)` on an element that is not ready | `page.locator(sel).click()` (auto‑wait) |
| Network timing | `page.waitForTimeout(5000)` | `page.waitForResponse(r => r.url().includes('/api/data'))` |
| Animation | Click during a transition | `locator.waitFor({ state: 'visible' })`, then click |

## Artifacts
```typescript
await page.screenshot({ path: 'artifacts/full-page.png', fullPage: true });
await page.locator('[data-testid="chart"]').screenshot({ path: 'artifacts/chart.png' });
```
In `playwright.config.ts`, set `trace: 'on-first-retry'`, `screenshot: 'only-on-failure'`, and `video: 'retain-on-failure'`. Add `junit` and `json` reporters next to `html` when CI must parse results.

## Test report template
```markdown
# E2E Test Report
**Date:** YYYY-MM-DD HH:MM | **Duration:** Xm Ys | **Status:** PASSING / FAILING

## Summary
- Total: X | Passed: Y (Z%) | Failed: A | Flaky: B | Skipped: C

## Failed tests
### test-name
**File:** `tests/e2e/feature.spec.ts:45`
**Error:** Expected element to be visible
**Screenshot:** artifacts/failed.png
**Recommended fix:** ...

## Artifacts
- HTML report: playwright-report/index.html
- Traces: test-results/**/trace.zip
```

## Web3 wallet mock
```typescript
test('wallet connection', async ({ page, context }) => {
  await context.addInitScript(() => {
    (window as any).ethereum = {
      isMetaMask: true,
      request: async ({ method }: { method: string }) => {
        if (method === 'eth_requestAccounts') return ['0x1234567890123456789012345678901234567890'];
        if (method === 'eth_chainId') return '0x1';
      },
    };
  });
  await page.goto('/');
  await page.getByTestId('connect-wallet').click();
  await expect(page.getByTestId('wallet-address')).toContainText('0x1234');
});
```

## Critical flows (payments, trades)
- Skip tests that move real money on production: `test.skip(process.env.NODE_ENV === 'production', 'Real money')`.
- Wait for the specific API response with a status check, not for a fixed time.
- Assert the preview values before you confirm the action.

## Best‑practice checklist
- [ ] Detect dev server(s) before writing scripts.
- [ ] Install Playwright and required browsers once.
- [ ] Use a stable `playwright.config.ts` with retries, traces, and parallel workers.
- [ ] Store authentication state with `storageState` and a dedicated `setup` project.
- [ ] Write selectors using `getByRole`, `getByLabel`, `text=` – avoid brittle CSS/XPath.
- [ ] Rely on Playwright auto‑wait; remove `waitForTimeout` calls.
- [ ] Keep each test isolated; reset context between tests.
- [ ] Capture screenshots, videos, and traces on failure.
- [ ] Parameterize URLs via `process.env.BASE_URL` or a `TARGET_URL` constant.
- [ ] Run tests in CI with sharding and artifact upload.
- [ ] For visual regression, use `expect(page).toHaveScreenshot()` with a low `maxDiffPixelRatio`.
- [ ] Review flaky tests: add explicit waits (`waitForSelector`, `waitForURL`) or improve selectors.
- [ ] Never run destructive actions against production; use dedicated test data.

---
*All commands assume you are in the project root. Adjust paths if your layout differs.*

## Related skills

Load these when the task spans more than this skill.

- [`web-vulnerability-testing`](../../secure-coding/references/web-vulnerability-testing.md) — Test web applications for OWASP-aligned vulnerabilities across injection, authentication, access control, API,…
- [`web-performance`](../../web-quality-audit/references/web-performance.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`web-accessibility`](../../web-quality-audit/references/web-accessibility.md) — Provides concise guidance for auditing and fixing web accessibility to meet WCAG 2.1 (POUR) and ARIA standards…
- [`typescript`](../../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`web-scraping-apis`](../../web-scraping-apis/SKILL.md) — Unified guide for using web‑scraping APIs (Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik) to extr…
- [`performance`](../../web-quality-audit/references/performance.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
