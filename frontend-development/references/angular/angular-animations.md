@REF:angular-animations
§VER_SEL{
  1:check(`package.json`→angular_ver);
  v≥20.2⇒native_CSS(`animate.enter`,`animate.leave`);
  v<20.2∨heavy_legacy_use⇒deprecated_DSL(`@angular/animations`);
  ¬mix(legacy_DSL ∧ `animate.enter`/`animate.leave`)_in_same_cmp
}
§NATIVE_CSS{
  `animate.enter="cls"`:applies_cls→auto_removes_on_end(note:transitions_vs_@keyframes⇒require_initial_style);
  `animate.leave="cls"`:valid_on_removed_child_els∧waits_anim_end_before_DOM_remove;
  events:`(animate.enter)`|`(animate.leave)`→JS_libs(GSAP);
  ```html
  @if (isShown()) { <div animate.enter="enter-animation" (animate.leave)="onLeave($event)">...</div> }
  ```
  ```ts
  import { AnimationCallbackEvent } from '@angular/core';
  onLeave(e: AnimationCallbackEvent) { /* anim */ e.animationComplete(); } // MUST call so Angular removes DOM node
  ```
}
§ADV_CSS{
  state_toggle:`[class.open]="isOpen"`+`transition:height 0.3s ease-out`;
  auto_height_grid:`.c{display:grid;grid-template-rows:0fr;transition:grid-template-rows 0.3s} .c.open{grid-template-rows:1fr} .c>div{overflow:hidden}`;
  stagger:`animation-delay`∨`transition-delay`_per_item;
  parallel:`animation: rotate 3s, fade-in 2s;`;
  programmatic:`element.getAnimations().forEach(a => a.pause())`
}
§LEGACY_DSL{
  deprecated:true;
  setup:`bootstrapApplication(App, { providers: [provideAnimationsAsync()] })`;
  ```ts
  import { trigger, state, style, animate, transition } from '@angular/animations';
  @Component({
    animations: [trigger('openClose', [
      state('open', style({ opacity: 1 })), state('closed', style({ opacity: 0 })),
      transition('open <=> closed', [animate('0.5s')])
    ])],
    template: `<div [@openClose]="isOpen() ? 'open' : 'closed'">...</div>`
  })
  ```
}
