Status: planned — do not implement as part of the MVP

# Feature: AI interview coach

The MVP already contains a narrow **AI analyst** (see [docs/requirements.md](../requirements.md), 5.5): it helps only with a disputed pair, and only after the user asks. This feature widens the use of the same connection (the user's own OpenRouter account, free models first, model fallback, loader and failure messages) to interview preparation, which pitches-peaches does not grade and TailorProof can.

## User stories

1. As a job seeker, I want realistic interview questions for this posting, built from its Requirements and from my Gaps, each with a reference answer made only of my own resume's facts (or an honest note that a fact is missing), so that I know what to say and what I cannot say.
2. As a job seeker, I want to go through the questions one by one like in a chat, get short feedback after each answer (level weak / okay / strong, what is missing, how to say it better) and a summary at the end, so that I see how strong my answers are.
3. As a job seeker, I want the feedback to point at my own facts and to flag claims my resume does not support, so that I do not promise what I cannot back up.

## Rough acceptance criteria

- Each question is tied to a Requirement of the posting (with its quote from the posting) or to a Gap. A question with no such tie is dropped.
- A reference answer contains only facts that have a Quote in the resume or in the user's answers. A missing fact is listed under "missing facts" and never invented.
- The quiz level is computed by code: the model proposes rubric criteria; a criterion counts only when a Quote from the user's answer (and a fact from the resume) backs it; the level follows the share of criteria met (proposed: weak below 40 %, okay 40–74 %, strong 75 % and above). A claim in an answer that no fact supports is flagged.
- Feedback is on the user's side: no "claims to have", no doubt about the resume; caution only about the company and the posting.
- With no AI connected, or when every model fails, the app shows the same failure message as in the MVP and the rest keeps working.
- Free limits (20 requests per minute, 50 per day) are counted and shown; a quiz answer costs one request, and a question set costs a few.
- Nothing is stored between sessions unless the owner saves it in Personal mode.

## What it touches

- **API:** an endpoint for building the question set and one for grading an answer; both reuse the AI analyst's connection, model fallback and states.
- **Engine:** the rubric scoring and the check that every reference answer fact has a Quote (`verifyQuote`).
- **Data:** none new in the MVP's storage; optionally quiz history per Application in Personal mode later.
- **UI:** a "Prepare for the interview" panel with a chat-style quiz and a summary.

## Constraints

- No model output is shown as true without a verified Quote.
- Small free models may produce weaker questions and feedback than paid ones; a paid model through the user's own OpenRouter credits is the upgrade path.
- Interview answers are practised in English.
