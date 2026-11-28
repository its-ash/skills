@REF:uspto
§R{scope}
lookup(granted/pre-grant_pat,app_status/wrapper/assign/pros_hist,tm_status/docs/assign),repro_IP_log,cross_chk(Google_Pat|Lens.org|OpenAlex|co_pgs)
¬legal_advice;flow≡data_gather+rec_verif

§CFG{src_auth}
official_1st:{
  ODP(`https://data.uspto.gov`∧`https://api.uspto.gov/api/v1`):unified_portal(Patent_File_Wrapper,Office_Actions,Assignments,PTAB,Bulk_Data);
  PatentsView_in_ODP:legacy_`search.patentsview.org`_DECOMMISSIONED(NXDOMAIN)∧legacy_PatentSearch_API_paused/restructured⇒use_ODP_REST_APIs∨ODP_Bulk_Datasets(`pvgpatdis`:`g_patent`,`g_cpc_current`,`g_assignee_disambiguated`);
  TSDR_Data_API(`tsdrapi.uspto.gov`):tm_stat+docs(Swagger_migrated_to_ODP;distinct_API_Mgr/TSDR_key+strict_rate_lim)
}
secondary(Google_Pat|Lens.org|Sem_Scholar)≡conv_idx⇒cross_chk_official_if_mat
auth:USPTO.gov_acct+ID.me_verif→key@`https://data.uspto.gov/apikey`;env:`USPTO_ODP_API_KEY`(¬files,¬trans,¬hist;legacy_DevHub_keys_incompat);hdr:`X-API-KEY`
limits:ODP_weekly_quota∧strict_concurrency(¬parallel_streams_same_key)

§CMD{odp_patent_api}
use:{app_search,biblio,status,file_wrapper,tx,assignments,PTAB}
flow:1_chk_live_ODP_OpenAPI(ep,fields,params)→2_query(q,limit,offset)→3_serial_req(¬parallel_same_key)→4_log(ep,q,date,cnt)
```python
import os,requests
BASE="https://api.uspto.gov/api/v1"
p={"q":"applicationMetaData.inventionTitle:Semiconductor*","offset":0,"limit":50}
r=requests.get(f"{BASE}/patent/applications/search",headers={"X-API-KEY":os.environ["USPTO_ODP_API_KEY"]},params=p,timeout=30)
r.raise_for_status();print(r.json())
```
legacy_note:if_PatentsView_v1_compat_ep_re-enabled⇒pagination≡cursor(`size`≤1000+`after`),¬legacy(`per_page`/`page`)

§PAT{tsdr_wrap_assign}
TSDR(stat,docs,img,owner_hist,pros):1_norm(ser|reg)→2_chk(ODP_TSDR_Swagger,API_Mgr_hdr)→3_get(stat_1st;docs_if_req)→4_low_rate_lim(PDF/ZIP/multi)→5_log(date,ID);bulk_pull⇒ODP_bulk(¬scrape)
Wrapper(app_stat,tx,pros_docs):ODP_File_Wrapper(`api.uspto.gov/api/v1/patent/applications/...`);exact(app|pub|pat|party);tag(granted|pre-grant|pending);cross_chk(doc_dates+stat↔detail_pg)_pre_cite
Assign(owner):1_srch(pat/app/reg|assignor|assignee|reel/frame)→2_rec(convey_txt,exec_d,rec_d,parties)→3_assign_rec≠curr_legal_owner→4_mat⇒flag(atty/SME)

§FMT{log}
cols:Source|Date|ID/query|Filters|Results|Notes
ex:`USPTO_ODP|2026-11-28|inventionTitle:Semiconductor*|limit=50,offset=0|50|ODP_v1_search`;`TSDR|2026-11-28|serial=90000000|stat_only|1|API_Mgr_key,no_bulk`
writeup_sep:{official_facts,inferred,secondary_matches,gaps/legal_flags}

§CHK{official_ODP_1st∧¬legacy_search.patentsview.org∧verif_OpenAPI_pre∧keys∉{file,hist,log}∧serial_concurrency∧log(date+q)∧¬legal_concl/escalate∧sec_labeled}

§REF
ODP:https://data.uspto.gov/;key:https://data.uspto.gov/apikey;PV_bulk:https://data.uspto.gov/bulkdata/datasets/pvgpatdis;cat:https://developer.uspto.gov/api-catalog;TSDR_FAQ:https://developer.uspto.gov/faq/tsdr-api-bulk-download
