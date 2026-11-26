---
description: Write the pull request description from the commits and diff, using the PR template, and open the PR
---

Prepare a pull request for the current branch. Base branch: $ARGUMENTS (default `master`).

Current branch and commits not in the base:

!`git branch --show-current`

!`git log --reverse --format='%h %s%n%b' master..HEAD`

Diff summary:

!`git diff --stat master...HEAD`

Steps:

1. Read `.github/pull_request_template.md` and fill every section. Keep its headings and order.
2. Read the actual diff (`git diff master...HEAD`) and the docs it touches. Understand what changed and why before writing.
3. Write for a reviewer, not a file list:
   - **Summary:** 2-4 sentences: what and why, and what is NOT included.
   - **Guide step / requirement:** the step of the course guide or the user story from `docs/requirements.md`.
   - **Changes:** group by meaning (for example "Requirements and glossary", "Architecture", "Agent tooling"), one bullet per idea: **Area:** what changed and why. Never list files one by one; name a file only when it is the point.
   - **Verification:** tick only the commands you ran now, and say what was not run (for example "docs only, nothing to run").
   - **Checklist:** tick only what is true; if not checked, leave it unticked and say so.
   - **Notes:** open questions, follow-ups, anything unverified.
4. Use the terms from `docs/glossary.md`. Do not invent facts: if you do not know the guide step, ask.
5. Show me the full title and description first. The title MUST follow Conventional Commits: `type: short summary` in lower case, imperative, no full stop, types only `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`. Choose the type by what the PR mostly does (docs only → `docs`; tooling or config → `chore`; GitHub automation → `ci`). If the commits do not follow Conventional Commits, tell me which ones. Only after I confirm, run `gh pr create --base <base> --title "<title>" --body-file <file>`. Never push without my confirmation.
