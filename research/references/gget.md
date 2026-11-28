@REF:gget
§META{scope:gget_CLI/Py(v0.30+,scverse:Ensembl,gene/seq,BLAST/BLAT,single_cell,motifs,targets,cancer,virus,repro_log)|Py≥3.9|¬use⇔clinical_interp∨high_throughput_prod∨fine_DB_ver/local_index(use_Biopython,Snakemake,Nextflow,BLAST+,DB_clients)}
§CMD:install(clean_env;upgrade+recheck_docs_before_old_env_since_DBs_Δ){
  venv:`python -m venv .venv && . .venv/bin/activate && python -m pip install --upgrade pip gget && gget --version`;
  uv:`uv venv && . .venv/bin/activate && uv pip install --upgrade gget`;
  opt_setup(heavy_deps):`gget setup <mod>`∨`gget.setup("<mod>")`(req_for:cellxgene,alphafold,elm)
}
§PAT{
  cli:`gget <module> [arguments] [options]`;
  py:`import gget; gget.search(["BRCA1"],species="human")`;
  ex:{
    `gget search -s human brca1 dna repair -o brca1-search.json`,
    `gget info ENSG00000012048 -o brca1-info.json`,
    `gget seq ENSG00000012048 -o brca1-seq.fa`,
    `gget blast "MEEPQSDPSVEPPLSQETFSDLWKLLPEN" -l 10 -o blast-results.json`,
    `gget.cellxgene(species="homo_sapiens",gene="ACE2",tissue="lung")`,
    `gget.opentargets("ENSG00000130234",resource="diseases")`,
    `gget.elm("MAPK1_HUMAN")`
  }
}
§WF{1:id(species,assembly,ID_type,DB)→2:chk_upstream_docs+ver→3:run_`gget setup`_if_opt→4:small_query→5:save(filename+date)→6:log(module,ver,args,DB_assumptions)}
§API:mods(opt_deps_narrower_Py_support){
  core:{search:Ensembl_IDs,info:Ensembl/UniProt/NCBI_meta,seq:nt/aa_seq,ref:genome_links};
  align:{blast:BLAST,blat:BLAT_vs_assembly,muscle:MSA,diamond:local_align};
  struct_motif:{alphafold:structure_pred,pdb:PDB_struct,elm:Eukaryotic_Linear_Motifs};
  sc_expr:{cellxgene:CZ_CELLxGENE_Census_AnnData/TileDB-SOMA,archs4:tissue_expr/coexpr,bgee:ortholog_expr};
  target_cancer_enrich:{enrichr:gene_set_enrich,opentargets:target_disease[diseases|drugs|tractability|pharmacogenetics|expression],cbio:cBioPortal_cancer,cosmic:COSMIC_somatic_muts(updated_API)};
  virology:{virus:INSDC/NCBI_Virus_seq+meta}
}
§LOG{cols:{Date,`gget --version`,Module,Query,Species/assembly,Output,Notes};extra:{Py_ver,env_mgr,`gget setup`_deps,DB_IDs,fmt∈{JSON,CSV,FASTA,DataFrame,AnnData},upgrade_fixes}}
§CHK{verified_`gget --version`(v0.30+)∧chk_docs∧explicit_species/assembly∧exact_Ensembl/UniProt_IDs∧labeled_DB_out(¬clinical)∧repro_snippet∧isolated_opt_deps}
§REL{https://pachterlab.github.io/gget/;https://pachterlab.github.io/gget/en/updates.html;https://github.com/pachterlab/gget;https://doi.org/10.1093/bioinformatics/btac836}
