@REF:pubmed
§R{scope}
MEDLINE/bio_srch,MeSH+tags,PMID/abs/meta/rel_cit,sys_rev,E-utilities(Py/sh/HTTP)

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
ep:{esearch.fcgi:PMIDs,esummary.fcgi:meta,efetch.fcgi:abs/XML/MEDLINE/txt,elink.fcgi:rel}
auth:NCBI_EMAIL∧NCBI_API_KEY∈env(¬file,¬hist);batch⇒usehistory=y,WebEnv,query_key(¬long_URL)
```python
import os,time,requests
BASE="https://eutils.ncbi.nlm.nih.gov/entrez/eutils"
def esearch(query:str,retmax:int=20)->list[str]:
 p={"db":"pubmed","term":query,"retmode":"json","retmax":retmax,"tool":"pubmed-search","email":os.environ.get("NCBI_EMAIL","")}
 if k:=os.environ.get("NCBI_API_KEY"):p["api_key"]=k
 r=requests.get(f"{BASE}/esearch.fcgi",params=p,timeout=30);r.raise_for_status();time.sleep(0.35)
 return r.json()["esearchresult"]["idlist"]
```

§FMT{log}
rec:{query,db,date,flt,cnt,fmt,excl};ex:`PubMed|2026-05-11|sickle cell disease[mh] AND CRISPR[tiab]|2020:2026[dp],English|42`

§CHK{valid_tags∧MeSH+syn∧date_rng∧repro_log∧env_keys∧raise_for_status()∧rate_lim}

§REF
help:https://pubmed.ncbi.nlm.nih.gov/help/;eutils:https://www.ncbi.nlm.nih.gov/books/NBK25501/;key:https://support.nlm.nih.gov/kbArticle/?pn=KA-05317;eutilities@ncbi.nlm.nih.gov
