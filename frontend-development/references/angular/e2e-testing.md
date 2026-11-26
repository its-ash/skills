@REF:e2e-testing
§R{
  scope:critical_journeys(real_browser)∧workspace_fw(Cypress|Playwright);
  struct:{specs∈(cypress/e2e/|e2e/),helpers(login|setup)⇒fw_support_dir,fixtures:explicit∧small(clear_user_state)};
  serve_first⇒existing_scripts¬parallel_entrypoint;
  locators:getByRole|getByLabel|data-*¬(CSS_class∨DOM_depth∨incidental_text);
  wait:UI_state|route|network¬sleep;
  tests:smoke=short;full_workflow⇒highest_value_paths
}
§CMD{check(package.json,angular.json):npm run e2e|pnpm e2e|ng e2e}
§PAT{
  Cypress:cy.visit('/login')→cy.get('[data-cy=email]').type(e)→.click()→cy.url().should('include','/dashboard')
  Playwright(@playwright/test):page.goto('/login')→getByLabel('Email').fill(e)→getByRole('button',{name:'Sign in'}).click()→expect(page).toHaveURL(/dashboard/)
}
