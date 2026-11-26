@REF:research-workflow
§REL{../SKILL.md}
§FLOW{1_Collect→2_Clean→3_Patterns→4_Persona→5_Journey→6_TestPlan→7_Capture→8_Synthesize→9_Validate}
§STEPS{
  1:interviews→txt|JSON;surveys→CSV;analytics(views,clicks)→CSV|JSON;∈VC;
  2(pandas):`read_csv("survey_responses.csv")`,`read_json("interview_tags.json")`;`c.strip().lower().replace(" ","_")`;`drop_duplicates()`;`isna().mean(axis=1)<=0.30`;`dropna(subset=["age","goal","pain_point"])`;`satisfaction.map({"Very Satisfied":5,"Satisfied":4,"Neutral":3,"Dissatisfied":2,"Very Dissatisfied":1})`;
  3:small→freq(goals,pain_points);large(3-5)→`TfidfVectorizer(stop_words="english").fit_transform(s["goal"])`+`KMeans(n_clusters=4,random_state=42).fit(X).labels_`(`sklearn`);label_centroids("Power User","Occasional Shopper");
  4:{Name,Demographics(age,gender,loc,occ),Behaviors(freq,device),Goals,PainPoints,Psychographics(attitudes,motivations,values),Scenario(<150w),Conf(supporting/total*100)};
  5:Awareness(Social_ad,Curious,jargon)→Consideration(Product_page,Interested,no_pricing)→Purchase(Checkout,Anxious,validation)→Use(Mobile_onboard,Confident,UI_inconsist)→Support(Live_chat,Frustrated,wait);(touchpoint,emotion,pain_point);tools[table,Miro,FigJam,Lucidchart];+alt_paths;
  6:tasks←scenarios;criteria(≤2m,≤1_err);diverse_demo;method∈{mod_remote,unmod_remote(Maze,UserTesting),in_person};
  7:quant[success_rate,time_on_task,error_count,SUS]+qual[comments,think_aloud,expressions]→CSV;
  8:mean_time+success_%;affinity/thematic→(insight→implication);imp/eff(Nav:H/L→H,Checkout:M/M→M);
  9:Figma_Δ→retest_same_personas→vs_baseline
}
§CHK{[raw∈VC,dupes+nulls,clusters,persona+conf,journey,plan,CSV,prio_insights+implications,retest,shared]}
