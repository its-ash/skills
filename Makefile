LLM_URL ?= http://127.0.0.1:9694/v1/chat/completions
LLM_MODEL ?= local

.PHONY: run start deploy

run:
	@./setup.sh --status

start:
	@chmod +x setup.sh
	@./setup.sh
	@touch docs/.nojekyll

deploy: start
	@git checkout main
	@git add -A
	@MSG=$$(git diff --cached | python3 -c 'import json,sys,urllib.request; diff=sys.stdin.read()[:12000]; req=urllib.request.Request("$(LLM_URL)", data=json.dumps({"model":"$(LLM_MODEL)","messages":[{"role":"system","content":"Generate one concise conventional commit message for the git diff. Output ONLY the commit message, no quotes, no markdown, no explanation."},{"role":"user","content":diff}],"temperature":0.2}).encode(), headers={"Content-Type":"application/json"}); print(json.loads(urllib.request.urlopen(req).read())["choices"][0]["message"]["content"].strip())'); \
	git commit -m "$${MSG:-chore: update}"
	@git push origin main
