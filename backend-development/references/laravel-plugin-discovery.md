@REF:laravel-plugin-discovery
§USE{discover_Laravel_pkg|recommend_pkg|check_maintenance|verify_Laravel/PHP_compat|assess_health}
§CFG{
  mcp(`~/.claude.json` `mcpServers`):```json
"laraplugins": { "type": "http", "url": "https://laraplugins.io/mcp/plugins" }
```
  auth:none(free,¬API_key)
}
§API{
  SearchPluginTool(text_search?:str, health_score?:HealthBand, laravel_compatibility?:LaravelVer, php_compatibility?:PhpVer, vendor_filter?:str, page?:num)→[(pkg_name,desc,health,laravel_badges)];
  GetPluginDetailsTool(package:str[req,e.g."spatie/laravel-permission"], include_versions?:bool)→{health_score,last_activity,laravel_support_matrix,php_support,vendor_risk_score,version_history,readme_brief};
  enums:{
    HealthBand∈{"Healthy"(active/recent,rec_prod),"Medium"(occasional),"Unhealthy"(abandoned/infrequent),"Unrated"(unassessed)};
    LaravelVer∈{"5"-"9"(deprecated),"10"(legacy/common),"11"(widely_used),"12"(current_stable),"13"(latest)};
    PhpVer∈{"7.4","8.0","8.1","8.2","8.3","8.4","8.5"}
  }
}
§PAT{
  discover_feature:SearchPluginTool({text_search:"authentication",health_score:"Healthy",laravel_compatibility:"12"});
  eval_pkg:GetPluginDetailsTool({package:"spatie/laravel-permission",include_versions:true});
  by_vendor:SearchPluginTool({vendor_filter:"spatie",health_score:"Healthy"});
  compat_check:SearchPluginTool(laravel_compatibility)∨GetPluginDetailsTool
}
§R{
  prod⇒filter `health_score:"Healthy"`;
  match_target `laravel_compatibility`;
  prefer_known_vendors∈{"spatie","laravel"};
  always_verify_via `GetPluginDetailsTool` before_recommending;
  ¬API_key_required
}
§REL{
  `backend-development/references/php-laravel.md`;
  `backend-development/references/laravel-testing.md`;
  `backend-development/references/laravel-security.md`
}
