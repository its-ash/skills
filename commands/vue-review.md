---
description: "Vue.js review (Composition API, reactivity, composables, template sec, a11y, perf) via vue-reviewer (+typescript-reviewer on .vue/.ts)."
---
@CMD:vue-review
§SCOPE{
when:{PR/commit∈`.vue`,post_edit(comp/composable/Pinia),pre_merge,audit(`v-html`/URL_bind),new_composable,Router_guards/nav,Nuxt_SSR/routes}
`vue-reviewer`:reactivity,composables,template_sec,a11y,Vue_perf,Pinia/Router
`typescript-reviewer`:generic_TS/JS,`any`_abuse,async,Node_sec
`security-reviewer`:proj_wide_sec
`/code-review`:generic_PR/diff(pure_TS/JS_sans_Vue_imports⇒use_this)
`.vue`∨Vue_`.ts`/`.js`⇒invoke(`vue-reviewer`∧`typescript-reviewer`,non_overlapping)
}
§FLOW{
1:precheck→fix_broken_build∧run_component_tests
2:`git diff`→mod(`.vue`,Vue_`.ts`/`.js`)
3:checks:`npx eslint .`; `vue-tsc --noEmit`(∨canonical_typecheck); `npx eslint . --rule 'vue/no-v-html: warn' --rule 'vue/no-template-target-blank: error'`; `npm audit`
4:missing(`eslint-plugin-vue`∨`vue-tsc`)⇒flag(HIGH_config)∧continue
5:review(Vue_lanes_only)→emit_report(CRITICAL|HIGH|MEDIUM)
}
§R{
CRITICAL:`v-html`_unsanitized(fix:`DOMPurify.sanitize`∨text)
CRITICAL:`:href`/`:src`_unvalidated_URL(`javascript:`,`data:`)
CRITICAL:client_secret(`VITE_*`,Nuxt_`public`_runtimeConfig)
CRITICAL:Nitro_endpoint_sans_input_val
CRITICAL:`localStorage`/`sessionStorage`_session_tokens
CRITICAL:destructure_`reactive()`(props_destructure_ok≥Vue3.5)
CRITICAL:`reactive()`_reassign(breaks_watchers)
CRITICAL:watch_ref_obj_sans_`.value`
HIGH:composable_module_scope_side_fx
HIGH:composable_no_cleanup(watch:`onCleanup`+`AbortController`,interval,listener)
HIGH:`v-for`_sans_`:key`∨`key={index}`
HIGH:`v-if`+`v-for`_same_el
HIGH:props_mut;missing_prop_val
HIGH:route_guard_`return false`_sans_redirect
HIGH:`useRoute().params`_top_destructure(snapshot)
HIGH:`v-model`_computed_sans_setter
HIGH:a11y(missing_labels,non_semantic_interactive)
HIGH:Pinia_direct_state_mut_outside_actions
MEDIUM:Options_API_new_Vue3;comp_>300L;`v-show`vs`v-if`_misuse;`<KeepAlive>`_sans_`:max`
MEDIUM:large_replaced_sans_`shallowRef`;custom_val_vs_vetted_lib;`defineExpose`_overexpose;`v-bind="$attrs"`_sans_`inheritAttrs:false`
}
§GATE{
`PASS: Approve`⇔CRITICAL=0∧HIGH=0
`WARNING: Warning`⇔MEDIUM>0∧CRITICAL=0∧HIGH=0
`FAIL: Block`⇔CRITICAL>0∨HIGH>0
}
§OUT{
fmt:`# Vue Code Review Report`→`## Files Reviewed`→`## Lint Results`(`PASS: eslint clean`,`PASS: vue-tsc clean`)→`## Issues Found`(`[<SEV>] <Title>\nFile: <path:line>\nIssue:\nWhy:\nFix:`)→`## Summary`(CRITICAL/HIGH/MEDIUM)→`Recommendation: <GATE>`
rel:{`vue-reviewer`,`typescript-reviewer`,`/code-review`(non-Vue),`web-quality-audit/references/web-accessibility.md`}
}
