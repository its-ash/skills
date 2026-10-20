---
name: professional-communication
description: "Provides frameworks, templates, and checklists for writing professional emails, internal status updates, chat messages, and meeting communications tailored to software development teams. Use when drafting stakeholder emails, engineering updates, Slack or Teams messages, sprint retrospectives, 3P progress-plans-problems reports, newsletter sections, subject lines, tone calibration for executives versus peers, etiquette reviews, or any written communication needing audience-appropriate structure."
---

# Professional Communication

**Purpose** – Help software developers and teams write clear, effective professional messages: emails, internal updates, chat posts, and meeting materials.

---

## When to Use
- Drafting an email to a teammate, manager, stakeholder, or customer.
- Writing a status report, 3P update, newsletter, or incident summary.
- Sending a Slack/Teams/Discord message that requires a concise, actionable reply.
- Preparing a meeting agenda, facilitation plan, or post‑meeting summary.
- Translating technical details for a non‑technical audience.

---

## Core Frameworks
### 1. What‑Why‑How Structure
| Component | Goal | Example |
|---|---|---|
| **What** | State the topic or request clearly. | "We need to delay the release by one week." |
| **Why** | Explain the reason or impact. | "A critical bug was found in the payment flow." |
| **How** | List next steps or actions. | "QA will retest by Thursday; I will update stakeholders Friday." |

Apply this to any written message: email, chat, status update, or meeting notes.

### 2. Three Golden Rules for Written Communication
1. **Start with a clear subject or purpose** – the reader should know the intent within 5 seconds.
2. **Make it scannable** – use bullet points, headings, and short paragraphs.
3. **Put the key message first** – busy readers appreciate the main point up front.

---

## Audience Calibration
Before you write, answer three questions:
1. **Who** is the audience? (engineer, manager, executive, customer)
2. **What level of detail** do they need? (high‑level impact vs implementation specifics)
3. **What value** does the information provide them?

Adjust tone, jargon, and depth accordingly.

---

## Email Best Practices
### Subject‑Line Formula
| Weak | Strong |
|---|---|
| "Project updates" | "Project X: Status Update and Next Steps" |
| "Question" | "Quick question: API rate‑limit strategy" |
| "FYI" | "FYI: Deployment scheduled for Tue 3 PM PT" |

### Standard Email Template
```
Subject: [Project/Topic]: [Specific Purpose]

Hi [Name],

[1‑2 sentences stating the key point or request up front]

**Context / Background**
- [Bullet 1]
- [Bullet 2]

**What I need from you**
- [Specific action]
- [Deadline if any]

[Optional brief next steps]

Best,
[Your Name]
```

### Common Email Types
| Type | Key Elements |
|---|---|
| **Request** | Clear ask, brief context, deadline, why it matters |
| **Status Update** | Progress summary, blockers, next steps, timeline |
| **Escalation** | Issue summary, impact, attempted fixes, decision needed |
| **FYI / Announcement** | What changed, who is affected, any required action |
| **Follow‑up** | Reference prior message, restate ask, offer meeting |
| **Customer Support** | Apology, explanation, actions taken, next steps, contact |

### Tone Guidelines
- **Formal** – full sentences, no contractions, use titles.
- **Casual** – contractions OK, first names, still professional.
- **Urgent** – prefix subject with `[URGENT]` or `[ACTION REQUIRED]`, bold key points, explicit deadline.

### Email Etiquette Checklist
- Respond within 24 hours (even just to acknowledge).
- Use a specific subject line.
- Keep the body concise; aim for ≤ 200 words.
- Proofread for typos and clarity.
- Include attachments mentioned.
- Verify recipients (To, CC, BCC).
- End with a clear call‑to‑action.

---

## Internal Communication Formats
### 3P Update (Progress, Plans, Problems)
```
**Progress**
- Completed X feature.
- Fixed Y bug.

**Plans**
- Start Z work next week.
- Prepare release notes.

**Problems**
- Blocked by dependency on team A.
- Need clarification on API spec.
```

### Company Newsletter
- **Header**: Title, date, author.
- **Highlights**: 3‑5 bullet points of major news.
- **Deep Dives**: Short paragraphs (150‑200 words) for each highlight.
- **Call‑to‑Action**: Links to docs, surveys, or upcoming events.

### Incident Report
1. **Incident ID & Time**
2. **Summary** – one‑sentence description.
3. **Impact** – who/what was affected.
4. **Root Cause** – brief technical explanation.
5. **Resolution** – steps taken to fix.
6. **Preventive Actions** – what will change to avoid recurrence.

---

## Team Messaging Etiquette (Slack, Teams, Discord)
### When to Use Chat vs Email
| Chat | Email |
|---|---|
| Quick question, short answer | Detailed documentation, record‑keeping |
| Real‑time coordination | Formal communication to external stakeholders |
| Informal discussion | Messages that need careful review |
| Time‑sensitive update | Complex explanations with multiple parts |

### Best Practices
1. **Use threads** – keep channels clean; reply in thread.
2. **@mention selectively** – only notify those who need to act.
3. **Be direct** – e.g., "Can you review my PR #123?" instead of "Hey, are you busy?"
4. **Write async‑friendly** – assume the reader may reply hours later.
5. **Avoid “No Hello”** – combine greeting and request in one message.
   ```text
   Hi Sarah – quick question about the deployment script. I get a permission error on line 42. Have you seen this before?
   ```

---

## Technical vs Non‑Technical Communication
### Audience‑Specific Approaches
| Audience | Approach |
|---|---|
| Engineering peers | Full technical detail, code snippets, architecture diagrams |
| Technical managers | High‑level impact plus key technical points |
| Non‑technical stakeholders | Business impact, analogies, outcomes; avoid jargon |
| Customers | Plain language, what it means for them, next steps |

### Jargon Translation Cheat Sheet
| Technical term | Plain language |
|---|---|
| Microservices architecture | "Our system is split into smaller, independent pieces that can scale separately." |
| Asynchronous message processing | "Tasks are queued and processed in the background." |
| CI/CD pipeline | "Automated process that tests and deploys our code." |
| Database migration | "Updating how our data is organized and stored." |

### Simplification Strategies
1. **Start with the big picture** – explain *why* before *how*.
2. **Use analogies** – map technical concepts to familiar ideas.
3. **Check understanding** – pause for questions, watch for confusion.

---

## Writing Clarity Principles
- **Active voice** – "The team identified a bug" instead of "A bug was identified by the team."
- **Eliminate filler** – replace "At this point in time" with "Now".
- **The "So What?" Test** – after drafting, ask: *Why does this matter to the reader?* If the answer is unclear, rewrite to surface the value.

---

## Meeting Communication
### Agenda (pre‑meeting)
1. **Objective** – what will be accomplished?
2. **Agenda items** – list with time estimates.
3. **Preparation** – documents or data attendees must review.
4. **Desired outcome** – decision, information share, brainstorm?

### Facilitation Tips (during)
- Time‑box each item (e.g., "5 min discussion").
- Capture action items live with owner and due date.
- Use a "parking lot" for off‑topic ideas.

### Summary (post‑meeting) Template
```
**Meeting:** [Topic] – [Date]

**Attendees:** [Names]

**Key Decisions:**
- Decision 1
- Decision 2

**Action Items:**
- [ ] [Owner]: [Task] – due [Date]
- [ ] [Owner]: [Task] – due [Date]

**Next Steps:**
- Schedule follow‑up meeting
- Share relevant documents
```

---

## Quick Communication Checklist
- [ ] **Clear purpose** – can the reader grasp intent in 5 seconds?
- [ ] **Right audience/channel** – email, chat, or document?
- [ ] **Key message first** – main point appears at the top.
- [ ] **Scannable format** – bullets, headings, short paragraphs.
- [ ] **Action defined** – recipient knows what to do, if anything.
- [ ] **Jargon appropriate** – audience will understand terminology.
- [ ] **Tone suitable** – formal, casual, or urgent as needed.
- [ ] **Proofread** – no typos, correct names, accurate data.
- [ ] **Attachments/links included** – if referenced.

---

## References (inline examples only)
- Email templates for requests, status updates, escalations, and customer support.
- 3P update and incident‑report structures.
- Jargon‑to‑plain‑language mappings.
- Meeting agenda and summary formats.

---

*Last updated: 2025‑12‑22*

## Related skills

Load these when the task spans more than this skill.

- [`meeting-insights`](../meeting-insights/SKILL.md) — Analyzes meeting transcripts (txt, md, vtt, srt, docx) to reveal communication patterns, speaking ratios, fill…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`clear-writing`](../clear-writing/SKILL.md) — The clear‑writing skill helps you edit any human‑focused prose—documentation, commit messages, UI copy, report…
- [`planning`](../planning/SKILL.md) — Creates a concise atomic implementation plan for a coding task, expands it into a detailed step‑by‑step plan w…
- [`jira`](../jira/SKILL.md) — Interact with Jira issues using the jira CLI or Atlassian MCP tools. Use when the user mentions an issue key (…
- [`executive-advisor`](../executive-advisor/SKILL.md) — Provides integrated executive and technology leadership guidance for CEOs and CTOs. Use when planning corporat…
