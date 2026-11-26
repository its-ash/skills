@REF:component-harnesses
§WHY{
  preferred_test_API(unit∧E2E_reusable);
  robust(immune_to_DOM/CSS_refactors);
  readable(user_API:`button.click()`,`slider.getValue()` vs `fixture.nativeElement.querySelector(...)`);
  angular_material:provides_harness_per_component
}
§API{
  entry:`TestbedHarnessEnvironment.loader(fixture)`←`@angular/cdk/testing/testbed`⇒`HarnessLoader`;
  find:`await loader.getHarness(HarnessClass)`(async,first_match);
  filter:`HarnessClass.with({...})`⇒`HarnessPredicate`(text,selector,disabled,etc.);
  interact:harness_methods(`.isDisabled()`,`.click()`,`.getText()`,`.getValue()`)→async∧auto_handle(async_ops+change_detection)
}
§EX{
  ```ts
  import { TestbedHarnessEnvironment } from '@angular/cdk/testing/testbed';
  import { MatButtonHarness } from '@angular/material/button/testing';
  // setup: fixture = TestBed.createComponent(Cmp); loader = TestbedHarnessEnvironment.loader(fixture);
  const btn = await loader.getHarness(MatButtonHarness.with({ text: 'Submit' }));
  expect(await btn.isDisabled()).toBe(false);
  await btn.click();
  ```
}
