@REF:ui-demo
§USE{
  ref:[unit-testing-patterns/references/playwright.md](../../unit-testing-patterns/references/playwright.md);
  when:demo_video|screen_recording|walkthrough|tutorial|visual_showcase|onboarding;
  flow:P1_Discover→P2_Rehearse→P3_Record(¬skip_to_P3)
}
§P1_DISCOVER{
  why:DOM≠assumptions(<input>≠<textarea>,custom_dd≠<select>,@mentions/#tags);
  probe:```js
await page.evaluate(()=>[...document.querySelectorAll('input,select,textarea,button,[contenteditable]')].filter(e=>e.offsetParent!==null).map(e=>({tag:e.tagName,type:e.type||'',name:e.name||'',ph:e.placeholder||'',txt:e.textContent?.trim().slice(0,40)||'',ce:e.contentEditable==='true',role:e.getAttribute('role')||''})))
```;
  chk:{
    fields:<select>|<input>|custom|combobox;
    select_opts:`Array.from(el.options).map(o=>({value:o.value,text:o.text}))`∧skip(text∋"Select"∨value==="0");
    rich:placeholder∈{@mentions,#tags,md,emoji};
    req:{required,"*",empty_submit→err};
    dyn:conditional_post_fill;
    btn:exact_text("Submit"|"Submit Request"|"Send");
    tbl_modal:map(`input[type="number"]`→col_hdr)
  };
  out:field_map(e.g.inline:`span.cursor-pointer→input`,Send_disabled_until_nonempty)
}
§P2_REHEARSE{
  flag:`--rehearse`(no_video);
  fn:```js
async function ensureVisible(page,loc,label){
  const el=typeof loc==='string'?page.locator(loc).first():loc;
  if(await el.isVisible().catch(()=>false)){console.log(`REHEARSAL OK: "${label}"`);return true;}
  const vis=await page.evaluate(()=>[...document.querySelectorAll('button,input,select,textarea,a')].filter(e=>e.offsetParent!==null).map(e=>`${e.tagName}[${e.type||''}] "${e.textContent?.trim().slice(0,30)}"`).join('\n'));
  console.error(`REHEARSAL FAIL: "${label}" ${loc}\n${vis}`);return false;
}
```;
  run:∀{label,selector}:!ensureVisible⇒allOk=false;!allOk⇒`process.exit(1)`;fix_from_dump→rerun_till_100%
}
§P3_RECORD{
  story:Entry(login/start)→Context(pan)→Action(core)→Variation(settings/theme/l10n)→Result(outcome);
  pace:{login:4s,nav:3s,click:2s,step:1.5-2s,final:3s,type:25-40ms/c};
  cursor:reinject_post_EVERY_nav;
  subtitle:reinject_post_nav;len<60c;fmt:`"Step N - Action"`;clear`''`_long_pauses;
  scroll:`window.scrollTo({top:400,behavior:'smooth'})`+1500ms;
  helpers:```js
async function injectCursor(page){await page.evaluate(()=>{if(document.getElementById('demo-cursor'))return;const c=Object.assign(document.createElement('div'),{id:'demo-cursor',innerHTML:'<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M5 3L19 12L12 13L9 20L5 3Z" fill="white" stroke="black" stroke-width="1.5" stroke-linejoin="round"/></svg>'});c.style.cssText='position:fixed;z-index:999999;pointer-events:none;width:24px;height:24px;transition:left 0.1s,top 0.1s;filter:drop-shadow(1px 1px 2px rgba(0,0,0,0.3));left:0;top:0';document.body.appendChild(c);document.addEventListener('mousemove',e=>{c.style.left=e.clientX+'px';c.style.top=e.clientY+'px';});});}
async function moveAndClick(page,loc,label,{postClickDelay=800,...opts}={}){const el=typeof loc==='string'?page.locator(loc).first():loc;if(!await el.isVisible().catch(()=>false)){console.error('SKIP:',label);return false;}try{await el.scrollIntoViewIfNeeded();await page.waitForTimeout(300);const b=await el.boundingBox();if(b){await page.mouse.move(b.x+b.width/2,b.y+b.height/2,{steps:10});await page.waitForTimeout(400);}await el.click(opts);}catch(e){console.error('FAIL:',label,e.message);return false;}await page.waitForTimeout(postClickDelay);return true;}
async function typeSlowly(page,loc,txt,label,delay=35){const el=typeof loc==='string'?page.locator(loc).first():loc;if(!await el.isVisible().catch(()=>false)){console.error('SKIP:',label);return false;}await moveAndClick(page,el,label);await el.fill('');await el.pressSequentially(txt,{delay});await page.waitForTimeout(500);return true;}
async function panElements(page,sel,max=6){const els=await page.locator(sel).all();for(let i=0;i<Math.min(els.length,max);i++){try{const b=await els[i].boundingBox();if(b&&b.y<700){await page.mouse.move(b.x+b.width/2,b.y+b.height/2,{steps:8});await page.waitForTimeout(600);}}catch(e){console.warn('PAN SKIP',i,sel,e.message);}}}
async function injectSubtitleBar(page){await page.evaluate(()=>{if(document.getElementById('demo-subtitle'))return;const b=Object.assign(document.createElement('div'),{id:'demo-subtitle'});b.style.cssText='position:fixed;bottom:0;left:0;right:0;z-index:999998;text-align:center;padding:12px 24px;background:rgba(0,0,0,0.75);color:#fff;font-family:-apple-system,"Segoe UI",sans-serif;font-size:16px;font-weight:500;letter-spacing:0.3px;transition:opacity 0.3s;pointer-events:none;opacity:0';document.body.appendChild(b);});}
async function showSubtitle(page,t){await page.evaluate(s=>{const b=document.getElementById('demo-subtitle');if(!b)return;if(s){b.textContent=s;b.style.opacity='1';}else b.style.opacity='0';},t);if(t)await page.waitForTimeout(800);}
```;
  runner:```js
// demo-script.cjs: QA_BASE_URL||'http://localhost:3000', VIDEO_DIR=__dirname/screenshots, OUTPUT_NAME='demo-FEATURE.webm'
const browser=await chromium.launch({headless:true});
// if --rehearse: newContext({viewport:{width:1280,height:720}}) -> ensureVisible loop -> browser.close()
const ctx=await browser.newContext({recordVideo:{dir:VIDEO_DIR,size:{width:1280,height:720}},viewport:{width:1280,height:720}});
// try: injectCursor+injectSubtitleBar after every page.goto, showSubtitle('Step N - ...'), moveAndClick, typeSlowly, panElements
// finally: await ctx.close(); fs.copyFileSync(await page.video().path(), path.join(VIDEO_DIR,OUTPUT_NAME)); await browser.close();
```;
  cli:`node demo-script.cjs --rehearse` | `node demo-script.cjs`
}
§CHK{✓P1∧✓P2_100%;✓headless:true∧1280x720;✓reinject_overlays_post_nav;✓showSubtitle('Step N - ...');✓moveAndClick(labeled)∧typeSlowly∧smooth_scroll∧¬silent_catch;✓pauses∧story_order∧UI_truth}
§ANTI{1:no_reinject⇒lost_cursor;2:no_pause⇒too_fast;3:dot⇒use_SVG_arrow;4:teleport⇒moveAndClick;5:abrupt_select⇒move+pick;6:abrupt_modal⇒read_pause;7:random_webm⇒copyFileSync_stable;8:silent_catch⇒log;9-10:assumed_UI⇒P1;11:fake_select("0"|"Select...")⇒skip;12:popups_split_video⇒capture_popup_pages∧merge}
