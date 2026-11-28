@REF:testing-fundamentals

§R{
  runner:Vitest+jsdom_default(v22+,Node_exec,Jest-compat_`describe`/`it`/`expect`,replaces_deprecated_Karma/Jasmine);else_use_configured_workspace_runner;
  async_first(signals+zoneless+OnPush_CD_schedule_async);
  pattern:Act(set_input/click)→Wait(`await fixture.whenStable()`)→Assert;
  initial_binding_also_needs`await fixture.whenStable()`
}
§API{
  `@angular/core/testing`:`TestBed`,`ComponentFixture`;
  `await TestBed.configureTestingModule({imports:[MyComponent]}).compileComponents()`;
  `fixture=TestBed.createComponent(MyComponent)`;
  `fixture.componentInstance`|`fixture.nativeElement`|`fixture.debugElement`(platform_agnostic:`debugElement.query(By.css('p'))`)
}
§PAT{
```ts
describe('MyComponent', () => {
  let cmp: MyComponent, fix: ComponentFixture<MyComponent>, h1: HTMLElement;
  beforeEach(async () => {
    await TestBed.configureTestingModule({imports: [MyComponent]}).compileComponents();
    fix = TestBed.createComponent(MyComponent);
    cmp = fix.componentInstance;
    h1 = fix.nativeElement.querySelector('h1');
  });
  it('updates title', async () => {
    await fix.whenStable();
    expect(h1.textContent).toContain('Default Title');
    cmp.title.set('New Test Title');
    await fix.whenStable();
    expect(h1.textContent).toContain('New Test Title');
  });
});
```
}
