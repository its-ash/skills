---
description: "Scan project and generate PM2 v6 config, wrappers, and command/script files."
---
@CMD:pm2
§ARGS{$ARGUMENTS}
§R{
  cfg:"ecosystem.config.cjs"(¬.js)
  node:bin_path+interpreter("C:/Program Files/nodejs/node.exe")
  py:"{backend}/start.cjs"∧windowsHide:true
  win:"start wt.exe -d \"{path}\" pwsh -NoExit -c \"{cmd}\""
  cmd_md:1-2L_desc+bash_block(direct_exec,¬AI_parse)
  prod_alt:systemd|containers
}
§FLOW{
  1:chk_pm2(missing⇒"npm install -g pm2")
  2:detect:{
    Vite(vite.config.*):5173|bin="node_modules/vite/bin/vite.js"|args="--port {port}"
    Next(next.config.*):3000|bin="node_modules/next/dist/bin/next"|args="dev -p {port}"
    Nuxt(nuxt.config.*):3000|bin="node_modules/nuxt/bin/nuxt.mjs"|args="dev --port {port}"
    CRA(react-scripts∈package.json,legacy→Vite):3000
    Express/Node((server|backend|api)/+package.json):3000|bin="src/index.js"|"server.js"
    FastAPI/Flask(pyproject.toml|requirements.txt):8000|bin="start.cjs"
    Go(go.mod|main.go):8080
    port_prio:user>.env>cfg_file>script_args>default
  }
  3:gen:["ecosystem.config.cjs","{backend}/start.cjs"(if_py),".claude/commands/{pm2-all,pm2-all-stop,pm2-all-restart,pm2-{port},pm2-{port}-stop,pm2-{port}-restart,pm2-logs,pm2-status}.md",".claude/scripts/{pm2-logs-{port},pm2-monit}.ps1"]
  4:upd("CLAUDE.md":create_if_∅;exists("## PM2 Services")⇒replace⊕append)
  5:emit(§OUT)
}
§TPL{
  ecosystem.config.cjs:
  ```js
  module.exports={apps:[
    {name:'project-3000',cwd:'./packages/web',script:'node_modules/vite/bin/vite.js',args:'--port 3000',interpreter:'C:/Program Files/nodejs/node.exe',env:{NODE_ENV:'development'}},
    {name:'project-8000',cwd:'./backend',script:'start.cjs',interpreter:'C:/Program Files/nodejs/node.exe',env:{PYTHONUNBUFFERED:'1'}}
  ]};
  ```
  start.cjs:
  ```js
  const{spawn}=require('child_process');
  spawn('uv',['run','uvicorn','app.main:app','--host','0.0.0.0','--port','8000','--reload'],{cwd:__dirname,stdio:'inherit',windowsHide:true}).on('close',c=>process.exit(c));
  ```
  cmd_md:
  pm2-all.md:`cd "{PROJECT_ROOT}" && pm2 start ecosystem.config.cjs && start wt.exe -d "{PROJECT_ROOT}" pwsh -NoExit -c "pm2 monit"`
  pm2-all-stop.md:`cd "{PROJECT_ROOT}" && pm2 stop all`
  pm2-all-restart.md:`cd "{PROJECT_ROOT}" && pm2 restart all`
  pm2-{port}.md:`cd "{PROJECT_ROOT}" && pm2 start ecosystem.config.cjs --only {name} && start wt.exe -d "{PROJECT_ROOT}" pwsh -NoExit -c "pm2 logs {name}"`
  pm2-{port}-stop.md:`cd "{PROJECT_ROOT}" && pm2 stop {name}`
  pm2-{port}-restart.md:`cd "{PROJECT_ROOT}" && pm2 restart {name}`
  pm2-logs.md:`cd "{PROJECT_ROOT}" && pm2 logs`
  pm2-status.md:`cd "{PROJECT_ROOT}" && pm2 status`
  ps1:
  pm2-logs-{port}.ps1:`Set-Location "{PROJECT_ROOT}"`+`pm2 logs {name}`
  pm2-monit.ps1:`Set-Location "{PROJECT_ROOT}"`+`pm2 monit`
  claude_md:`## PM2 Services`+{port}|{name}|{type}+[`pm2 start ecosystem.config.cjs`,`pm2 start all`,`pm2 stop all / pm2 restart all`,`pm2 start {name} / pm2 stop {name}`,`pm2 logs / pm2 status / pm2 monit`,`pm2 save`,`pm2 resurrect`]
}
§OUT{
  summary:"PM2 Init Complete",services({port,name,type}),claude_cmds:[/pm2-all,/pm2-all-stop,/pm2-{port},/pm2-{port}-stop,/pm2-logs,/pm2-status],terminal_cmds:["pm2 start ecosystem.config.cjs && pm2 save","pm2 start|stop|restart all","pm2 start|stop {name}","pm2 logs|monit|resurrect"],tip:"Run `pm2 save` after first start"
}
