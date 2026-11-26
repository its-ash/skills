@REF:uncloud
§ARCH{
  platform:decentralized_Docker+WireGuard_mesh+Caddy(CLI:`uc`);
  peers:no_central_control_plane(equal_peers);
  caddy:global@∀machine(auto_TLS:LetsEncrypt);¬edit_Caddyfile⇒`x-caddy`|`--caddyfile`;
  overlay:WireGuard(`10.210.0.0/16`_def)+internal_DNS;
  zero_downtime:wait_healthcheck→rm_old
}
§CMD[uc]{
  machine:`init user@host [--name NAME] [--network 10.210.0.0/16] [--no-caddy] [--no-dns] [--public-ip auto|IP|none]`, `add user@host`, `ls`, `update NAME --public-ip IP`, `rm NAME`;
  service:`service ls`|`ls`, `service run [--name N] [-p ...] [--caddyfile F] IMG`, `deploy [--no-build|--recreate]`, `build --push && uc deploy --no-build`, `scale SVC N`, `service logs|logs [-f|--since 1h] SVC`, `service exec|exec SVC [/bin/sh -c "env"]`, `service inspect|inspect SVC`, `service rm SVC`(keeps_named_vols;rm_anon_vols), `ps`;
  image:`image push IMG [-m m1,m2]`, `images`;
  volume:`volume ls [-m m1]`, `volume create NAME -m MACH`, `volume rm NAME`;
  caddy:`caddy config`(ro), `caddy deploy`;
  dns_ctx:`dns show`(*.uncld.dev), `dns reserve`, `ctx ls`, `ctx use prod`
}
§NET{
  http:`-p [host:]cport[/proto]`{`8080/https`→`svc.cluster-domain`,`app.example.com:8080/https`,`8080/http`(no_TLS)};
  host_l4:`-p [hip:]hport:cport[/proto]@host`(bypasses_Caddy){`5432:5432@host`,`127.0.0.1:5432:5432@host`,`53:5353/udp@host`};
  dns:{`svc`|`svc.internal`→any_healthy,`rr.svc.internal`→RR,`nearest.svc.internal`→local_first};
  tip:`*.yourdomain.com→cluster-public-ip`
}
§CFG[compose_ext]{
  `x-ports`:`[example.com:8000/https,www.example.com:8000/https]`;`x-machines`:`db-machine`⊕`[m1,m2]`;`deploy.mode:global`;
  img_tpl:`{{gitsha N}}`,`{{gitdate "20060102"}}`(Go_fmt),`{{date "fmt"}}`,e.g.`myapp:{{gitsha 7}}.${GITHUB_RUN_ID:-local}`;
  caddy_tpl:`{{upstreams [svc] [port]}}`(healthy_IPs),`{{.Name}}`,`{{.Upstreams}}`(svcs→IPs);
```yaml
services:
  api: { build: ./api, x-ports: [api.example.com:3000/https], environment: { DATABASE_URL: postgres://db:5432/mydb } }
  web: { build: ./web, x-ports: [example.com:8000/https, www.example.com:8000/https], environment: { API_URL: http://api:3000 } }
  app:
    image: app:latest
    x-caddy: |
      example.com { redir https://www.example.com{uri} permanent }
      www.example.com {
        reverse_proxy {{upstreams 8000}} { import common_proxy }
        basic_auth /admin/* { admin $2a$14$... }
      }
  db: { image: postgres:18, environment: { POSTGRES_PASSWORD: ${DB_PASSWORD} }, volumes: [db-data:/var/lib/postgresql/data], x-machines: db-machine }
volumes: { db-data: {} }
```
}
§PAT[ext_lan]{
  rule:`--caddyfile`∧¬`@host`_ports⇒INVALID;
  caddy:`https://device.example.com { reverse_proxy https://192.168.1.x { transport http { tls_insecure_skip_verify } } log }` (plaintext:`reverse_proxy http://192.168.1.x:port`);
  cmd:`uc service run --name device-bmc --caddyfile ~/device.caddyfile registry.k8s.io/pause:3.9`→verify:`uc caddy config`
}
§ANTI{
  edit_Caddyfile⇒`x-caddy`|`--caddyfile`;
  self_signed_HTTPS⇒`transport http { tls_insecure_skip_verify }`;
  `uc caddy config`_empty⇒admin_sock_err⇒`uc inspect caddy`∧`uc logs caddy`;
  lan_unreachable⇒check_Caddy_host_routing;
  `uc service rm`_vol_loss⇒named_persist∧anon_removed
}
