@REF:gget
§META{scope:gget_CLI/Py(Ensembl,gene/seq,BLAST/BLAT,enrich,repro_log)|¬use⇔clinical_interp∨high_throughput_prod∨fine_DB_ver/local_index(use_Biopython,Snakemake,Nextflow,BLAST+,DB_clients)}
§CMD:install(clean_env;upgrade+recheck_docs_before_old_env_since_DBs_Δ){
  venv:`python -m venv .venv && . .venv/bin/activate && python -m pip install --upgrade pip gget && gget --help`;
  uv:`uv venv && . .venv/bin/activate && uv pip install gget`
}
§PAT{
  cli:`gget <module> [arguments] [options]`;
  py:`import gget; gget.search(["BRCA1"],species="human")`;
  ex:{`gget search -s human brca1 dna repair -o brca1-search.json`,`gget info ENSG00000012048 -o brca1-info.json`,`gget seq ENSG00000012048 -o brca1-seq.fa`,`gget blast "MEEPQSDPSVEPPLSQETFSDLWKLLPEN" -l 10 -o blast-results.json`,`gget.search(["BRCA1","DNA repair"],species="human");gget.info(["ENSG00000012048"]);gget.seq("ENSG00000012048")`}
}
§WF{1:id(species,assembly,ID_type,DB)→2:chk_upstream_docs→3:small_query→4:save(filename+date)→5:log(module,ver,args,DB_assumptions)}
§API:mods(opt_deps_narrower_Py_support){
  search:Ensembl_IDs;info:Ensembl/UniProt_meta;seq:nt/aa_seq;ref:genome_links;blast:BLAST;blat:BLAT_vs_assembly;muscle:MSA;diamond:local_align;alphafold|pdb:structure;enrichr|opentargets|archs4|bgee|cbio|cosmic:enrich/target/expr/cancer/disease
}
§LOG{cols:{Date,`gget --version`,Module,Query,Species/assembly,Output,Notes};extra:{Py_ver,env_mgr,`gget setup`_deps,DB_IDs,fmt∈{JSON,CSV,FASTA,DataFrame},upgrade_fixes}}
§CHK{verified_`gget --version`∧chk_docs∧explicit_species/assembly∧exact_Ensembl/UniProt_IDs∧labeled_DB_out(¬clinical)∧repro_snippet∧isolated_opt_deps}
§REL{https://pachterlab.github.io/gget/;https://pachterlab.github.io/gget/en/updates.html;https://github.com/pachterlab/gget;https://doi.org/10.1093/bioinformatics/btac836}
