@REF:router-testing
§R{
¬mock(Router|services)⇒USE(RouterTestingHarness+provideRouter)[tests_cfg,guards,resolvers];
setup:TestBed.configureTestingModule({providers:[provideRouter([...])]}).compileComponents()→await_RouterTestingHarness.create()[inits+navs_/];
nav:await_h.navigateByUrl(url,Cmp)⇒Cmp_instance;
wait:nav_action⇒ALWAYS_await_h.fixture.whenStable()_before_assert;
inspect:h.router.url|await_h.getHarness(Cmp).componentInstance|h.routeDebugElement(DebugElement)
}
§PAT{
```ts
import{TestBed}from'@angular/core/testing';
import{provideRouter}from'@angular/router';
import{RouterTestingHarness}from'@angular/router/testing';
let h:RouterTestingHarness;
beforeEach(async()=>{
  await TestBed.configureTestingModule({providers:[provideRouter([{path:'',component:Dashboard},{path:'heroes/:id',component:HeroDetail}])]}).compileComponents();
  h=await RouterTestingHarness.create();
});
it('nav',async()=>{
  const d=await h.navigateByUrl('/',Dashboard);
  d.selectHero({id:42,name:'Test Hero'});
  await h.fixture.whenStable();
  expect(h.router.url).toEqual('/heroes/42');
  const hd=await h.getHarness(HeroDetail);
  expect(await hd.componentInstance.hero.name).toBe('Test Hero');
});
```
}
