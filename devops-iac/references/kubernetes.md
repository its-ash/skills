@REF:kubernetes
§SCOPE{platform_arch(K8s_v1.34-v1.37,N-3_window),multi_cluster,GitOps,Gateway_API,Helm_4,Karpenter,native_sidecars,CEL_ValidatingAdmissionPolicy,progressive_delivery,mesh,sec,multi_tenancy,FinOps,EKS|AKS|GKE|kubeadm,manifests(Deployment,Service,Gateway,HTTPRoute,Job,CronJob,HPA,PDB,RBAC),kubectl_dbg(CrashLoopBackOff,OOMKilled,Pending,ImagePullBackOff)}
§WF{1:reqs(workload,compliance,scale)→2:topology(cluster,net,sec_bounds)→3:delivery(GitOps,Canary|BlueGreen)→4:sec(PSS,RBAC,NetworkPolicy,CEL_policy)→5:obs(OTel,metrics,logs,traces)→6:scale(HPA,VPA,KEDA,Karpenter)→7:validate(policy/admission:staging→prod)}
§PAT{
  gitops(OpenGitOps:declarative∧versioned/immutable∧auto_pulled∧cont_reconciled):{tools:[ArgoCD,Flux_v2,Tekton];prog:[Argo_Rollouts,Flagger(canary|A-B)];repo:[App-of-apps,Kustomize_overlays];secrets:[External_Secrets_Operator,Sealed_Secrets,Vault]};
  iac:{k8s_native:[Helm_4(SSA,Wasm_plugins,OCI),Kustomize,cdk8s,Pulumi];provision:[Terraform|OpenTofu,Cluster_API];policy:[ValidatingAdmissionPolicy(in_tree_CEL),Kyverno,OPA_Gatekeeper,Falco]};
  sec:{PSS:[Restricted,Baseline,Privileged];net:[Cilium_eBPF,NetworkPolicy];supply_chain:[Sigstore,SBOM,Trivy];runtime:[Falco,Sysdig]};
  mesh_net:{ingress:Gateway_API(`gateway.networking.k8s.io/v1`:Gateway,HTTPRoute,TLSRoute,TCPRoute)¬`ingress-nginx`(EOL_Mar_2026);impl:[Envoy_Gateway,Cilium,Traefik,HAProxy];migrate:`ingress2gateway`;mesh:[Istio(ambient|sidecar),Linkerd,Cilium];enc:mTLS};
  sidecar:native_sidecars(`initContainers`+`restartPolicy:Always`,KEP-753)⇒start_before_app∧stop_after_app∧safe_in_Jobs;
  obs:{metrics:[Prometheus_3(OTLP),Mimir,VictoriaMetrics,Thanos];logs:[Fluent_Bit,Loki];traces:[OpenTelemetry,Tempo,Jaeger];viz:Grafana};
  cost_scale:{nodes:[Karpenter(v1+,fast_binpack_consolidation),ClusterAutoscaler];pods:[KEDA(event),HPA/VPA(resource)];finops:[OpenCost,KubeCost,spot,right_size];multi_tenant:[Namespace,ResourceQuota,LimitRange]}
}
§SAFE{¬prod_apply without rollback_plan;test(ValidatingAdmissionPolicy|Kyverno) in Audit/Warn mode first;∀container⇒resources.requests∧limits;stateful_PV⇒StorageClass+backup(Velero);¬deploy_EOL`ingress-nginx`}
§DEPLOY{
```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: my-app, namespace: my-namespace, labels: {app: my-app, version: "1.0.0"}}
spec:
  replicas: 3
  selector: {matchLabels: {app: my-app}}
  strategy: {type: RollingUpdate, rollingUpdate: {maxSurge: 1, maxUnavailable: 0}}
  template:
    metadata: {labels: {app: my-app, version: "1.0.0"}}
    spec:
      serviceAccountName: my-app-sa
      automountServiceAccountToken: false
      securityContext: {runAsNonRoot: true, runAsUser: 1001, fsGroup: 1001, seccompProfile: {type: RuntimeDefault}}
      terminationGracePeriodSeconds: 30
      # Native sidecar (starts first, terminates last): initContainers with restartPolicy: Always
      containers:
        - name: my-app
          image: ghcr.io/org/my-app:1.0.0 # pin semver or @sha256:... (¬:latest)
          imagePullPolicy: IfNotPresent
          ports: [{containerPort: 8080, protocol: TCP}]
          resources: {requests: {cpu: "100m", memory: "128Mi"}, limits: {cpu: "500m", memory: "256Mi"}}
          securityContext: {allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, capabilities: {drop: [ALL]}}
          startupProbe: {httpGet: {path: /health, port: 8080}, failureThreshold: 30, periodSeconds: 5}
          livenessProbe: {httpGet: {path: /health, port: 8080}, initialDelaySeconds: 0, periodSeconds: 30, failureThreshold: 3}
          readinessProbe: {httpGet: {path: /ready, port: 8080}, initialDelaySeconds: 5, periodSeconds: 10, failureThreshold: 2}
          envFrom: [{configMapRef: {name: my-app-config}}]
          env: [{name: DB_PASSWORD, valueFrom: {secretKeyRef: {name: my-app-secrets, key: db-password}}}]
          volumeMounts: [{name: tmp, mountPath: /tmp}]
      volumes: [{name: tmp, emptyDir: {}}]
```
}
§PROBE{
  startupProbe:{fail:kill_container;use:slow_start(JVM,Python);ex:failureThreshold:30*periodSeconds:5=150s_max};
  livenessProbe:{fail:restart_container;use:deadlock|hung;ex:periodSeconds:30*failureThreshold:3=90s};
  readinessProbe:{fail:remove_from_Service_endpoints;use:temp_unavail(DB_reconnect);ex:path:/ready,periodSeconds:10,failureThreshold:2};
  ¬(livenessProbe.initialDelaySeconds:60∧¬startupProbe)⇒race_cond
}
§NET{
  Service(v1):`spec:{selector:{app:my-app},ports:[{port:80,targetPort:8080,protocol:TCP}],type:ClusterIP}`;
  Gateway_API(preferred,¬EOL`ingress-nginx`):
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: prod-gw, namespace: gateway-system, annotations: {"cert-manager.io/cluster-issuer": "letsencrypt-prod"}}
spec:
  gatewayClassName: envoy # or cilium | traefik
  listeners: [{name: https, protocol: HTTPS, port: 443, hostname: "myapp.example.com", tls: {mode: Terminate, certificateRefs: [{name: my-app-tls}]}}]
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: my-app-route, namespace: my-namespace}
spec:
  parentRefs: [{name: prod-gw, namespace: gateway-system}]
  hostnames: ["myapp.example.com"]
  rules: [{matches: [{path: {type: PathPrefix, value: /}}], backendRefs: [{name: my-app, port: 80}]}]
```
}
§CFG{
  ConfigMap(v1):non-sensitive;mount_file:`volumes:[{name:config,configMap:{name:my-app-config,items:[{key:app.yaml,path:app.yaml}]}}]`,`volumeMounts:[{name:config,mountPath:/etc/app,readOnly:true}]`;
  Secret(v1,type:Opaque):base64_only(¬encrypted_at_rest unless KMS/cluster_enc)⇒prod:External_Secrets_Operator(https://external-secrets.io)∨Sealed_Secrets;
  cli:`kubectl create secret generic my-app-secrets --from-literal=db-password='s3cr3t' --namespace=my-namespace --dry-run=client -o yaml | kubectl apply -f -`
}
§RES{
  requests:scheduler_placement(100m=0.1_CPU);limits:kill|throttle_cap;
  sizing:{Web_API:cpu:100-250m,mem:128-256Mi,lim=2-4x;Worker:cpu:250-500m,mem:256-512Mi,mem_lim=req;JVM:cpu:500m-1,mem:512Mi-2Gi,headroom>-Xmx;Sidecar:cpu:10-50m,mem:32-64Mi};
  ¬(no_req_or_lim)⇒OOM/evict;¬(limits∧¬requests)⇒req=lim⇒over_reserve
}
§RBAC{
  patA(¬K8s_API,default):SA(v1) `automountServiceAccountToken:false` ∧ pod(`serviceAccountName:my-app-sa,automountServiceAccountToken:false`),¬Role/RoleBinding;
  patB(needs_K8s_API:operators/watchers):SA(`automountServiceAccountToken:true`) + Role(rbac.authorization.k8s.io/v1,ns-scoped,`rules:[{apiGroups:[""],resources:[configmaps],verbs:[get,list,watch]},{apiGroups:[""],resources:[secrets],resourceNames:[my-app-secrets],verbs:[get]}]`) + RoleBinding(rbac.authorization.k8s.io/v1,`subjects:[{kind:ServiceAccount,name:my-app-sa,namespace:my-namespace}]`,`roleRef:{kind:Role,apiGroup:rbac.authorization.k8s.io,name:my-app-role}`)
}
§HPA{req:resources.requests∀containers(util=current/request);`apiVersion:autoscaling/v2,kind:HorizontalPodAutoscaler,spec:{scaleTargetRef:{apiVersion:apps/v1,kind:Deployment,name:my-app},minReplicas:2,maxReplicas:10,metrics:[{type:Resource,resource:{name:cpu,target:{type:Utilization,averageUtilization:70}}},{type:Resource,resource:{name:memory,target:{type:Utilization,averageUtilization:80}}}]}`}
§PDB{`apiVersion:policy/v1,kind:PodDisruptionBudget,spec:{minAvailable:2,selector:{matchLabels:{app:my-app}}}` (⊕ `maxUnavailable:1`)}
§NS{`kubectl create namespace my-namespace`; `ResourceQuota(v1)`:`spec.hard:{requests.cpu:"4",requests.memory:4Gi,limits.cpu:"8",limits.memory:8Gi,pods:"20"}`}
§JOB{
  Job(batch/v1):`spec:{backoffLimit:3,ttlSecondsAfterFinished:3600,template:{spec:{restartPolicy:OnFailure|Never(¬Always),containers:[{name:migrate,image:ghcr.io/org/my-app:1.0.0,command:["python","manage.py","migrate"],resources:{requests:{cpu:"100m",memory:"256Mi"}}}]}}}`;
  CronJob(batch/v1):`spec:{schedule:"0 2 * * *",concurrencyPolicy:Forbid,successfulJobsHistoryLimit:3,failedJobsHistoryLimit:1,jobTemplate:{spec:{template:{spec:{restartPolicy:OnFailure,containers:[{name:cleanup,image:ghcr.io/org/cleanup:1.0.0,resources:{requests:{cpu:"50m",memory:"64Mi"}}}]}}}}}`
}
§DBG{
```bash
kubectl get pods -n my-namespace [-o wide]
kubectl describe pod <pod> -n my-namespace
kubectl logs <pod> -n my-namespace [--previous] [-c <container>]
kubectl exec -it <pod> -n my-namespace -- sh # or bash
kubectl top pods -n my-namespace && kubectl top nodes
kubectl rollout status|history|undo deployment/my-app -n my-namespace [--to-revision=2]
kubectl scale deployment my-app --replicas=5 -n my-namespace
kubectl get events -n my-namespace --sort-by='.lastTimestamp'
kubectl port-forward pod/<pod> 8080:8080 -n my-namespace # or svc/my-app 8080:80
kubectl apply -f deployment.yaml --dry-run=server # server-side validation
```
  triage:{CrashLoopBackOff:`logs --previous`+`describe pod`(exit_code,OOMKilled);ImagePullBackOff:`describe pod` Events(bad_tag,missing_imagePullSecret,private_reg);Pending:`describe pod`(insuff_resources,nodeSelector,taint/toleration);OOMKilled:`describe pod | grep -A5 "Last State"`(inc_mem_limit|mem_leak)}
}
§ANTI{`ingress-nginx`(EOL_Mar_2026⇒Gateway_API);`:latest` tag(pin semver|@sha256:...);`securityContext:{}`(root);no resource req/lim;plaintext secrets in ConfigMap;ClusterRoleBinding→`cluster-admin` for apps;PDB `minAvailable:0`;Job `restartPolicy:Always`;regular_container_sidecars_in_Jobs(⇒native_sidecar`initContainers`+`restartPolicy:Always`)}
§CHK{
  platform:[declarative_VCS,no_plaintext_secrets_in_git,Gateway_API(¬ingress-nginx),NetworkPolicy_default_deny,multi_region_DR(RTO/RPO),PSS+ValidatingAdmissionPolicy(CEL),Karpenter|CA,obs(OTel+metrics+logs+traces)];
  sec:[runAsNonRoot:true+runAsUser,seccompProfile:RuntimeDefault,readOnlyRootFilesystem:true+emptyDir,allowPrivilegeEscalation:false,capabilities.drop:[ALL],dedicated_SA(¬default),automountServiceAccountToken:false,least_priv_Role(¬ClusterRole),ESO|SealedSecrets];
  rel:[3_probes(startup+liveness+readiness),req+lim∀container,minReplicas>=2,PDB,RollingUpdate(maxUnavailable:0),HPA];
  obs:[/health+/ready,structured_JSON_logs(¬PII),labels(app,version,environment)]
}
§HELM{reusable_apps⇒Helm_4(native_SSA,Wasm_plugins,OCI);env_diff⇒Kustomize_overlays;GitOps_VCS;replace_pods(¬patch_live);`values.yaml:{replicaCount:3,image:{repository:myapp/backend,tag:"{{ .Chart.AppVersion }}"},service:{type:ClusterIP,port:80},resources:{limits:{cpu:"500m",memory:"256Mi"},requests:{cpu:"250m",memory:"128Mi"}}}`;`helm upgrade --install myapp oci://ghcr.io/org/charts/myapp --version 1.2.0 -f values.yaml -n prod --atomic`}
§REL{[docker.md](docker.md);[deployment-patterns.md](deployment-patterns.md);[secure-coding](../../secure-coding/SKILL.md);[git-workflow](../../git-workflow/SKILL.md)}
