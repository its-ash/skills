---
name: analytics-tracking
description: "Plans, implements, audits, and analyzes analytics tracking across GA4, GTM, Mixpanel, and other platforms with structured tracking plans, object_action event naming conventions, core event sets for marketing sites, products, and e-commerce, plus custom event properties and gtag.js snippets. Use when configuring data streams, enhanced measurement, tag manager containers, UTM parameters, custom events, funnel analysis, attribution modeling, debugging GA4 reports, or reviewing Mixpanel dashboards for product, marketing, or e-commerce insights."
---

# Analytics Tracking

Help teams design, implement, audit, and analyze analytics tracking that drives product and marketing decisions. Covers planning, naming, GA4 & GTM setup, UTM strategy, validation, privacy, and basic GA4 data analysis.

---

## When to Use
- You need a tracking plan for a new website, app, or product feature.
- You want to improve or audit existing GA4 / GTM implementation.
- You must define UTM conventions for campaigns.
- You need to validate that events fire correctly and respect privacy.
- You want to pull GA4 data via the API to identify trends and recommend actions.

---

## 1. Initial Assessment
| Area | Key Questions |
|------|---------------|
| Business | What decisions will the data support? Which conversions matter? |
| Current State | What tools are in use (GA4, Mixpanel, Amplitude, etc.)? What events already exist? |
| Technical | What tech stack (web, iOS, Android) and who will maintain the tags? Any consent or GDPR requirements? |

Gather answers before writing any code.

---

## 2. Tracking Plan Framework
Create a single source of truth (Google Sheet, Confluence page, or Markdown file).

```
Event Name | Category | Properties | Trigger | Notes
----------|----------|------------|---------|------
```

### 2.1 Event Types
- **Pageviews** – automatic in most tools; add metadata if needed.
- **User Actions** – button clicks, form submissions, feature usage.
- **System Events** – signup completed, purchase completed, error logged.
- **Custom Conversions** – funnel milestones, business‑specific goals.

### 2.2 Naming Conventions (recommended: object_action)
```
signup_completed
button_clicked
form_submitted
article_read
```
- Use lowercase and underscores.
- Keep the name short; put context in properties.
- Document every event in the plan.

---

## 3. Core Event Sets (Starter List)
### Marketing Site
| Event | Typical Properties |
|-------|---------------------|
| page_view (enhanced) | page_title, page_location |
| outbound_link_clicked | link_url, link_text |
| scroll_depth | percent (25,50,75,100) |
| cta_clicked | button_text, location |
| form_started | form_name |
| form_submitted | form_name, success |
| resource_downloaded | resource_name |
| signup_started | source, medium |
| signup_completed | method, plan |

### Product / App
| Event | Typical Properties |
|-------|---------------------|
| onboarding_step_completed | step_number, step_name |
| feature_used | feature_name |
| session_started | session_id |
| trial_started | trial_type |
| purchase_completed | plan, value |

### E‑commerce
| Event | Typical Properties |
|-------|---------------------|
| product_viewed | product_id, category, price |
| product_added_to_cart | product_id, quantity |
| cart_viewed | cart_value |
| checkout_started | step |
| purchase_completed | order_id, value, items |

---

## 4. Event Properties (Parameters)
| Group | Common Properties |
|-------|--------------------|
| Page/Screen | page_title, page_location, page_referrer |
| User | user_id, user_type, account_id, plan_type |
| Campaign | source, medium, campaign, content, term |
| Product (e‑comm) | product_id, product_name, category, price, quantity, currency |
| Timing | timestamp, session_duration |

**Best practices**
- Use consistent names across all events.
- Do not send PII (email, phone, address).
- Align with GA4 automatic parameters to avoid duplication.

---

## 5. GA4 Implementation
### 5.1 Data Streams & Enhanced Measurement
- Create one stream per platform (Web, iOS, Android).
- Enable *Enhanced measurement* for page_view, scroll (90 % depth), outbound_click, site_search, video_engagement, file_download.

### 5.2 Custom Event Snippets
#### gtag.js
```javascript
gtag('event', 'signup_completed', {
  method: 'email',
  plan: 'free'
});
```
#### Google Tag Manager (dataLayer)
```javascript
dataLayer.push({
  event: 'signup_completed',
  method: 'email',
  plan: 'free'
});
```

### 5.3 Conversions
1. Verify the event appears in **Admin > Events**.
2. Mark it as a *Conversion*.
3. Choose counting method (once per session vs. every time).
4. Optionally import to Google Ads.

### 5.4 Custom Dimensions & Metrics
- Create in **Admin > Custom definitions**.
- Scope: *Event* for per‑event data, *User* for persistent attributes, *Item* for e‑comm items.
- Parameter name must match the property sent in the event.

---

## 6. Google Tag Manager (GTM) Setup
### 6.1 Container Structure
- **Tags**: GA4 Configuration (base), GA4 Event (one per event or grouped), conversion pixels (Meta, LinkedIn, etc.).
- **Triggers**: Page View, Click – All Elements, Form Submission, Custom Event.
- **Variables**: Built‑in (Click Text, Click URL), Data Layer variables, JavaScript variables, Lookup tables.

### 6.2 Naming Conventions
```
Tag_GA4_Event_signup_completed
Trigger_Click_SignupCTA
Variable_DL_user_id
```
- Use folders to group Tags, Triggers, Variables.
- Add a version note on every publish.

### 6.3 Data Layer Pattern
```javascript
// Custom event
dataLayer.push({
  event: 'form_submitted',
  form_name: 'contact',
  form_location: 'footer'
});

// User properties (once per session)
dataLayer.push({
  user_id: '12345',
  user_type: 'premium'
});

// E‑commerce purchase
dataLayer.push({
  event: 'purchase',
  ecommerce: {
    transaction_id: 'T12345',
    value: 99.99,
    currency: 'USD',
    items: [{
      item_id: 'SKU123',
      item_name: 'Product Name',
      price: 99.99,
      quantity: 1
    }]
  }
});
```

---

## 7. UTM Parameter Strategy
| Parameter | Purpose | Example |
|-----------|---------|---------|
| utm_source | Traffic origin | google |
| utm_medium | Marketing medium | cpc |
| utm_campaign | Campaign name | spring_sale |
| utm_content | Creative variant | hero_cta |
| utm_term | Paid‑search keyword | running+shoes |

**Naming Rules**
- Lowercase only.
- Use underscores or hyphens consistently.
- Keep names concise but descriptive (e.g., `blog_footer_cta`).

**Documentation** – maintain a spreadsheet with columns: Campaign, Source, Medium, Content, Full URL, Owner, Date.

---

## 8. Debugging & Validation
### 8.1 Tools
- **GA4 DebugView** – real‑time event stream (`?debug_mode=true`).
- **GTM Preview Mode** – see tag firing and data layer state.
- Browser extensions: GA Debugger, Tag Assistant, dataLayer Inspector.

### 8.2 Validation Checklist
- [ ] Event fires on the correct trigger.
- [ ] All required properties are present and correctly typed.
- [ ] No duplicate events on a single interaction.
- [ ] Works on major browsers and mobile devices.
- [ ] Conversions are recorded in GA4.
- [ ] User ID is sent when the user is logged in.
- [ ] No PII appears in any property.

### 8.3 Common Issues & Fixes
| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Event not firing | Trigger mis‑configured or tag paused | Open GTM Preview, verify trigger conditions |
| Wrong values | Variable not set or data layer push occurs after tag fires | Move dataLayer push earlier or use a custom JavaScript variable |
| Duplicate events | Multiple containers or tag firing on both Click and Form Submit | Consolidate triggers, add a once‑per‑event filter |

---

## 9. Privacy & Compliance
- Implement a consent management platform (CMP) and respect **Consent Mode** in GA4.
- Do not send PII; hash or omit sensitive fields.
- Enable IP anonymization (`'anonymize_ip': true`).
- Set appropriate data‑retention periods in GA4 admin.
- Provide a user‑deletion API integration if required.

---

## 10. GA4 Data Analysis (Audit & Insight)
### 10.1 Authentication (Python)
```bash
export GOOGLE_ANALYTICS_PROPERTY_ID="123456789"
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
```
Install packages:
```bash
pip install google-analytics-data python-dotenv pandas
```
### 10.2 Basic Fetch Example
```python
import os, pandas as pd
from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import DateRange, Metric, Dimension

client = BetaAnalyticsDataClient()
property_id = os.getenv('GOOGLE_ANALYTICS_PROPERTY_ID')

request = {
    "property": f"properties/{property_id}",
    "date_ranges": [DateRange(start_date='30daysAgo', end_date='today')],
    "metrics": [Metric(name='sessions'), Metric(name='bounceRate')],
    "dimensions": [Dimension(name='pagePath')]
}
response = client.run_report(request)

df = pd.DataFrame([r.row.values for r in response.rows], columns=[d.name for d in response.dimension_headers] + [m.name for m in response.metric_headers])
print(df.head())
```
### 10.3 Analysis Checklist
- **Trend Check** – compare last 30 days vs. previous period.
- **Top Pages** – identify high‑traffic pages with high bounce or low engagement.
- **Source/Medium** – surface channels driving conversions.
- **Funnel Gaps** – look for drop‑off between `signup_started` and `signup_completed`.
- **Event Health** – verify that custom events have ≥ 95 % success rate (no missing properties).

### 10.4 Recommendations Template
```
**Insight**: Low conversion rate (2 %) on checkout page.
**Root cause**: High exit rate after ‘payment_info_entered’ event.
**Recommendation**: Add a progress indicator, test alternative payment UI, and ensure ‘payment_info_entered’ fires before form submission.
**Priority**: High
**Expected impact**: +1.5 % conversion lift.
```

---

## 11. Checklist for a Complete Implementation
- [ ] Define business questions and key conversions.
- [ ] Inventory existing tracking and tools.
- [ ] Draft a tracking plan with event table.
- [ ] Agree on naming conventions and property schema.
- [ ] Set up GA4 data streams and enable enhanced measurement.
- [ ] Implement base GA4 Configuration tag in GTM.
- [ ] Add GA4 Event tags (or dataLayer pushes) for each custom event.
- [ ] Configure conversion events in GA4 admin.
- [ ] Create custom dimensions/metrics as needed.
- [ ] Document UTM conventions and share builder link.
- [ ] Test all events in GTM Preview & GA4 DebugView.
- [ ] Validate data quality (no duplicates, correct types, no PII).
- [ ] Implement consent mode and privacy safeguards.
- [ ] Publish GTM container with version notes.
- [ ] Run a GA4 data audit (fetch recent data, compare expected vs. actual).
- [ ] Deliver tracking plan document and ongoing monitoring schedule.

---

## 12. Questions to Clarify Context
- Which analytics platform(s) are you using (GA4, Mixpanel, Amplitude, etc.)?
- What are the primary business decisions you need data for?
- List the key conversion actions you want to measure.
- Who will implement the tags – developers or a marketing team?
- Are there regional consent or GDPR requirements?
- Do you already have a data layer or need one built from scratch?

---

**End of Skill**

## Related skills

Load these when the task spans more than this skill.

- [`conversion-optimization`](../conversion-optimization/SKILL.md) — Conversion Optimization skill guides you through improving conversions for marketing pages, forms, popups, sig…
- [`seo`](../seo/SKILL.md) — SEO provides a complete audit and optimization guide covering technical SEO, on-page elements, content quality…
- [`paid-ads`](../paid-ads/SKILL.md) — Provides a step‑by‑step workflow for planning, creating, testing, optimizing, and scaling paid advertising cam…
- [`product-management`](../product-management/SKILL.md) — A comprehensive product‑management skill that guides product managers, strategists, and agile owners through d…
- [`ab-testing`](../ab-testing/SKILL.md) — A step‑by‑step guide for planning, designing, running, and analyzing A/B (split) tests or multivariate experim…
- [`app-store-optimization`](../app-store-optimization/SKILL.md) — Provides end‑to‑end guidance for researching keywords, optimizing metadata, managing reviews, planning launche…
- [`pricing-strategy`](../pricing-strategy/SKILL.md) — A step‑by‑step framework for SaaS pricing and monetization, covering research methods, value‑metric selection,…
