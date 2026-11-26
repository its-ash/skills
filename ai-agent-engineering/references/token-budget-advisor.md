@REF:token-budget-advisor
# Src: https://github.com/Xabilimon1/Token-Budget-Advisor-Claude-Code-
§WHEN{len/detail_ctrl;tokens|budget|depth|length|"short version"|"tldr"|"brief"|"al 25%"|"exhaustive"|upfront_depth;ex:{"Give me the short version first.","How many tokens will your answer use?","Respond at 50% depth.","I want the exhaustive answer, not the summary.","Dame la version corta y luego la detallada."}}
§SKIP{session_set⇒keep_silent;1_line_trivial;unrelated:{"What is a JWT token?","The checkout flow uses a payment token.","Is this normal?","Complete the refactor."}}
§FLOW{
1_in:prose:words×1.3|code/mix:chars/4(dominant,heuristic);
2_win:[in×m_min,min(in×m_max,model_max_out)]:Simple(3×–8×:"What is X?",yes/no,1_fact)|Medium(8×–20×:"How does X work?")|MedHigh(10×–25×:code+ctx)|Complex(15×–40×:multi_part,cmp,arch)|Creative(10×–30×:story,essay,narrative);
3_ask(¬short∧¬session_set):emit §TPL;25%:min+(max-min)×0.25|50%:min+(max-min)×0.50|75%:min+(max-min)×0.75|100%:max;
4_ans:25%_Essential(2-4sent|+direct,conclusion|-ctx,ex,nuance,alts)|50%_Moderate(1-3para|+ans,ctx,1ex|-deep,edge,refs)|75%_Detailed(struct|+multi_ex,pros/cons,alts|-extreme_edge,all_refs)|100%_Exhaustive(unbounded|+all|-∅)
}
§TPL{
```
Analyzing your prompt...

Input: ~[N] tokens  |  Type: [type]  |  Complexity: [level]  |  Language: [lang]

Choose your depth level:

[1] Essential   (25%)  ->  ~[tokens]   Direct answer only, no preamble
[2] Moderate    (50%)  ->  ~[tokens]   Answer + context + 1 example
[3] Detailed    (75%)  ->  ~[tokens]   Full answer with alternatives
[4] Exhaustive (100%)  ->  ~[tokens]   Everything, no limits

Which level? (1-4 or say "25% depth", "50% depth", "75% depth", "100% depth")

Precision: heuristic estimate ~85-90% accuracy (±15%).
```
}
§SHORT{"1"|"25% depth"|"short version"|"brief answer"|"tldr"⇒25%;"2"|"50% depth"|"moderate depth"|"balanced answer"⇒50%;"3"|"75% depth"|"detailed answer"|"thorough answer"⇒75%;"4"|"100% depth"|"exhaustive answer"|"full deep dive"⇒100%;persist_silently_until_changed}
§R{heuristic(no_tokenizer,~85-90%_acc,±15%_var);always_show_disclaimer}
