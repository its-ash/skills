@REF:tailwind-css

§R{
  STRICT_v4_ONLY;
  ¬`tailwind.config.js`(config_via_CSS_theme_vars∨PostCSS);
  ¬`@tailwind base;`/`@tailwind components;`/`@tailwind utilities;`⇒breaks_build
}
§CMD{
  auto(rec):`ng add tailwindcss`(installs_deps+config+global_import);
  manual_install:`npm install tailwindcss @tailwindcss/postcss postcss`
}
§CFG{
  `.postcssrc.json`(root):`{"plugins":{"@tailwindcss/postcss":{}}}`;
  CSS(`src/styles.css`):`@import 'tailwindcss';`;
  SCSS:`@use 'tailwindcss';`
}
§PAT{
  `<h1 class="text-3xl font-bold underline">Hello world!</h1>`
}
