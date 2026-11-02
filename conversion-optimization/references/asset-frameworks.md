# CRO Asset Frameworks

Per-asset checks for [`../SKILL.md`](../SKILL.md). Read only the section for the asset under audit.

## 1. Page (homepage, landing, pricing, feature, blog)

| Dimension | Check | Quick win |
|---|---|---|
| Value proposition | Visitor gets the core benefit in ≤5 s | Outcome-focused headline; remove jargon |
| Headline | Specific, states core value, matches ad copy | Test numbers or social proof ("Join 12 000+ teams") |
| CTA | One primary CTA above the fold, value copy | "Submit" → "Start Free Trial"; repeat a secondary CTA after key sections |
| Visual hierarchy | Clear H1 → H2 → body, white space, images support message | More spacing, larger benefit text, product screenshots over stock photos |
| Trust signals | Logos, testimonials, review scores near CTA | "Trusted by" strip directly above primary CTA |
| Objections | FAQ, guarantees, pricing clarity | Short FAQ accordion below the fold |
| Friction | Slow load, hidden nav, too many links | Cut page weight; hide nav on single-purpose landing pages |

Test ideas: headline A/B, CTA color, hero image vs. video, "Most Popular" badge on pricing.

## 2. Form (lead, contact, demo, quote, survey, checkout)

- Field cost: 3 fields = baseline; 4–6 → 10–25 % drop; 7+ → 25–50 % drop.
- Essential: email (or phone) + password (signup) + one optional name field.
- Email: one field, inline validation, typo detection, email keyboard on mobile.
- Name: one "Full name" field; split only for personalization.
- Phone: optional, auto-format, country code picker.
- Company: auto-suggest; enrich after submit.
- Choices: searchable dropdown for >5 options; keep labels visible.
- Layout: single column; two columns only for short related fields (first/last name).
- Multi-step: use for >5 fields or logical sections. Progress bar, easy questions first, back navigation, save progress.
- Errors: inline, specific, focus first error, never clear entered data.
- Submit: action + benefit ("Get My Free Quote"), high contrast, ≥44 px.
- Trust: privacy note, security badge, expected response time.
- Mobile: large tap targets, correct keyboards, sticky submit.
- Metrics: start rate, completion rate, field-level drop-off, error rate, time to complete.

## 3. Popup / modal

| Trigger | Setting |
|---|---|
| Scroll | 25–50 % depth (blogs) |
| Exit intent | Desktop: cursor toward close. Mobile: back-scroll or time delay |
| Time delay | 30–60 s after load; never <10 s |
| Click | User-initiated; zero annoyance |
| Behavior | Cart abandonment, pricing-page visit, repeat visit |

- Order: headline > value > form/CTA > close. Width 400–600 px desktop; full-width bottom or centered on mobile.
- Close button always visible plus a "No thanks" link.
- Copy: benefit headline, short subhead, specific CTA, privacy reassurance.
- Frequency: once per session; respect dismiss for 7–30 days.
- Compliance: GDPR consent for personal data; keyboard and screen-reader accessible.
- Metrics: impressions, conversion, close rate, time to close.

## 4. Signup flow

- Essential: email/phone + password. Name optional. Defer company, role, phone to onboarding.
- Put social auth first; it often converts better than email.
- ≤3 fields → single step; >3 → multi-step with progress indicator.
- Trust: "No credit card required", privacy note, security badge, testimonial.
- Errors: inline, clear, keep entered data.
- Mobile: large tap targets, autofill, social auth, sticky CTA.
- After submit: instant confirmation, next-step preview; delay email verification if possible.

## 5. Onboarding

- Define the aha moment: the first action that predicts long-term retention.
- One goal per session; defer secondary features.
- Prefer interactive tasks to static tutorials.
- Checklist: 3–7 high-value items, ordered by impact, progress bar, celebration on completion.
- Empty states: explain purpose, show preview, primary CTA to create the first item.
- Tooltips/tours: ≤5 steps, dismissible, hidden for returning users.
- Multi-channel: welcome email, in-app reminders, timed push (not immediate).
- Metrics: activation rate, time to activation, onboarding completion, Day 1/7/30 retention.

## 6. Paywall / upgrade screen

- Show only after real value (post-aha or at a usage limit).
- Headline: benefit first ("Unlock unlimited projects"), not price first.
- Show value: paid-feature preview, before/after, or ROI example.
- Comparison: key differences only; mark the recommended plan.
- Pricing: simple, annual/monthly toggle, clear per-seat cost.
- CTA: action + benefit ("Upgrade to Pro – Get Unlimited").
- Escape: clear "Maybe later" / "Continue with Free"; no guilt-trip copy.
- Path: in-context upgrade, pre-filled info, few steps, security badges.
- Mobile: full screen is acceptable, swipe to dismiss, large tap targets.
- Frequency: 1–2 prompts per session; cool-down of days after dismiss.
- Metrics: impressions, click-through, upgrade completion, revenue per user, churn after upgrade.
