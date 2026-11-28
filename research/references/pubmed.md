@REF:pubmed
§R{scope_limits}
MEDLINE/PubMed/PMC_bio_srch,MeSH+tags,PMID/PMCID/abs/meta/rel_cit,sys_rev,E-utilities(Py/sh/HTTP)
rate_lim:{no_key:3_req/s,with_NCBI_API_KEY:10_req/s,exceed⇒HTTP_429(exp_backoff),mass_batch⇒off_peak(9PM-5AM_ET∨weekends)}
pmc_2026_chg:db=pmc_migrated_to_new_PMC_E-utilities⇒esearch_cap≤10000_records(`retmax<=10000`)∧epost_cap≤10000_PMCIDs/URL
datasets_api:5_req/s_default∨10_req/s_with_key

§PAT{q}
bool:`c1 AND c2 AND filt`|`syn_a OR syn_b`|`NOT excl`
tags:{[ti]:title,[ab]:abs,[tiab]:ti|ab,[au]:auth,[ta]:j_abbr,[mh]:MeSH,[majr]:maj_MeSH,[pt]:pub_type,[dp]:date,[la]:lang,[nm]:subst,[sb]:sub,[text]:avail}
ex:`diabetes mellitus[mh] AND treatment[tiab] AND systematic review[pt] AND 2023:2026[dp]`|`(metformin[nm] OR insulin[nm]) AND diabetes mellitus, type 2[mh] AND randomized controlled trial[pt]`|`smith ja[au] AND cancer[tiab] AND 2026[dp] AND english[la]`

§R{mesh}
stable⇒[mh];new/var⇒[mh]+[tiab];sub_pre_tag:`diabetes mellitus, type 2/drug therapy[mh]`,`cardiovascular diseases/prevention & control[mh]`;[majr]⇔central(↑prec,↑miss)

§CFG{flt}
[pt]∈{clinical trial,meta-analysis,randomized controlled trial,review,systematic review,guideline}
[dp]:2026|2020:2026|2026/03/15;avail:free full text[sb]|hasabstract[text]

§CMD{eutils}
base:https://eutils.ncbi.nlm.nih.gov/entrez/eutils
ep:{esearch.fcgi:PMIDs,esummary.fcgi:meta,efetch.fcgi:abs/XML/MEDLINE/txt,elink.fcgi:rel,epost.fcgi:batch_IDs}
auth:NCBI_EMAIL∧NCBI_API_KEY∈env(¬file,¬hist);batch⇒usehistory=y,WebEnv,query_key(¬long_URL)
```python
import os,time,requests
BASE="https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
def esearch(query:str,db:str="pubmed",retmax:int=20)->list[str]:
 k=os.environ.get("NCBI_API_KEY")
 p={"db":db,"term":query,"retmode":"json","retmax":min(retmax,10000),"tool":"pubmed-search","email":os.environ.get("NCBI_EMAIL","")}
 if k:p["api_key"]=k
 for i in range(4):
  r=requests.get(f"{BASE}/esearch.fcgi",params=p,timeout=30)
  if r.status_code!=429:break
  time.sleep(2**i)
 r.raise_for_status();time.sleep(0.11 if k else 0.35)
 return r.json()["esearchresult"]["idlist"]
```

§FMT{log_PRISMA-S}
rec:{db,exact_date,exact_query,filters,result_cnt,export_fmt,excl};ex:`PubMed|2026-11-28|sickle cell disease[mh] AND CRISPR[tiab]|2020:2026[dp],English|42|PMID_list`

§CHK{valid_tags∧MeSH+syn∧date_rng∧PRISMA-S_log∧env_keys∧429_backoff∧adaptive_rate_lim∧pmc_10k_cap_aware∧raise_for_status()}

§REF
help:https://pubmed.ncbi.nlm.nih.gov/help/;eutils:https://www.ncbi.nlm.nih.gov/books/NBK25501/;key:https://support.nlm.nih.gov/kbArticle/?pn=KA-05317;eutilities@ncbi.nlm.nih.gov
