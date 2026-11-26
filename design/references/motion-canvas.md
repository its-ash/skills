@REF:motion-canvas
§USE{TS_programmatic_video(generators,signals,Vite_editor):init|scenes|fix_setup_import_build|shapes_text_custom|audio_sync}
§CMD{
  mkdir proj && cd proj && npm init -y
  npm i -D @motion-canvas/core @motion-canvas/2d @motion-canvas/vite-plugin @motion-canvas/ui vite typescript
  npm run dev # http://localhost:5173
}
§CFG{
  package.json:{"type":"module",scripts:{dev,build,preview}};
  vite.config.js(¬.ts):`import{defineConfig}from'vite';import{createRequire}from'module';const m=createRequire(import.meta.url)('@motion-canvas/vite-plugin');export default defineConfig({plugins:[(m.default||m)({project:'./src/project.ts'})]})`;
  tsconfig.json:{compilerOptions:{target:"ES2020",module:"ES2020",lib:["ES2020","DOM"],jsx:"react-jsx",jsxImportSource:"@motion-canvas/2d/lib",moduleResolution:"node",esModuleInterop:true,allowSyntheticDefaultImports:true,strict:true,skipLibCheck:true,resolveJsonModule:true,isolatedModules:true,noEmit:true},include:["src/**/*"],exclude:["node_modules"]};
  index.html:`<div id="root"/>+<script type="module" src="/src/project.ts">`;
  src/project.ts:`import{makeProject}from'@motion-canvas/core';import ex from'./scenes/example?scene';export default makeProject({scenes:[ex]})`
}
§PAT{
  core:function*+yield*;signals;createRef;all(...);prop(targetVal,sec);
  src/scenes/example.tsx:
  ```tsx
  import{makeScene2D}from'@motion-canvas/2d/lib/scenes';import{Circle}from'@motion-canvas/2d/lib/components';import{createRef}from'@motion-canvas/core/lib/utils';import{all}from'@motion-canvas/core/lib/flow';
  export default makeScene2D(function*(v){const c=createRef<Circle>();v.add(<Circle ref={c} size={70} fill="#e13238"/>);yield* c().size(140,1);yield* c().position.x(300,1);yield* c().fill('#e6a700',1);yield* all(c().scale(1.5,0.5),c().rotation(360,1))});
  ```
}
§TRBL{
  "TypeError: motionCanvas is not a function"⇒createRequire(¬ESM_import(@motion-canvas/vite-plugin));
  "Cannot find module '@motion-canvas/ui'"⇒npm_i(@motion-canvas/ui);
  "Property 'default' does not exist"⇒tsconfig(esModuleInterop+allowSyntheticDefaultImports);
  CJS_Vite_warning⇒ignore;
  "Failed to resolve import *.tsx?scene"⇒check(vite_plugin,"?scene");
  TS_build_err⇒check(tsconfig.json,jsxImportSource,deps)
}
§CHK{pkg("type":"module");deps(core,2d,vite-plugin,ui);vite.config.js(¬.ts,createRequire);tsconfig(esModuleInterop,jsxImportSource,strict);index.html(/src/project.ts);?scene_imports;function*+refs+sec_durations+split_scenes;npm_run_dev}
§RES{https://motioncanvas.io/docs;https://github.com/motion-canvas/motion-canvas}
§REL{../../typescript/SKILL.md;../../frontend-development/references/d3-visualization.md;../SKILL.md}
