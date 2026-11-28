@REF:regex-vs-llm-structured-text
§WHEN{structured_text∈{quizzes,exams,forms,invoices,receipts,tables,docs};cost_acc_opt∨hybrid_pipe}
§DEC{
  repeating(>90%_pattern)⇒regex_first:{acc≥95%⇒done(¬LLM)|acc<95%⇒hybrid(regex+LLM_edge)};
  free_form∨high_var⇒LLM_direct
}
§PIPE{Source→Regex_Parser(95-98%_acc)→Cleaner(markers,page_nums,artifacts)→Conf_Scorer→{≥0.95⇒out|<0.95⇒LLM_Validator→out}}
§API{
```python
@dataclass(frozen=True) class ParsedItem: id: str; text: str; choices: tuple[str, ...]; answer: str; confidence: float = 1.0
@dataclass(frozen=True) class ConfidenceFlag: item_id: str; score: float; reasons: tuple[str, ...]

pat = re.compile(r"(?P<id>\d+)\.\s*(?P<text>.+?)\n(?P<choices>(?:[A-D]\..+?\n)+)Answer:\s*(?P<answer>[A-D])", re.MULTILINE | re.DOTALL)
# parse_structured_text(content:str)->list[ParsedItem]: choices via re.findall(r"[A-D]\.\s*(.+)", choices)
# score_confidence(item:ParsedItem)->ConfidenceFlag: base=1.0; len(choices)<3⇒"few_choices"(-0.3); ¬answer⇒"missing_answer"(-0.5); len(text)<10⇒"short_text"(-0.2); max(0.0,score)
# identify_low_confidence(items:list[ParsedItem], threshold:float=0.95)->list[ConfidenceFlag]: f.score<threshold
def validate_with_llm(item: ParsedItem, original_text: str, client, model: str = "claude-haiku-5-5") -> ParsedItem:
    return client.messages.create(model=model, max_tokens=500, messages=[{"role":"user","content":f"Extract question,choices,answer.\nText:{original_text}\nCurrent:{item}\nReturn corrected JSON or 'CORRECT'."}])
# process_document(content:str,*,llm_client=None,confidence_threshold:float=0.95)->list[ParsedItem]: parse→identify_low_conf→if ¬low∨llm_client is None: return items→validate low_conf_ids
```
}
§METRICS{quiz_410:{regex_ok:98.0%,low_conf:8(2.0%),llm_calls:~5,cost_save_vs_LLM:~95%,cov:93%}}
§R{
  regex_first⇒baseline;
  conf_score⇒gate_LLM;
  model:cheapest(Haiku);
  immutable:¬mutate(ParsedItem)→new_instance;
  TDD:known_pats→edge_cases(malformed,missing_fields,encoding);
  log:{regex_ok_rate,llm_calls}
}
§ANTI{all_text→LLM_if(regex≥95%);regex_on_free_form;¬conf_scoring;mutate_in_place;¬edge_tests}
