@REF:blender-motion-state-inspection
§WHEN{char∈{twisted,mirrored,flattened,offset,foot_sliding,frozen_rig}∨verify(avatar|armature|retarget≡expected_pose)∨cmp(render,facts:{bones,bbox,contacts,facing,action_slot})∨classify(char|prop|proxy|rig|broken_import)}
§BPY_5{
  breaking(Blender_5.0+;introduced_4.4,dual_4.5_LTS):REMOVED{`action.fcurves`,`action.groups`,`action.id_root`};
  modern_api:```python
from bpy_extras import anim_utils
ad=obj.animation_data; act=ad.action if ad else None; slot=ad.action_slot if ad else None
cbag=anim_utils.action_ensure_channelbag_for_slot(act,slot) if (act and slot) else None
fcs=cbag.fcurves if cbag else []; grps=cbag.groups if cbag else []; id_type=slot.target_id_type if slot else None
```;
  new_bug:`act is not None and slot is None`⇒action_unbound(silent_frozen_char)
}
§R{
  1:¬judge_3d_by_screenshots_alone(hide:axis_conv,bone_names,obj_scale,local_xform,parented_meshes,mat_slots,action_slot,frame_contacts);
  2:extract_structured_state_1st(exporter∨bpy_in_blender)→confirm_via_viewport_renders;
  3:baseline_clean_scene_pre_motion;
  4:preserve(orig_mesh,materials,armature,skinning) unless explicit_repair_req;
  5:facts_pre_opinions(frame#,obj,bone,world_coords,thresholds)∧sep(confirmed_fails,visual_suspicions)∧attach_screenshots_after_state_explains
}
§FLOW{
  1_inventory:list(meshes,armatures,empties,cameras,lights,modifiers,parents,hidden)∧sep(char_meshes,helper_proxy)∧rec(obj_bbox,world_bbox);
  2_skeleton:cap(armatures,action,action_slot,channelbag.fcurves,pose_bones,heads,tails,roll,parents,constraints,rest_axes)∧map(hips,spine,neck,head,shoulders,elbows,hands,thighs,knees,ankles,feet)∧flag(missing_LR,odd_naming,unbound_action_slot);
  3_axes:derive(fwd,up,side) from pelvis+spine+shoulders+hips+head+feet(¬1_normal)∧cmp(local_arm,world,import:{glTF_Y_up,Blender_Z_up})∧flag(mirrored|backwards⇔face_head_feet≠root_motion);
  4_sample:frames∈{first,mid,contact,airborne,extreme}∧rec(root_loc,root_heading,pelvis_z,torso_lean,limb_dirs,foot_clear,bounds)∧dense(flips,landings,turns,collisions,contacts);
  5_integrity:verify_clean_baseline_pre_anim∧treat(sphere_blobs|giant_proxy|crushed_body)⇒import|selection_bug_until_proven;
  6_diagnose:{ground_pen:min_z(foot|shoe_verts) vs floor_z/f; foot_slide:Δworld_pos(foot) across planted_f; leg_cross:side_order(L/R thigh,knee,ankle,foot); twist_dmg:sep(swing_dir,roll_twist_around_axis); scale_drift:cmp(anim_bounds,baseline_bounds); slot_unbound:action_set∧action_slot≡None}
}
§THRESH{units:m(unless scene.unit_settings≠1); ground_pen:>1-2cm⇒visible(unless soft|stylized); scale_Δ:>5%⇒rig|constraint|inherit_bug; ankle_LR_flip_airborne⇒crossover_risk(even_if_recovers); root_heading_Δ:>30°/f⇒suspicious(unless snap_turn)}
§PAT{
  foot_slide:foot.L_min_z=0.004(planted)∧foot.L_x:0.21→0.28/6f∧pelvis_y:1.14→1.31⇒fail(fix:foot_lock|retarget_constraints,¬mesh_props);
  backwards_import:f1(neck→head=-Y)∧f72(root_y:0→2.8=+Y∧toes=-Y)⇒fix_import_retarget_axis_pre_curves;
  unbound_slot:act="Walk"∧action_slot=None⇒frozen_pose(fix:bind`ad.action_slot`→matching`target_id_type='OBJECT'`)
}
§OUT_FMT{Scene_Inventory(char_candidates,armatures,helpers_proxy,cameras_lights); Action_Binding(action,action_slot,target_id_type,fcurve_cnt); Orientation(world_up,char_fwd,root_heading,mirrored_backwards_risk); Baseline_Integrity(clean_bounds,anim_bounds,mats_skin_ok,suspicious_non_char); Frame_Findings(Frame,Finding,Evidence); Verdict(pass_fail,required_fix,render_ready)}
§ANTI{¬access`action.fcurves`/`action.groups`/`action.id_root`_on_Blender_5+; ¬edit_proportions_for_pose(unless mesh_repair); ¬bake_baseline_pre_record; ¬1_cam_angle_proof; ¬del_helpers_pre_logging_why_∉_char; ¬assume_facing(±X|±Y) w/o head+feet+torso+root}
§CMD{prefer:JSON_exporter(meshes,armatures,action_slot,pose_bones,materials,contacts,bbox,sampled_frames); fallback:`blender --background scene.blend --python collect_motion_state.py` # bpy∉sys_python}
