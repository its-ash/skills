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

## ecosystem.config.cjs (PM2 — mandatory for all server / web-server apps)
```js
module.exports = {
  apps: [
    {
      name: "<app-name>",
      script: "dist/index.js",
      cwd: __dirname,
      instances: 1,
      exec_mode: "fork",
      autorestart: true,
      watch: false,
      max_memory_restart: "512M",
      env: {
        NODE_ENV: "development",
        PORT: 3000,
      },
      env_production: {
        NODE_ENV: "production",
        PORT: 3000,
      },
    },
  ],
};
```

## Makefile (npm + PM2 + local LLM deploy)
```makefile
LLM_URL ?= http://127.0.0.1:9694/v1/chat/completions
LLM_MODEL ?= local

.PHONY: run start deploy

run:
	npm run dev

start:
	npm run build
	pm2 startOrReload ecosystem.config.cjs --env production && pm2 save

deploy:
	npm run build
	git checkout main
	git add -A
	@MSG=$$(git diff --cached | python3 -c 'import json,sys,urllib.request; diff=sys.stdin.read()[:12000]; req=urllib.request.Request("$(LLM_URL)", data=json.dumps({"model":"$(LLM_MODEL)","messages":[{"role":"system","content":"Generate one concise conventional commit message for the git diff. Output ONLY the commit message, no quotes, no markdown, no explanation."},{"role":"user","content":diff}],"temperature":0.2}).encode(), headers={"Content-Type":"application/json"}); print(json.loads(urllib.request.urlopen(req).read())["choices"][0]["message"]["content"].strip())'); \
	git commit -m "$${MSG:-chore: update}"
	git push origin main
```

## Nuxt static `start` target (GitHub Pages from `docs/`)
```makefile
start:
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
