---
description: "Get/analyze Jira ticket, comment, transition status, or JQL search via Atlassian MCP or REST API v3"
---
@CMD:jira
§IN:$ARGUMENTS→`get <TICKET-KEY>`|`comment <TICKET-KEY>`|`transition <TICKET-KEY>`|`search <JQL>`
§GATE{
auth:Atlassian_MCP(`claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp`)⊕REST_v3(env:`JIRA_URL`,`JIRA_EMAIL`,`JIRA_API_TOKEN`)
¬creds⇒stop→direct_user_setup
}
§FLOW{
get <TICKET-KEY>→fetch(MCP|REST_v3)→extract{summary,desc,AC,priority,labels,linked_issues,+comments?}→§OUT
comment <TICKET-KEY>→summarize(built,tested,committed)→format_structured→post
transition <TICKET-KEY>→fetch_transitions(To Do→In Progress→Done)→show_opts→exec_selected
search <JQL>→exec_JQL→summary_table
}
§OUT{
```
Ticket: PROJ-1234
Summary: [title] | Status: [status] | Priority: [priority] | Type: [Story/Bug/Task]
Requirements: 1..N [extracted]
Acceptance Criteria: - [ ] [criterion]
Test Scenarios: Happy Path / Error Case / Edge Case
Dependencies: [linked issues, APIs, services]
Recommended Next Steps: /plan | unit-testing-patterns/references/test-driven-development.md
```
}
§REL:/plan→`unit-testing-patterns/references/test-driven-development.md`→/code-review→`/jira comment`→`/jira transition`;skill:`git-workflow/references/jira-integration.md`
