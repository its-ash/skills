@REF:liquid-glass-design
§CTX{iOS26–27+:LiquidGlass(dynamic_refraction+lensing+touch/pointer_react);Xcode27⇒mandatory(`UIDesignRequiresCompatibility`_ignored);scope:{SwiftUI,UIKit,WidgetKit}}
§PAT{
  swiftui:{
    basic:`.glassEffect()` // default:.regular,in:.capsule;
    variants:{`.regular`(toolbars/ctrls),`.clear`(media-heavy_bg),`.identity`(conditional_toggle)};
    custom:`.glassEffect(.regular.tint(.orange).interactive(), in: .rect(cornerRadius: 16.0))`;
    shapes:{`.capsule`,`.rect(cornerRadius:)`,`.circle`,`ConcentricRectangle`(matches_parent/device_curves)};
    btn:`.buttonStyle(.glass)`⊕`.buttonStyle(.glassProminent)`;
    container:`GlassEffectContainer(spacing: 40.0) { ... }` // unified_render_pass+proximity_merge;spacing=merge_dist;
    union:`@Namespace var ns; view.glassEffect().glassEffectUnion(id: "g1", namespace: ns)`;
    morph:`GlassEffectContainer { ... .glassEffectID("id", in: ns) }`+`withAnimation { toggle() }`;
    chrome_blend:{`.backgroundExtensionEffect()`(bleed_header_art_under_sidebar/inspector);`.scrollEdgeEffectStyle(.soft|.hard|.automatic, for: .top)`};
    tabs:{`.tabBarMinimizeBehavior(.onScrollDown)`;`.tabViewBottomAccessory { ... }`+`@Environment(\.tabViewBottomAccessoryPlacement)`};
    window_focus:`@Environment(\.appearsActive) private var appearsActive` // dim/adapt_custom_glass_on_unfocused_iPadOS/macOS_windows
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
    container:`UIGlassContainerEffect()`(`spacing: 40.0`)→`UIVisualEffectView(effect: containerFx)`→`containerView.contentView.addSubview(childGlassView)`;
    scroll_edge:`scrollView.topEdgeEffect.style = .automatic; bottomEdgeEffect.style = .hard; leftEdgeEffect.isHidden = true`;
    toolbar:`barButtonItem.hidesSharedBackground = true` // opt_out_shared_glass
  };
  widgetkit:{
    mode:`@Environment(\.widgetRenderingMode) var m` // .accented(tinted_white_glass)⊕full_color;
    accent_grp:`view.widgetAccentable()`(accent_grp;default=primary_grp);
    img:`Image(...).widgetAccentedRenderingMode(.monochrome)`;
    bg:`view.containerBackground(for: .widget) { ... }`
  }
}
§R{
  1:reserve_glass_for_chrome/nav/overlays(toolbars,tab_bars,FABs,floating_ctrls,widgets)∧keep_main_scroll_content_clean_underneath;
  2:wrap_sibling_glass_in(`GlassEffectContainer`|`UIGlassContainerEffect`)_for_single_pass_perf+morph;
  3:order:apply(`.glassEffect()`)_AFTER(frame,font,padding);
  4:`.interactive()`⇔user_interactive_elems(btns,toggles);
  5:animate_morphs_via(`withAnimation`+`@Namespace`+`glassEffectID`);
  6:Xcode27_audit:remove_`UIDesignRequiresCompatibility`∧verify_safe_areas+scroll_insets+custom_bgs;
  7:a11y+themes:test_{light,dark,accented/tinted,system_transparency_slider,ReduceTransparency}∧verify_contrast
}
§ANTI{
  ¬rely_on_`UIDesignRequiresCompatibility`_in_Xcode27(ignored);
  ¬standalone_sibling_glass_without_container;
  ¬nest_custom_glass_directly_under_system_TabView(double-glass_artifacts);
  ¬deep_glass_nesting(perf+clarity);
  ¬glass_on_every_view_or_opaque_bg_behind_glass;
  ¬forget(`clipsToBounds = true`)_in_UIKit_w_cornerRadius;
  ¬ignore(`widgetRenderingMode == .accented`∨`appearsActive`)
}
§REL{
  [swift-ios](../SKILL.md):SwiftUI_views+state;
  [mobile-design](../../design/references/mobile-design.md):iOS_conventions+touch_targets;
  [design](../../design/SKILL.md):translucent_material_rules
}
