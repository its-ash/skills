@REF:manim-video
§WHEN{tech_explainer(graph|workflow|arch|metric_prog|sys_diagram)∨X_landing_launch(precision+clarity>photorealism)}
§TOOLS{manim_CLI(ManimCommunity); ffmpeg; ../SKILL.md(assembly+polish); remotion.md(composited_UI|captions|motion_layers)}
§OUT{16:9_MP4; 1_thumb_poster_frame; storyboard+scene_plan; return:{core_thesis,storyboard,scene_outline,render_plan,polish_recs?}}
§FLOW{1:1_sentence_thesis→2:3..6_scenes→3:what_each_proves→4:scene_outline_pre_code→5:smallest_working(-ql)→6:tighten(type,spacing,color,pacing)→7:handoff_if_value_added}
§R{
  1:1_thing_proved/scene ∧ ¬overstuff ∧ progressive_reveal>clutter;
  2:motion_explains_state_Δ(¬busywork) ∧ short_meaningful_titles;
  3:net_graph_default:{current_pre_optimized, sep_style(low_sig_clutter,hi_sig_bridges), highlight(warm_paths,target_clusters)};
  4:render_conv:{16:9_default(unless vertical_req), smoke=`manim -ql`, final=`manim -qh` after comp+timing_stable, `-s`=save_last_frame_social_thumb}
}
§PAT{
  cmd:`manim -ql network_graph_scene.py NetworkGraphExplainer`;
  scene_api:`from manim import DOWN,LEFT,RIGHT,UP,Circle,Create,CurvedArrow,FadeIn,FadeOut,Scene,Text,VGroup` → `class NetworkGraphExplainer(Scene)`:{
    title:`Text(...,font_size=40).to_edge(UP)`, sub:`Text(...,font_size=20).next_to(title,DOWN)`;
    nodes:`Circle(radius=0.32..0.45,color="#4F8EF7"|"#7A7A7A"|"#21A179"|"#FF9F1C").shift(...)`, labels:`Text(...,font_size=18|22).move_to(n.get_center())`;
    edges:`CurvedArrow(a.get_right(),b.get_left(),angle=...,color=...)`;
    seq:`self.play(FadeIn/Create)`→`FadeIn(Text(...,font_size=24).to_edge(DOWN))`→`FadeOut(stale_nodes_edges)`→`Create(new_target_edge)`→`VGroup(...).animate.shift(UP*0.1)`→`self.wait(1)`
  }
}
