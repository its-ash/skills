@REF:rendering-strategies
§D{SEO∧static⇒SSG;SEO∧dynamic⇒SSR;¬SEO∧interactive⇒CSR;mixed⇒Hybrid(route)}
§PAT{
CSR[default]:browser|use=dashboards,internal|+=simple_cfg,low_srv_cost|-=poor_SEO,slow_FCP(JS);
SSG[prerender]:build_HTML|use=marketing,blogs,docs|+=fastest_load,SEO,CDN|-=rebuild_Δ,¬user_data;
SSR:srv(init_req)→SPA(nav)|use=ecommerce,news,personalized|+=SEO,fast_FCP|-=Node_srv,cost_latency
}
§R{hydration:SSR_HTML→interactive;full⇒all_at_once;incremental⇒@defer;event_replay⇒capture_pre_hydration→replay_post}
