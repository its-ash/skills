@REF:html-slides
§REL{../SKILL.md:§10+§5.B;html-slides/style-presets.md:CSS/presets/moods/gotchas;html-slides/html-template.md:HTML;html-slides/viewport-base.css:CSS_base;html-slides/animation-patterns.md:motion;motion-react.md:React;../../unit-testing-patterns/references/playwright.md:QA;pptx:PPTX_out}
§WHEN{zero-dep browser HTML deck(scratch|.ppt/.pptx|enhance)|style_previews;deps_ok⇒reveal.js5|Slidev}
§R{
  1_ZERO_DEP:1_HTML(inline CSS+JS);`assets/` only imgs|WOFF2(`font-display:swap`;net font⇔user accepts);
  2_FIT_GATE:∀`.slide`⇒`height:100dvh;overflow:hidden;`,0_scroll,type+space via `clamp()`;overflow⇒split(¬shrink<readable);
  3_SHOW:visual previews,¬abstract Qs;
  4_DISTINCT:¬generic purple gradients,¬Inter-on-white,¬templates(`../SKILL.md` §10);
  5_A11Y:commented,semantic(`main`,`section`,`nav`),AA contrast,kbd nav,`prefers-reduced-motion`,fast;
  PRE_GEN:read `style-presets.md`
}
§FLOW{
  1_MODE:New|PPT_convert|Enhance;
  2_CONTENT:ask min(purpose:pitch|teaching|talk|internal_update;len:short 5-10|med 10-20|long 20+;state:final|notes|topic);get content pre-style;
  3_STYLE:named preset⇒use;else mood(impressed|energized|focused|inspired)→`style-presets.md`→3 self-contained previews in temp dir(`slide-previews/`,<~100L/slide,type+color+motion)→pick/mix;
  4_BUILD:`presentation.html`|<name>.html(`html-template.md`+`viewport-base.css`+`animation-patterns.md`):`main`/`section`/`nav`,CSS vars+`color-scheme`+`light-dark()`(dark),JS ctrl(kbd+touch/swipe+wheel+progress/idx+reveal-on-enter),motion(`animation-timeline:view()`|`IntersectionObserver`,`@starting-style`,§5.B),strong type+abstract shapes/grids/noise/geometry(¬illustrations);
  5_QA:1920x1080,1280x720,768x1024,375x667,667x375(browser auto:0_overflow+kbd);
  6_DELIVER:rm temp previews(unless kept);open(`open`|`xdg-open`|`start ""` `file.html`);report path,preset,count,CSS vars
}
§PPTX{
  `python3`+`python-pptx`(cross-platform,¬macOS-only;ask pre `pip install python-pptx`|manual);keep order,notes,`assets/`,then §FLOW.3;
  ```python
  import json,sys;from pathlib import Path
  from pptx import Presentation;from pptx.enum.shapes import MSO_SHAPE_TYPE
  def extract(p:str,out:str=".")->list[dict]:
   a=Path(out,"assets");a.mkdir(parents=True,exist_ok=True);res=[]
   for n,s in enumerate(Presentation(p).slides,1):
    d={"number":n,"title":"","content":[],"images":[],"notes":""}
    for sh in s.shapes:
     if sh.has_text_frame and (t:=sh.text_frame.text.strip()):
      if sh==s.shapes.title: d["title"]=t
      else: d["content"].append(t)
     if sh.shape_type==MSO_SHAPE_TYPE.PICTURE:
      nm=f"slide{n}_{sh.shape_id}.{sh.image.ext}"
      (a/nm).write_bytes(sh.image.blob);d["images"].append(f"assets/{nm}")
    if s.has_notes_slide: d["notes"]=s.notes_slide.notes_text_frame.text.strip()
    res.append(d)
   return res
  if __name__=="__main__":
   if len(sys.argv)<2: sys.exit("usage: extract_pptx.py <input.pptx> [output_dir]")
   print(json.dumps(extract(sys.argv[1],sys.argv[2] if len(sys.argv)>2 else "."),indent=2))
  ```
}
§LIMITS{title:1h+1sub+opt_tag;content:1h+(4-6_bullets|2_short_p);grid:≤6_cards;code:8-10L;quote:1q+attr;img:1(fit)}
§ANTI{¬startup gradients;¬system-font(unless editorial);¬bullet walls;¬scrolling code;¬fixed-height boxes on short screens;¬`-clamp(...)`⇒`calc(-1 * clamp(...))`}
§CHK{runs_local;0_scroll;distinctive;purposeful_motion;reduced_motion;handoff_paths+vars}
