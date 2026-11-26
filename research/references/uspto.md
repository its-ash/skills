@REF:uspto
§R{scope}
lookup(granted/pre-grant_pat,app_status/wrapper/assign/pros_hist,tm_status/docs/assign),repro_IP_log,cross_chk(Google_Pat|Lens.org|Sem_Scholar|co_pgs)
¬legal_advice;flow≡data_gather+rec_verif

§CFG{src_auth}
official_1st:{ODP(migrated_data/APIs),Patent_File_Wrapper(app_bib+wrapper),PatentSearch_API(PatentsView:granted+pre-grant),TSDR_Data_API(tm_stat+docs),Assignment_Search(pat/tm_transfers),PTAB_in_ODP}
secondary(Google_Pat|Lens.org|Sem_Scholar)≡conv_idx⇒cross_chk_official_if_mat
keys∈env∨sec_mgr(¬files,¬trans,¬sh_hist):USPTO_API_KEY,PATENTSVIEW_API_KEY;PatentSearch⇒hdr:X-Api-Key;TSDR⇒API_Mgr_instr+rate_lim

§CMD{patentsearch}
use:{trends,inventors,assignees,classif,dates,portfolio}
flow:1_chk_live_docs/Swagger(ep,fields,params,key)→2_JSON_q(filt)→3_min_fields(f)→4_det_sort/page→5_log(ep,body,date,curr,cnt)
```python
import os,requests
BASE="https://search.patentsview.org/api/v1"
p={"q":{"_and":[{"patent_date":{"_gte":"2024-01-01"}},{"assignees.assignee_organization":{"_text_any":["Google","Alphabet"]}}]},"f":["patent_id","patent_title","patent_date"],"s":[{"patent_date":"desc"}],"o":{"per_page":100,"page":1}}
r=requests.post(f"{BASE}/patent/",headers={"X-Api-Key":os.environ["PATENTSVIEW_API_KEY"],"Content-Type":"application/json"},json=p,timeout=30)
r.raise_for_status();print(r.json())
```

§PAT{tsdr_wrap_assign}
TSDR(stat,docs,img,owner_hist,pros):1_norm(ser|reg)→2_chk(API_Mgr,hdr)→3_get(stat_1st;docs_if_req)→4_low_rate_lim(PDF/ZIP/multi)→5_log(date,ID);bulk_pull⇒bulk_flow(¬scrape)
Wrapper(app_stat,tx,pros_docs):ODP_File_Wrapper;exact(app|pub|pat|party);tag(granted|pre-grant|pending);cross_chk(doc_dates+stat↔detail_pg)_pre_cite
Assign(owner):1_srch(pat/app/reg|assignor|assignee|reel/frame)→2_rec(convey_txt,exec_d,rec_d,parties)→3_assign_rec≠curr_legal_owner→4_mat⇒flag(atty/SME)

§FMT{log}
cols:Source|Date|ID/query|Filters|Results|Notes
ex:`PatentSearch|2026-05-11|assignee=Alphabet AND date>=2024|patent ep|118|docs chk pre-run`;`TSDR|2026-05-11|serial=90000000|stat only|1|key flow,no bulk`
writeup_sep:{official_facts,inferred,secondary_matches,gaps/legal_flags}

§CHK{official_1st∧verif_ep/fields_pre∧keys∉{file,hist,log}∧log(date+q_shape)∧rate_lim∧¬legal_concl/escalate∧sec_labeled}

§REF
cat:https://developer.uspto.gov/api-catalog;ODP:https://data.uspto.gov/;PS_ref:https://search.patentsview.org/docs/docs/Search%20API/SearchAPIReference/;PS_upd:https://search.patentsview.org/docs/;TSDR_FAQ:https://developer.uspto.gov/faq/tsdr-api-bulk-download
