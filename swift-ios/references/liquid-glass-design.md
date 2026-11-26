@REF:liquid-glass-design
§CTX{iOS26+:LiquidGlass(dynamic_material:blur_behind+reflect_color/light+touch/pointer_react);scope:{SwiftUI,UIKit,WidgetKit}}
§PAT{
  swiftui:{
    basic:.glassEffect() // default:.regular,in:.capsule;
    custom:.glassEffect(.regular.tint(.orange).interactive(),in:.rect(cornerRadius:16.0));
    opts:{variant:.regular,tint:.tint(Color),react:.interactive(),shape:.capsule|.rect(cornerRadius:)|.circle};
    btn:.buttonStyle(.glass)⊕.buttonStyle(.glassProminent);
    container:GlassEffectContainer(spacing:40.0){...}; // spacing=merge_dist;req_for_perf+morph
    union:@Namespace ns;view.glassEffect().glassEffectUnion(id:"g1",namespace:ns);
    morph:GlassEffectContainer{...}.glassEffectID("id",in:ns)+withAnimation{toggle()};
    under_sidebar_scroll:extend_ScrollView_content_to_leading/trailing_edges(auto,¬extra_mod)
  };
  uikit:{
    ```swift
    let fx = UIGlassEffect()
    fx.tintColor = .systemBlue.withAlphaComponent(0.3)
    fx.isInteractive = true
    let v = UIVisualEffectView(effect: fx)
    v.layer.cornerRadius = 20
    v.clipsToBounds = true
    v.contentView.addSubview(label)
    ```
    container:UIGlassContainerEffect()(spacing:40.0)→UIVisualEffectView(effect:containerFx)→containerView.contentView.addSubview(childGlassView);
    scroll_edge:scrollView.topEdgeEffect.style=.automatic;bottomEdgeEffect.style=.hard;leftEdgeEffect.isHidden=true;
    toolbar:barButtonItem.hidesSharedBackground=true // opt_out_shared_glass
  };
  widgetkit:{
    mode:@Environment(\.widgetRenderingMode) var m; // .accented(tinted_white_glass)⊕full_color
    accent_grp:view.widgetAccentable()(accent_grp;default=primary_grp);
    img:Image(...).widgetAccentedRenderingMode(.monochrome);
    bg:view.containerBackground(for:.widget){...}
  }
}
§R{
  wrap_sibling_glass_in(GlassEffectContainer|UIGlassContainerEffect);
  order:apply(.glassEffect())_AFTER(frame,font,padding);
  .interactive()⇔user_interactive_elems(btns,toggles);
  animate_morphs_via(withAnimation+@Namespace+glassEffectID);
  test:{light,dark,accented/tinted};
  a11y:verify_text_contrast_on_glass;
  use_for:{nav_bars,toolbars,tab_bars,FABs,cards,interactive_ctrls,morph_states,widgets}
}
§ANTI{
  ¬standalone_sibling_glass_without_container;
  ¬deep_glass_nesting(perf+clarity);
  ¬glass_on_every_view;
  ¬forget(clipsToBounds=true)_in_UIKit_w_cornerRadius;
  ¬ignore(widgetRenderingMode==.accented);
  ¬opaque_bg_behind_glass
}
§REL{
  [swift-ios](../SKILL.md):SwiftUI_views+state;
  [mobile-design](../../design/references/mobile-design.md):iOS_conventions+touch_targets;
  [design](../../design/SKILL.md) §6.H:translucent_material_rules
}
