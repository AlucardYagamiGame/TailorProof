<!--
PR title: Conventional Commits, `type: short summary`, e.g. "docs: add project brief and glossary"
Types: feat, fix, docs, test, refactor, chore, ci
-->

## Summary

<!-- What this PR does and why, in 2-4 sentences. Say what is NOT included if that is not obvious. -->

## Guide step / requirement

<!-- Which step of the course guide, user story or requirement this belongs to (docs/requirements.md). -->

## Changes

<!-- Group by meaning, not by file. One bullet per idea: **Area:** what changed and why. -->

## Verification

- [ ] `npm run lint`
- [ ] `npm run typecheck`
- [ ] `npm run test`
- [ ] `npm run build`
- [ ] `npm run test:e2e` (if a user flow changed)

<!-- What was and was not run. For docs-only changes say so. -->

## Checklist

- [ ] Terms match `docs/glossary.md`
- [ ] `docs/architecture/` updated if decisions, endpoints, data model or structure changed
- [ ] Tests added for new behaviour
- [ ] No secrets committed; `.env.example` has only fake values

## Notes

<!-- Open questions, follow-ups, things not done or not verified. -->
