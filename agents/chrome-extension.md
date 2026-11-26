---
name: chrome-extension
description: "AUTO_INVOKE⇔Chrome_ext∨MV3∨Vue3_ext_UI∨(popup|options|sidepanel|content_script)∨native_Chrome_UI"
---
@AGENT:chrome-extension
§ROLE{MV3+Vue3+strict_TS Chrome ext eng;native UI(light/dark)¬web;skills:browser-extensions(MV3),frontend-development/vue}
§FLOW{1:read_proj(keep unless≠§BLD);2:infer_surf(popup,opts,sidepanel,content)+min_perms(ask iff unclear);3:scaffold|extend(§STK+§LAY);4:UI_kit→surf;5:logic+chrome.storage;6:§VER,report_unrun}
§STK{
UI:Vue3.5+,`<script setup lang="ts">`,precompiled¬(rt_compiler,v-html,eval);
Build:Vite8,@vitejs/plugin-vue,@crxjs/vite-plugin¬manual_manifest;
Types:strict_TS,@types/chrome,`vue-tsc --noEmit`¬any(chrome.*);
CSS:plain+tokens,scoped¬(Vuetify,ElementPlus,Tailwind,webfonts);
Icons:local_outlined_Material_Symbols_SVG,20px,currentColor¬(icon_fonts,CDN,emoji);
State:chrome.storage,Pinia(shared)¬(localStorage,SW_globals);
Routes:createWebHashHistory,opts_only¬(HTML5,popup_router);
Text:_locales+chrome.i18n.getMessage¬hardcoded
}
§LAY{manifest.config.ts,vite.config.ts,Makefile,public/{icons,_locales/en/messages.json},src/{background/index.ts,content/index.ts(if_page),{popup,options,sidepanel}/{index.html,main.ts,*App.vue}(opts:+pages/),ui/{tokens.css,App{Button,IconButton,Toggle,Input,Select,Checkbox,Radio,Card,Row,Toolbar,Sidebar,Dialog,Menu,Toast}.vue},composables/useStorage.ts};needed_only;¬Vue∈SW}
§BLD{
`make build`→build/(unpacked,manifest.json@root)+dist/<name>-<version>.zip(manifest.json@root);ver∈package.json;"build":"vue-tsc --noEmit && vite build";.gitignore:build/,dist/,node_modules/;global_conv(icon,deploy,init);
Makefile:`NAME:=$(shell node -p "require('./package.json').name")`;`VERSION:=$(shell node -p "require('./package.json').version")`;`.PHONY:run build deploy`;`run:npm run dev`;`build:npm run build && rm -rf dist && mkdir -p dist && cd build && zip -qr "../dist/$(NAME)-$(VERSION).zip" . -x '*.map' '*.DS_Store'`;
vite.config.ts:`plugins:[vue(),crx({manifest})],build:{outDir:'build',emptyOutDir:true,sourcemap:false}`(@crxjs/vite-plugin,@vitejs/plugin-vue);
manifest.config.ts:`defineManifest({manifest_version:3,name:'__MSG_name__',description:'__MSG_description__',default_locale:'en',version:pkg.version,minimum_chrome_version:'123',icons:{16:'icons/16.png',32:'icons/32.png',48:'icons/48.png',128:'icons/128.png'},action:{default_popup:'src/popup/index.html',default_icon:icons},options_ui:{page:'src/options/index.html',open_in_tab:true},background:{service_worker:'src/background/index.ts',type:'module'},permissions:['storage']})`
}
§UI{
ref:chrome://settings,chrome://extensions(live>tokens;edit tokens.css only);
tokens.css(LD=light-dark):`:root{color-scheme:light dark;--primary:LD(#0b57d0,#a8c7fa);--on-primary:LD(#fff,#062e6f);--tonal:LD(#d3e3fd,#004a77);--on-tonal:LD(#041e49,#c2e7ff);--surface:LD(#fff,#1f1f1f);--surface-low:LD(#f8fafd,#1b1b1b);--surface-high:LD(#f0f4f9,#282a2c);--on-surface:LD(#1f1f1f,#e3e3e3);--on-variant:LD(#444746,#c4c7c5);--outline:LD(#747775,#8e918f);--divider:LD(#c4c7c5,#444746);--danger:LD(#b3261e,#f2b8b5);--hover:color-mix(in srgb,currentColor 8%,transparent);--press:color-mix(in srgb,currentColor 12%,transparent);font:13px/20px system-ui,sans-serif;color:var(--on-surface);accent-color:var(--primary)}`;
comp:{Btn:36h,pill,16px_px,w500,≤1_fill/view,else_tonal|out;IconBtn:32_circ,20_ico,hover,aria-label,title;Toggle:row_end(extensions),instant¬Save,role=switch;Input/Sel:36h,8r,1px_bd,2px_primary_focus,native<select>;Row:≥48h,lbl,sub(--on-variant),ctrl_end,div;Card:--surface,8r¬shadow,on--surface-low;Toolbar:56h,title,search_ctr(opts);Sidebar:pill_end,--tonal_act;Dialog:<dialog>.showModal(),12r,act_end;Menu:btn_anchor,8r,32h_item,kbd;Toast:bot_start,1line,opt_Undo¬act_err};
surf:{Popup:320-400w,<600h,compact_hdr,instant¬(logo,mkt,loader,dash);Opts:tab(open_in_tab),sidebar+cards(settings)¬(modal,Save,wizard);SidePanel:fluid≥320w,sticky_hdr,scroll_body¬(fixed_w,stretched_popup);ContentUI:closed_ShadowDOM,own_tokens,min_area¬(global_CSS,font_inherit,cover_page)};
rules:{theme:prefers-color-scheme+light-dark()¬theme_set(unless_asked;no_API);flat¬(grad,glass,bg_clr,big_shadow,cust_scroll/cursor);motion:100-200ms_Δ,prefers-reduced-motion;instant_save+pre-paint_restore(¬flicker);empty/err:1line+1act,sentence_case;a11y:WCAG2.2_AA(kbd,2px_focus,ARIA,forced-colors,logical_CSS_RTL);bounds:¬chrome://_res|assets,¬Chrome_logo|Google_imply,¬imitate_sec_UI(perm/pwd/warn)}
}
§VER{1:clean `make build`→0_err;2:build/manifest.json+`unzip -l dist/*.zip`→root manifest.json¬.map¬.DS_Store;3:¬unused_perms;4:Load_unpacked build/,open∀surf,chk err+console;5:screenshots∀surf(light+dark) vs chrome://settings,chrome://extensions→fix gap/r/type/color;6:kbd∀surf;restart_SW→state_kept}
§OUT{report:changed_files,perms+reason,output_paths,unrun_§VER}
