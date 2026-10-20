---
name: app-store-optimization
description: "This skill guides keyword research, metadata optimization, review management, launch planning, and performance tracking for mobile apps on Apple App Store and Google Play Store. Use when researching ASO keywords, optimizing app title subtitle short description full description keyword field, localizing store listings, analyzing competitor rankings review sentiment category trends, improving conversion rates with screenshots videos icons, planning soft launch global rollout, monitoring install velocity retention ratings, or responding to user feedback on iOS Android."
---

# App Store Optimization (ASO)

This skill helps you research keywords, improve store listings, manage reviews, plan launches, and track performance for mobile apps on Apple App Store and Google Play Store.

## When to use
- Before launching a new app or major update.
- When you need to increase organic discoverability.
- When you want to improve conversion from store view to install.
- When you need to monitor competitor strategies or user sentiment.

---

## 1. Research & Analysis
### Keyword research
- Gather search volume estimates, competition level, and relevance scores.
- Prioritize keywords with high relevance and medium‑to‑low competition.
- Include long‑tail phrases (3‑4 words) for niche traffic.
- Re‑search quarterly to capture trend changes.

### Competitor analysis
- Identify top 10 competitors in your category.
- Extract their titles, subtitles, descriptions, and visual assets.
- Compare keyword overlap and visual asset styles.
- Note gaps where competitors rank poorly.

### Market trend analysis
- Use industry reports or app store charts to spot emerging categories.
- Align new features or messaging with identified trends.

### Review sentiment analysis
- Pull recent user reviews (last 30‑90 days).
- Compute positive/negative/neutral ratios.
- Extract common issues and feature requests.

### Category analysis
- Evaluate primary and secondary category options.
- Choose categories with high traffic and lower competition.

---

## 2. Metadata Optimization
### Title & Subtitle (Apple) / Short Description (Google)
- Keep within platform character limits (Apple title 30 chars, subtitle 30 chars; Google title 50 chars, short description 80 chars).
- Front‑load the most important keyword.
- Ensure the title reads naturally for users.

### Full Description
- Use up to 4,000 chars on both stores.
- Structure: brief hook → key benefits → feature list → call‑to‑action.
- Maintain a keyword density of 1‑2 % for target terms.

### Apple keyword field
- 100 chars, comma‑separated, no spaces.
- Include only unique, relevant keywords; avoid plurals and duplicates.

### Visual assets
- **Icon**: 1024 × 1024 px, recognizable at 60 × 60 px.
- **Screenshots**: First 2‑3 are most impactful; add captions that convey value.
- **Preview video**: 15‑30 seconds, highlight core benefit.

### Localization
- Target high‑value markets first (e.g., English, Spanish, Chinese, French, German).
- Translate metadata with native speakers.
- Adjust keywords per locale; re‑validate character limits.

---

## 3. Conversion Optimization
- Plan A/B tests for titles, screenshots, icons, and videos.
- Define hypothesis, test variable, duration, and success metric (e.g., lift in conversion rate).
- Use a minimum sample size that gives 95 % confidence (calculate based on daily impressions).
- Iterate based on test results; update winning assets.

---

## 4. Rating & Review Management
- Monitor new reviews daily.
- Respond to 1‑star and 2‑star reviews within 24‑48 hours with a courteous, solution‑focused tone.
- Thank 4‑star and 5‑star reviewers.
- Use identified issues to prioritize bug fixes or feature improvements.
- Encourage rating prompts after a positive user action.

---

## 5. Launch & Update Strategies
### Pre‑launch checklist
- Verify all required assets (icons, screenshots, video) meet size and format specs.
- Confirm metadata complies with store guidelines.
- Test the app on a range of devices and OS versions.
- Prepare press release and social assets.

### Launch timing
- Aim for days with historically higher traffic in target markets (e.g., Tuesdays for US).
- Avoid major holidays unless you have a seasonal hook.

### Update cadence
- Release minor updates every 4‑6 weeks to signal activity.
- Include “What’s New” text that highlights a key benefit.
- Refresh visual assets after major feature releases.

### Seasonal optimization
- Align screenshots and copy with holidays or events (e.g., “Back to School”).
- Adjust keywords to capture seasonal search spikes.

---

## 6. Analytics & Tracking
- **ASO health score** (0‑100) composed of:
  - Metadata quality (0‑25)
  - Ratings & reviews (0‑25)
  - Keyword performance (0‑25)
  - Conversion metrics (0‑25)
- Track keyword rankings weekly.
- Monitor impression‑to‑install conversion rate; aim for > 5 % for high‑traffic keywords.
- Measure download velocity (downloads per day) to spot momentum.
- Benchmark against category averages.

---

## 7. Platform‑Specific Requirements
| Feature | Apple App Store | Google Play Store |
|---|---|---|
| Title | 30 chars | 50 chars |
| Subtitle / Short description | 30 chars (subtitle) | 80 chars (short description) |
| Promotional text (editable) | 170 chars | N/A |
| Full description | 4,000 chars | 4,000 chars |
| Keyword field | 100 chars, comma‑separated | No separate field (keywords derived from title & description) |
| “What’s New” | 4,000 chars | 4,000 chars |

---

## 8. Input Formats (JSON examples)
### Keyword research request
```json
{
  "app_name": "MyApp",
  "category": "Productivity",
  "target_keywords": ["task manager", "productivity", "todo list"],
  "competitors": ["Todoist", "Any.do", "Microsoft To Do"],
  "language": "en-US"
}
```
### Metadata optimization request
```json
{
  "platform": "apple",
  "app_info": {
    "name": "MyApp",
    "category": "Productivity",
    "target_audience": "Professionals 25‑45",
    "key_features": ["Task management", "Team collaboration", "AI assistance"],
    "unique_value": "AI‑powered task prioritization"
  },
  "current_metadata": {
    "title": "Current Title",
    "subtitle": "Current Subtitle",
    "description": "Current description..."
  },
  "target_keywords": ["productivity", "task manager", "todo"]
}
```
### Review analysis request
```json
{
  "app_id": "com.myapp.app",
  "platform": "apple",
  "date_range": "last_30_days",
  "rating_filter": [1,2,3,4,5],
  "language": "en"
}
```
### ASO score calculation request
```json
{
  "metadata": {
    "title_quality": 0.8,
    "description_quality": 0.7,
    "keyword_density": 0.6
  },
  "ratings": {
    "average_rating": 4.5,
    "total_ratings": 15000
  },
  "conversion": {
    "impression_to_install": 0.05
  },
  "keyword_rankings": {
    "top_10": 5,
    "top_50": 12,
    "top_100": 18
  }
}
```
---

## 9. Workflow Overview
1. **Research** – Run keyword and competitor analysis. Identify primary and secondary keywords.
2. **Draft metadata** – Use keyword list to craft title, subtitle/short description, and full description. Validate character limits.
3. **Design visual assets** – Create icon, screenshots, and preview video following best‑practice dimensions.
4. **Localize** – Translate and adapt metadata for target markets.
5. **Submit** – Upload assets and metadata to the store console.
6. **Monitor** – Track rankings, conversion, and reviews daily for the first two weeks.
7. **Iterate** – Run A/B tests on under‑performing elements, update metadata, and respond to reviews.

---

## 10. Best Practices
- **Keyword placement** – Put the most important keyword at the start of the title and early in the description.
- **Natural language** – Write for users first; avoid keyword stuffing.
- **Use every character** – Fill all allowed characters in title, subtitle, and keyword field.
- **A/B test continuously** – Test one variable at a time; run tests until statistical significance is reached.
- **Prompt for ratings** – Ask for a rating after a successful user action, not on launch.
- **Update regularly** – Refresh copy and visuals with each major release.
- **Monitor sentiment** – Treat recurring negative themes as priority bugs.
- **Measure ROI of localization** – Track downloads per locale to decide where to invest further.

---

## 11. Common Pitfalls
- Targeting high‑volume keywords with no relevance – leads to low conversion.
- Leaving spaces or duplicates in Apple’s keyword field – causes rejection.
- Ignoring the first three screenshots – users often decide before scrolling.
- Changing metadata too frequently on Apple – each change requires a new app version.
- Running A/B tests with insufficient traffic – results are inconclusive.
- Responding to reviews with generic templates – can appear insincere.
- Forgetting to update “What’s New” after each release – loses re‑engagement opportunity.

---

## 12. Checklist
- [ ] Define primary and secondary keywords.
- [ ] Validate title, subtitle, and keyword field lengths.
- [ ] Write a benefit‑focused description (≤ 4,000 chars).
- [ ] Create icon (1024 × 1024 px) and 3‑5 screenshots with captions.
- [ ] Produce a 15‑30 s preview video (optional but recommended).
- [ ] Localize metadata for target languages.
- [ ] Prepare “What’s New” text for the upcoming version.
- [ ] Submit assets and metadata to store console.
- [ ] Set up daily monitoring of rankings, conversion, and reviews.
- [ ] Plan first A/B test (e.g., icon vs. screenshot).
- [ ] Respond to new reviews within 48 hours.
- [ ] Review performance after 14 days and iterate.

## Related skills

Load these when the task spans more than this skill.

- [`seo`](../seo/SKILL.md) — SEO provides a complete audit and optimization guide covering technical SEO, on-page elements, content quality…
- [`conversion-optimization`](../conversion-optimization/SKILL.md) — Conversion Optimization skill guides you through improving conversions for marketing pages, forms, popups, sig…
- [`market-research-reports`](../market-research-reports/SKILL.md) — Generate comprehensive 50+ page market research reports with consulting-style analysis, strategic frameworks (…
- [`analytics-tracking`](../analytics-tracking/SKILL.md) — Provides a complete workflow for planning, implementing, auditing, and analyzing analytics tracking (GA4, GTM,…
- [`copywriting`](../copywriting/SKILL.md) — Creates clear, compelling marketing copy for webpages (home, landing, pricing, feature, about, product) and pr…
- [`react-native-expo`](../react-native-expo/SKILL.md) — Provides production‑ready patterns for building React Native apps with Expo (architecture, navigation, state,…
- [`flutter`](../flutter/SKILL.md) — Provides expert guidance for building high‑performance, multi‑platform Flutter apps with Dart 3. Use it for ar…
