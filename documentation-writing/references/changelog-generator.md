# Changelog Generator

Automatically creates a polished, user‑oriented changelog from the git commit history of a project.

## When to Use
- Preparing release notes for a new version.
- Summarising weekly or monthly product updates.
- Writing changelog entries for app‑store submissions or email notifications.
- Maintaining a public `CHANGELOG.md` page.

## Workflow
1. **Open a terminal** in the root of the git repository.
2. **Choose a scope**:
   - `last release` – commits since the most recent tag.
   - `date range` – commits between two dates (e.g., `2024-03-01` to `2024-03-15`).
   - `time window` – commits from the past *n* days.
3. **Run the generator** (replace placeholders with your values):
   ```bash
   changelog-generator \
       --since v2.4.0            # start point (tag, commit SHA, or date)
       --until v2.5.0            # end point (optional, defaults to HEAD)
       --style CHANGELOG_STYLE.md # optional file with formatting rules
       --output CHANGELOG.md      # file to write, defaults to stdout
   ```
4. **Review** the generated markdown. Adjust wording or ordering to match brand voice.
5. **Commit** the updated `CHANGELOG.md` (or other target file) to the repository.

## Rules & Decision Criteria
- **Commit classification**
  - `feat:` → **New Features**
  - `fix:` → **Bug Fixes**
  - `perf:` or `refactor:` → **Improvements**
  - `BREAKING CHANGE:` or `!` in the header → **Breaking Changes**
  - `security:` → **Security**
- **Noise filtering**
  - Exclude commits that only contain `chore:`, `test:`, `docs:` without user impact.
  - Optionally provide a regex list of patterns to ignore.
- **User‑friendly translation**
  - Keep the core action (e.g., *Add team workspaces*).
  - Remove internal identifiers, file paths, and code snippets.
  - Use present‑tense, active voice, and concise phrasing.
- **Formatting**
  - Top‑level heading: version or period (e.g., `# Updates – Week of March 10, 2024`).
  - Sub‑headings for each category, prefixed with an emoji or icon if desired.
  - Bullet list for individual items.
  - Preserve markdown links or references when they add value for the user.

## Patterns & Templates
```markdown
# <Title> – <Period or Version>

## ✨ New Features
- **<Feature Name>**: <Brief user‑focused description>.

## 🔧 Improvements
- **<Component>**: <What is faster, more reliable, etc.>.

## 🐛 Bug Fixes
- Fixed <issue description>.

## ⚠️ Breaking Changes
- <What changed> requires <action> from users.
```
- Use the same heading style throughout the document.
- Align bullet indentation to two spaces for readability.

## Pitfalls & Mitigations
- **Non‑standard commit messages** – The generator may mis‑categorise. Encourage developers to follow Conventional Commits.
- **Large commit batches** – Too many items can overwhelm readers. Consider grouping minor fixes under a single bullet.
- **Missing `CHANGELOG_STYLE.md`** – Without a style file, defaults may not match brand guidelines. Provide a minimal template if none exists.
- **Automatic translation errors** – Always review generated text; AI‑based rewrites can miss nuance.

## Checklist
- [ ] Run from the repository root.
- [ ] Specify the correct start point (`--since`).
- [ ] Provide an end point if you do not want HEAD (`--until`).
- [ ] Include a style file for consistent formatting (`--style`).
- [ ] Verify that noisy commits are filtered out.
- [ ] Review the markdown for clarity and brand tone.
- [ ] Save the output to `CHANGELOG.md` or the appropriate file.
- [ ] Commit the updated changelog to version control.
