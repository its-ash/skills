# Node.js project setup templates

## .nvmrc
```bash
node -v > .nvmrc   # exact version, e.g. 20.17.0
```

## package.json
```json
{
  "type": "module",
  "engines": { "node": ">=20.0.0" },
  "scripts": {
    "dev": "<framework dev command>",
    "build": "<framework build command>",
    "start": "node dist/index.js",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit"
  }
}
```

## Makefile (npm)
```makefile
run:
	npm run dev

build:
	npm run build

deploy: build
	git checkout main
	git add -A
	git commit -m "$$(copilot -sp 'Analyze the staged git changes and generate a concise commit message. Output ONLY the commit message. Do not execute any commands. Do not include quotes, markdown, explanation, or bullet points.')"
	git push origin main
```

## Nuxt `build` target (GitHub Pages from `docs/`)
```makefile
build:
	npx nuxt generate
	cp -r .output/public/* docs/ 2>/dev/null || cp -r dist/* docs/ 2>/dev/null
	touch docs/.nojekyll
```
- Set GitHub Pages manually in repo settings. Do not add a deploy workflow unless asked.

## .gitignore minimum
```
node_modules/
dist/
.env
.DS_Store
```
