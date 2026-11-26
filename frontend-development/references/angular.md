@REF:angular
§SCOPE{Angular:code_gen∧arch;detail_files:`angular/`(read_only_needed)}
§WHEN{any_angular_proj∨scaffold(app|lib)∨gen(c|s|d|p|guard|resolver)∨signals(`signal`|`linkedSignal`|`resource`)∨forms(signal|reactive|template)∨DI∨routing(lazy|guards)∨aria|animations|styling∨tests(unit|harness|e2e)∨tooling(CLI|MCP)}
§R{
1:analyze(pkg_angular_ver)⊕(`ng new`⇒¬pin_ver_unless_req);
2:follow(angular_style_guide)∧scaffold_via(`ng`CLI:c|s|d|p|routes);
3:post_gen⇒ALWAYS(`ng build`)→fix_errs(¬skip)
}
§NEW{
def:{ver:latest_stable;forms:SignalForms⇔target_ver_supports→[signal-forms.md](angular/signal-forms.md)};
ng_new:{1:user_ver_req⇒`npx @angular/cli@<requested_version> new <project-name>`(bypass_local);2:¬user_ver_req∧`ng version`_ok⇒`ng new <project-name>`;3:¬user_ver_req∧`ng version`_fail⇒`npx @angular/cli@latest new <project-name>`}
}
§MAP{
cmp(https://angular.dev/guide/components):{anatomy,metadata,@if,@for,@switch→[components.md](angular/components.md);signal_inputs,transforms,model→[inputs.md](angular/inputs.md);signal_outputs,events→[outputs.md](angular/outputs.md);host_bindings,attr_inj→[host-elements.md](angular/host-elements.md)};
rx:{`signal`,`computed`,reactive_ctx,`untracked`→[signals-overview.md](angular/signals-overview.md);`linkedSignal`→[linked-signal.md](angular/linked-signal.md);`resource`→[resource.md](angular/resource.md);`effect`,`afterRenderEffect`,DOM,log,¬when→[effects.md](angular/effects.md)};
forms(new∧supported⇒prefer_signal;legacy∨existing⇒match_proj):{signal→[signal-forms.md](angular/signal-forms.md);template(simple)→[template-driven-forms.md](angular/template-driven-forms.md);reactive(complex)→[reactive-forms.md](angular/reactive-forms.md)};
di:{DI,services,`inject()`→[di-fundamentals.md](angular/di-fundamentals.md);`providedIn:'root'`,inject_targets→[creating-services.md](angular/creating-services.md);auto|manual,`InjectionToken`,`useClass|useValue|useFactory`,scopes→[defining-providers.md](angular/defining-providers.md);allowed_sites,`runInInjectionContext`,`assertInInjectionContext`→[injection-context.md](angular/injection-context.md);`EnvironmentInjector` vs `ElementInjector`,resolution,`optional`,`skipSelf`,`providers` vs `viewProviders`→[hierarchical-injectors.md](angular/hierarchical-injectors.md)};
aria(headless:Accordion|Listbox|Combobox|Menu|Tabs|Toolbar|Tree|Grid,ARIA_css)→[angular-aria.md](angular/angular-aria.md);
routing(https://angular.dev/guide/routing):{paths,static|dynamic,wildcard,redirect→[define-routes.md](angular/define-routes.md);eager,lazy,context→[loading-strategies.md](angular/loading-strategies.md);`<router-outlet>`,nested,named→[show-routes-with-outlets.md](angular/show-routes-with-outlets.md);`RouterLink`,`Router`→[navigate-to-routes.md](angular/navigate-to-routes.md);`CanActivate`,`CanMatch`,sec→[route-guards.md](angular/route-guards.md);`ResolveFn`→[data-resolvers.md](angular/data-resolvers.md);nav_events,debug→[router-lifecycle.md](angular/router-lifecycle.md);CSR,SSG/prerender,SSR+hydration→[rendering-strategies.md](angular/rendering-strategies.md);ViewTransitionsAPI→[route-animations.md](angular/route-animations.md)};
style_anim:{tailwind→[tailwind-css.md](angular/tailwind-css.md);native_CSS_rec|legacy_DSL→[angular-animations.md](angular/angular-animations.md);styles,encapsulation→[component-styling.md](angular/component-styling.md)};
testing:{unit,async,`TestBed`→[testing-fundamentals.md](angular/testing-fundamentals.md);harnesses→[component-harnesses.md](angular/component-harnesses.md);`RouterTestingHarness`→[router-testing.md](angular/router-testing.md);E2E(Cypress|Playwright)→[e2e-testing.md](angular/e2e-testing.md)};
tooling:{CLI(create,gen,serve,build)→[cli.md](angular/cli.md);MCP(tools,cfg,exp)→[mcp.md](angular/mcp.md)}
}
§ANTI{
init_signal_form(`null`|`undefined`)⇒use(`''`|`0`|`[]`);
`form.field.valid()`⇒call_field:`form.field().valid()`;
new_form_old_API⇔target_supports_signal_forms;
HTML_attrs(`min`,`max`,`value`,`disabled`,`readonly`)_on(`[formField]`)⇒schema_rules;
`inject()`_outside_ctx⇒`runInInjectionContext`;
`effect()`_for_derived⇒`computed()`;
`$parent.$index`_in_nested_`@for`(unsupported)⇒`let outerIdx = $index`
}
§REL{[unit-testing-patterns](../../unit-testing-patterns/SKILL.md):TDD;[secure-coding](../../secure-coding/SKILL.md):sec;[frontend-development](../SKILL.md):React/Next.js}
