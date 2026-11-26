# Product Requirements

> **Status:** draft

This file describes **what** TailorProof must do. AI agents read it before planning or implementing anything (it is loaded automatically through `CLAUDE.md`), so clear requirements lead to better code. Write it in English.

Keep **how** it is built (technical decisions) in `docs/architecture.md`. Words are defined in `docs/glossary.md`: use them exactly. Sample data is in `data/seed.json` and `data/dictionary.seed.json`.

---

## 1. Product overview

**TailorProof** adapts one resume to one job posting **without inventing anything**. It reads the resume, compares it with the posting using **association dictionaries stored in a database** (terms, aliases, relations), shows a match percentage and which requirements are proven, asks the user whenever a relation is unclear, applies only the changes the user accepts, and hands the result back as a file of the same type, as a PDF, or on the screen.

Rules that shape the whole product:

1. **No invention.** Nothing is added to the resume without the user's "yes". Every change shows its source: a quote from the user's own resume, a dictionary relation with a source link, or the user's own answer.
2. **The core works without AI.** The match, the highlights, the suggestions and the outputs are computed by code from the dictionary. An AI analyst (free OpenRouter models) is called **only** for a disputed pair that the dictionary does not cover, and **only** if the user chooses to ask it.
3. **Privacy.** The resume is read and edited in the browser. It leaves the browser only in the PDF step (the edited DOCX, kept in memory, never stored or logged) and, if the user agrees, as one sentence sent to the AI analyst.
4. **The user decides.** Disputed questions are the user's to solve, to hand to the AI analyst, or to skip.

The idea is inspired by the open-source project pitches-peaches (MIT): its match structure (four dimensions, bands, gaps as coverage and not credibility, "ask first, then score once", "everything the user says is true") is followed here, with a deterministic engine instead of a language model.

## 2. Users

A **job seeker** who adapts one resume to many postings. There is a single role and there are no accounts. The texts are in English.

The application runs in two modes, controlled by `ALLOW_WRITES`:

- **Demo mode** (`ALLOW_WRITES=false`, the default): nothing the user types is stored. The dictionary is read-only. This is what a public deployment runs.
- **Personal mode** (`ALLOW_WRITES=true`): the owner can import and edit the dictionary and save resumes, postings and Applications in the database.

## 3. User stories

Input

1. As a job seeker, I want to add my resume as a file (DOCX, Markdown, TXT), as a screenshot, or by typing it section by section, so that I can start from whatever I have.
2. As a job seeker, I want to see what the app read from my file in editable fields, and a warning when the layout (tables, columns) may be read badly, so that I can fix mistakes before the analysis.
3. As a job seeker, I want to give the posting as a link or as text, and be moved to typing it when the link cannot be read, so that a blocked page never stops me.

Match

4. As a job seeker, I want a match percentage and a report before any change (requirements proven with a quote, gaps with a reason), so that I know where I stand.
5. As a job seeker, I want the posting text highlighted green, orange and red in the interface, so that I see at a glance what my Skills prove, what is only in my projects, and what is missing.
6. As a job seeker, I want to be asked when a relation between the posting and my resume is unclear, and to choose to answer myself, ask the AI analyst, or skip, so that nothing is guessed for me.

Adjust

7. As a job seeker, I want to accept or reject every suggested change (a synonym replaced by the posting's wording, a concept named next to a tool, a technology added to Skills, lines reordered, filler removed), so that the resume matches the posting without invented facts.
8. As a job seeker, I want to see the match percentage again after the changes, calculated on the adjusted text, so that I see what the changes gained.

Output and session

9. As a job seeker, I want to choose the output (PDF only, same file type plus PDF, same file type only, or no files), and always see the final summary on the screen, so that I get what I need.
10. As a job seeker, I want to clear the session at any time, and have it cleared when I reload or close the tab, but never just because the result was delivered, so that my data does not stay behind and I do not lose my result by accident.

Owner

11. As the owner (Personal mode), I want to import dictionaries from open datasets and edit them in the database, and save resumes, postings and Applications, so that matching improves over time.
12. As a visitor with no AI connection, I want everything except the AI analyst to work, so that I can try the app without connecting anything.

## 4. Scope

### In scope (MVP)

- **Input:** resume as a file (DOCX, Markdown, TXT), as an image (screenshot, read by OCR in the browser) or typed by sections; posting as a link (fetched by the server) or as text.
- **File reading** into editable fields, a **layout warning** for tables, columns and text boxes, and a read-failure path to manual entry.
- **Skills required**; projects, portfolio, experience, education optional (see "Optional experience").
- **Match** by the dictionary: match percentage before and after, four dimensions, band, gaps, gate recommendation.
- **Highlight** of the posting: green, orange, red.
- **Clarifications** and the **disputed choice**; the **AI analyst** (OpenRouter, user's own account, free models, model fallback, loader and failure message).
- **Suggested changes**, each accepted or rejected, each with its source.
- **Output choice** (4 variants) with the PDF made by LibreOffice on the server; the final summary on the screen always.
- **Session reset** by button, reload or tab close.
- **Dictionary in the database**, imported and edited by the owner (Personal mode); read-only in Demo mode.
- **Applications** (a saved resume + posting pair with its adjusted result), Personal mode only.

### Out of scope

- User accounts and logins of our own.
- A local model; the site owner's own AI key.
- Automatic submission of applications.
- PDF as an **input** file (it cannot be edited without losing its look; a PDF screenshot can be given as an image).
- Non-English texts (Ukrainian included).
- Company research, red flags of the posting, interview questions and the quiz: planned, see [docs/features/ai-assistant.md](features/ai-assistant.md).
- Access through MCP.
- Remembering the user's one-off answers to disputed questions between sessions.

### Constraints and documented limitations

- **English only.** Technical postings only: only skills known to the dictionary are checked.
- **Paraphrase is not recognised** unless the dictionary relates the words. An unknown pair becomes a disputed question for the user.
- **A match proves a mention, not a skill level.** The match percentage is a score by the dictionary and its rules, not a chance of getting the job.
- Free OpenRouter models have limits (20 requests per minute, 50 per day for accounts that have bought less than $10 of credits) and may be slow or unavailable; the app must keep working without them.
- Some posting pages cannot be read by the server (login, scripts, blocking); manual entry is always available.
- Tables, columns and text boxes in a resume may be read with mistakes, and changes touching them are not written to the file automatically.
- OCR of screenshots can be wrong; the user checks the result.

## 5. Rules and acceptance criteria (draft)

The precise criteria are written in Step 4 with the analyst. This section fixes the rules that the stories depend on.

### 5.1 Input

- **Skills are mandatory.** Without a Skills section (read from the file, typed, or entered after the app could not find it) the analysis does not start. The analysis rests on Skills when nothing else is given.
- **Reading a file** fills the fields of Skills, Experience, Projects, Portfolio, Education, Languages and Links, recognising sections by headings from the dictionary. Text that cannot be assigned goes to "Other" and takes part in the analysis with the lowest weight. The user can edit every field before the analysis; edits become changes in the output.
- **Read failure** (corrupt, empty, password-protected or unsupported file) shows an error with the reason and leads to manual entry.
- **Layout warning.** Right after reading, if the file contains tables, columns or text boxes, the app shows a warning that the part may be read with mistakes and that many ATS read such layouts badly, and recommends a one-column resume without tables. Buttons: "Skip warning" (the file is parsed as it comes out), "Upload another file", "Enter manually". Text read from those places is marked "check". Changes inside tables, columns and text boxes are not written to the file automatically; they are shown on the screen for manual transfer.
- **Screenshots.** PNG, JPG or WebP, or pasted from the clipboard, read by OCR in the browser. A loader shows progress. Lines with low confidence are marked "check". If nothing can be read, the app shows "Could not read the text from the image" with the reason and leads to manual entry. The image never leaves the browser.
- **Optional experience.** A switch "I have no work experience". Only when there is none, the app offers (with a fixed text, without AI) to add even irrelevant experience (any job, part-time work, volunteering, study projects), with "Add" and "Skip". If skipped, the section is left out of the output (no empty heading) and the analysis runs on the other sections; requirements that need experience ("3+ years") remain gaps. Irrelevant experience that was added takes part in the match and is placed last in the output, marked "possibly irrelevant".
- **Posting.** A link is fetched by the server. If it cannot be read (network error, non-200, login page, not HTML, empty or too short text, no recognisable description), the app switches to manual entry and says why. The fetched text is always shown in an editable field.

### 5.2 Match logic

Follows pitches-peaches (`models.py`, `stages/match.py`, `prompts/match.md`, `probes.md`, `gate.md`, `quotes.py`), computed by code from the dictionary:

- **Ask first, then score once.** Clarifications come before the final score. The user's answers count as source text, like the resume.
- **Everything the user says is true.** No doubt is expressed about the resume or the answers; caution is only about the posting and the company.
- **A gap is coverage, not credibility:** only two states, present in the record or absent.
- **Evidence sources have priority.** A mention in **Skills** is the preferred quote and counts fully (weight 1.0); a mention only in projects, portfolio or experience counts less (proposed weight 0.7, one constant in one visible place). Accepting "add to Skills" raises the weight to 1.0.
- **Four dimensions, always all present:** technical, ownership, delivery, business context (0–100), an **overall** score and a **band**: strong ≥ 80, possible ≥ 55, weak below. The thresholds live in one visible function.
- Proposed formulas (to be confirmed against the original's fixtures): technical = share of proven requirements (must-have 70 %, nice-to-have 30 %); ownership = share of lines near matches that contain ownership verbs from the dictionary; delivery = share of such lines with a number or a delivery verb; business context = overlap of domain terms (shown as "n/a" when the posting names no domain); overall = weighted mean with visible weights.
- **Fit points** carry a verbatim quote; every quote passes `verifyQuote`.
- **Gaps and prepare**, and a **gate recommendation** (apply, apply with caveats, do not apply) with a short reading of the shape of the four scores and, for "do not apply", things to build first (fixed texts).
- The percentage shown before and after is the overall score computed by the same function on the original and on the adjusted text, plus the share of requirements proven. A *literal* figure (the posting's exact words are present) and a figure *through the dictionary* (aliases and relations counted) are both shown.

### 5.3 Highlight (interface only, never in a file)

- **Green:** the requirement's technology is in the Skills section. **Orange:** it is not in Skills but is mentioned in projects or portfolio (assumed: experience too). **Red:** it is nowhere in the resume.
- Colour is never the only sign: each requirement has a mark (✓, ~, ✗) and a text hint for screen readers. Clicking a green or orange requirement shows the quote and the section where it was found.
- Orange suggests an action: "Kafka is mentioned in project X but is not in Skills. Add to Skills?" This is a change the user accepts or rejects.
- Highlights update after the user's answers.

### 5.4 Clarifications and disputed questions

- **Safe automatically, no question:** an alias is replaced by the posting's wording; a tool in the resume covers a concept the posting asks for (relation `implements`, with a source).
- **Clarification** where the dictionary sees a related but not identical technology (relation `related`, or the resume names only the concept). Example: the posting asks for Redux Toolkit, the resume says "state manager" or Zustand. The app asks "Did you work with Redux Toolkit?" with **Yes** (change or add it), **No** (keep the user's own wording, for example "state management (Zustand)") and **Both**. Without an answer there is no change.
- **Disputed pair** (the dictionary knows nothing about the pair). The app first asks how to continue, with three choices, and starts none by itself:
  - **"I'll decide"** — the user answers (Yes/No, or which line to keep, or how to name it). No model call.
  - **"Ask the AI analyst"** — only after this click the model is called (see 5.5).
  - **"Skip"** — nothing changes; what the user had stays; the requirement stays open (colour and percentage unchanged).
  When no AI is connected only "I'll decide" and "Skip" are shown, with a hint that the AI analyst can be connected.
- The user's decisions apply to this session only and are not remembered; only the owner changes the dictionary.

### 5.5 AI analyst

- Called only for a disputed pair, only after the user chose "Ask the AI analyst". It finds the resume line that may answer the requirement and proposes a question and wording options; the user accepts or rejects them. The model's answer never changes the file without confirmation, and code checks that a proposal introduces no technology or number beyond the user's answer.
- Only one resume sentence and one requirement are sent, with a preview shown to the user; never the whole resume.
- **Connection:** the user's own OpenRouter account (OAuth PKCE). The key lives only in server memory with an expiry, tied to an `httpOnly` cookie, and never reaches the browser, a log or the database.
- **Model fallback:** a list of free models from OpenRouter's public models list (cached; a fallback list in configuration). One call is one attempt with a timeout; the client switches to the next model on timeout, upstream error, invalid answer or a per-minute limit, skips a model that just failed (cooldown), tries at most 3 models within about 45 seconds, and has a "Cancel" button. A daily limit does not switch models.
- **While waiting** the user sees a loader and text such as "Loading the AI analyst… (model X, attempt 2 of 3)" (`role="status"`).
- **When every attempt fails or OpenRouter is unreachable** the user sees "Could not reach the AI analyst to clarify the unknown technology." with the reason when known (limit reached, network, not connected), and returns to the choice "I'll decide", "Skip" or "Try again". The app is never blocked by the AI.

### 5.6 Output choice

- Default: **same file type + PDF**. Variants: PDF only; same type + PDF; same type only (no PDF); no files (screen only). For a screenshot or a typed resume the file is built in the chosen format (DOCX, Markdown or TXT) from a built-in template.
- The **final information is always shown on the screen**: the percentages before and after, the list of changes with sources, the adjusted text.
- The PDF step is the only one where the resume file goes to the server; without PDF the resume stays in the browser (apart from the confirmed sentence for the AI analyst and the posting link, if one was pasted).

### 5.7 Session reset

- The session is cleared only when the user presses "Clear session", **reloads** the page or **closes** the tab. Delivering files or showing the result never clears it.
- Clearing returns the app to the state of a first launch: resume, posting, results, answers, the dictionary cache and output settings in the browser, the OpenRouter key and the cookie on the server. Records saved in Personal mode in the database are not part of the session and are deleted separately.
- All client state lives only in the page's memory (nothing in `sessionStorage`, `localStorage` or IndexedDB). The server AI session is ended on `pagehide` (best effort) and when the page loads; an idle expiry (proposed 30 minutes) is the backstop.

## 6. Data

- **Resume** (in the browser; saved only in Personal mode): sections Skills (required), Experience (optional: company, role, period, bullets), Projects (name, stack, bullets), Portfolio (links or text), Education, Languages, Links, Other (unassigned). Title, 100 characters at most.
- **Vacancy**: company (optional), title, text (30–20,000 characters after trimming), source (link or manual).
- **Dictionary** (database; read by the browser as one compiled object): Term (id slug, name, kind: technology, concept or domain, `caseSensitive`), Alias, Relation (`implements` or `related`, from, to, **source link required**, status), plus lists: fluff words, ownership verbs, delivery verbs, section headings (resume and posting), navigation lines, negation and aspiration patterns, marker words.
- **Application** (Personal mode): a resume + posting pair and its adjusted result. Answers to clarifications are not stored.
- **Analysis** (requirements, evidence, gaps, percentages, dimensions, highlights, changes) is derived and never stored.

## 7. Open questions

- **Interface language.** The original brief says everything is in English, while the exact messages were first discussed in Ukrainian. Default: English interface; confirm.
- **"Outside Skills" for orange.** Does orange also cover work experience (assumed), or only projects and portfolio?
- **Evidence weight outside Skills** (proposed 0.7) and the dimension formulas: confirm against the original's fixtures in the spike.
- **Dictionary sources and licences.** ESCO and Stack Overflow tag synonyms are the intended open datasets; their licences (for example share-alike) are not checked yet.
- **Deployment.** LibreOffice in Docker on Render's free plan (memory, startup time) is not checked. The OpenRouter key in server memory is lost when the service sleeps; the user reconnects.
- **Posting links.** Which sites can be read at all (many block robots) and what their terms allow.
- **Tables and columns in DOCX.** Whether changes inside them can ever be written safely, or stay manual transfer.
- **Effort.** The scope is far larger than the starter's "few evenings" MVP. The order of work is set by dependencies; the last items (Applications, dictionary editing screen) are the first to stay unfinished.
