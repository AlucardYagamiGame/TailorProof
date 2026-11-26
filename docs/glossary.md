# Glossary

> **Status:** draft

The words of TailorProof and what exactly they mean in **this** app. AI agents read this file before every task (it is loaded through `CLAUDE.md`). Models can mix up similar words — a clear glossary stops them from mixing up concepts in code, UI and tests.

## How to use it

- One row per term: the word, what it means here, what it must **not** be confused with, and its name in code.
- Use these exact words everywhere: requirements, UI texts, code, tests. If you rename a term, change it here first.
- **Resume** is the only word for the user's document. Do not use "CV" in code or UI.
- The web application is called **the app** (or TailorProof). The capitalized **Application** always means a saved Resume + Vacancy pair.

## Terms

### Input

| Term | Meaning in this app | Not to be confused with | In code |
| --- | --- | --- | --- |
| Resume | The user's document, read into sections. The source of truth for every Change. | Application: a Resume saved together with a Vacancy. "CV": not used. | `Resume` type |
| Vacancy | One job posting: title, company, text, and its source. | Application. | `Vacancy` type |
| Vacancy source | How the Vacancy text arrived: a link (fetched by the server) or typed or pasted by hand. | Parse failure. | `VacancySource` |
| Parse failure | A link that could not be turned into a Vacancy text (network error, non-200, login page, not HTML, empty or too short, no description found). The app switches to manual entry. | Read failure: about a Resume file. | `ParseFailure` |
| Section | One named part of a Resume: Skills, Experience, Projects, Portfolio, Education, Languages, Links, or Other. | Section of a Vacancy (a heading group such as Requirements). | `ResumeSection` |
| Skills | The Resume section that lists technologies. **Mandatory**: the analysis rests on it. | Projects, Portfolio, Experience (other Evidence sources). | `skills` |
| Optional section | A Section the user may leave out; the left-out Section is not written to the output file. Experience is the main case. | Skills (mandatory). | `optional` |
| Unassigned text ("Other") | Text of a Resume file that could not be put in any Section. It still takes part in the match, with the lowest weight. | A Section with a name. | `other` |
| Manual entry | The user types the Resume by Section, or types the Vacancy text, instead of giving a file or a link. | File reading. | `manual` |
| File reading | The app reads a Resume file in the browser and fills the fields by Section. | OCR: reading an image. | `reader` |
| OCR | Reading text from an image (a screenshot) in the browser. | File reading. | `ocr` |
| Read failure | A Resume file or image that could not be read (corrupt, empty, password-protected, unsupported, nothing recognised). The app shows the reason and leads to manual entry. | Parse failure: about a link. | `ReadFailure` |
| Layout warning | The warning shown right after reading when the Resume has tables, columns or text boxes: the part may be read with mistakes and many ATS read such layouts badly. The user can skip it. | Read failure. | `LayoutWarning` |

### Dictionary

| Term | Meaning in this app | Not to be confused with | In code |
| --- | --- | --- | --- |
| Dictionary | The data the engine uses, kept in the database: Terms, Aliases, Relations, fluff words, verbs, headings, patterns. Edited only by the owner. | Seed: sample resumes and postings. | `dictionary`, `dictionary.seed.json` |
| Term | One entry of the Dictionary: a technology, a concept or a domain. It can appear in a Vacancy and in a Resume. | Requirement: a Term found in a Vacancy. | `Term` type |
| Alias | Another spelling of the same Term (`k8s` for Kubernetes). It means exactly the same thing and is replaced by the Vacancy's wording automatically. | Relation: a link between different Terms. | `aliases` |
| Relation | A sourced link between two Terms: `implements` or `related`. A source link is required. | Alias. | `Relation` type |
| `implements` | One-way: a tool provides a concept (Redux Toolkit implements state management). A tool in the Resume covers the concept the Vacancy asks for, never the other way round. One step only. | `related`. | `implements` |
| `related` | Two Terms that are close but not the same (Redux Toolkit and Zustand, PostgreSQL and MySQL). It never counts as a match; it leads to a Clarification. | `implements`; Alias. | `related` |
| Relation source | The link that backs a Relation. The owner reviews it before the Relation is used. | Evidence source. | `sources` |
| Fluff | A Resume sentence that has a fluff word and no number, no Term and no action verb. Offered for removal, only with the user's confirmation. | Gap. | `Fluff` type |
| Fluff word | A word or phrase from the Dictionary that signals an empty claim ("passionate", "results-driven"). Never a Term. | Fluff. | `fluffWords` |

### Match

| Term | Meaning in this app | Not to be confused with | In code |
| --- | --- | --- | --- |
| Requirement | A Term found in a Vacancy, in a must or nice section or in neutral text, with a priority (must or nice). Terms in ignored sections are not Requirements. | Term; Fit point. | `Requirement` type |
| Quote | Exact words copied from the Resume or the user's answer that prove a Requirement. | Fact (not used). A paraphrase is never a Quote. | `Quote` type |
| `verifyQuote` | The function that finds a Quote in a source text, ignoring only case, whitespace and quote/dash style. No match means the Quote is not used. | A model's output. | `verifyQuote()` |
| Evidence source | The Section where a Term was found: Skills, Projects, Portfolio or Experience. Skills weighs more (1.0); the others weigh less (proposed 0.7). | Relation source. | `EvidenceSource` |
| Fit point | A statement, why it matters for this Vacancy, and a verbatim Quote. | Gap. | `FitPoint` type |
| Gap | A Requirement the Resume does not prove, with a reason. Coverage, not credibility: it is either in the record or absent. | Fluff. | `Gap` type |
| Dimension | One of four aspects of the match: technical, ownership, delivery, business context (0–100, or n/a). | Requirement. | `Dimension` type |
| Overall | The weighted score (0–100) of the four Dimensions. | Match percentage: Overall shown with its context. | `overall` |
| Band | strong (80 and above), possible (55 and above) or weak: the word next to Overall. | Verdict; Gate recommendation. | `Band` type |
| Match percentage | What the user sees: the Overall score and the share of Requirements proven, before and after the Changes; a *literal* figure (the Vacancy's exact words are present) and a figure *through the Dictionary*. It is a score by the Dictionary and its rules, not a chance of getting the job. | Coverage. | `MatchPercentage` |
| Coverage | The share of Requirements proven, weighted by Evidence source. | Match percentage. | `coverage` |
| Gate recommendation | apply, apply with caveats or do not apply, with a short reading of the shape of the four Dimensions. | Band. | `GateRecommendation` type |
| Highlight | Colouring of the Vacancy text in the interface only: green (in Skills), orange (only outside Skills, in projects or portfolio, assumed experience too), red (nowhere). Never written to a file. | A Change. | `Highlight` type |

### Asking the user

| Term | Meaning in this app | Not to be confused with | In code |
| --- | --- | --- | --- |
| Clarification | A question the Dictionary can ask because it sees a related but not identical Term (the Vacancy asks Redux Toolkit; the Resume says "state manager" or Zustand). Answers: Yes, No, Both. | Disputed pair. | `Clarification` type |
| Disputed pair | A Requirement and a Resume line the Dictionary knows nothing about. | Clarification. | `DisputedPair` type |
| Disputed choice | What the user picks for a Disputed pair: "I'll decide", "Ask the AI analyst" or "Skip". Nothing starts by itself. | Clarification answer. | `DisputedChoice` type |
| AI analyst | The model (free OpenRouter models) that helps with a Disputed pair, only after the user chose to ask. | The Dictionary. | `aiAnalyst` |
| AI connection | The user's own OpenRouter account connected by OAuth PKCE. | Session key. | `aiConnection` |
| Session key | The OpenRouter key kept only in server memory with an expiry, tied to an `httpOnly` cookie. Never sent to the browser, logs or database. | Any key in `.env` (the site has none). | `sessionKey` |
| Model fallback | Trying the next free model when one times out, errors, answers invalidly or hits a per-minute limit; a model that just failed is skipped for a while. | Daily limit (does not switch models). | `modelFallback` |

### Changes and output

| Term | Meaning in this app | Not to be confused with | In code |
| --- | --- | --- | --- |
| Change | One suggested edit of the Resume with its source: an Alias replaced, a concept named next to a tool, a technology added to Skills, lines reordered, Fluff removed, or the user's own edit. Accepted or rejected one by one. | Highlight. | `Change` type |
| Output choice | PDF only; same file type + PDF (default); same file type only; no files. The final summary on the screen is always shown. | Session reset. | `OutputChoice` type |
| Session reset | Return to the state of a first launch: on "Clear session", reload or tab close; never by delivering the result. | Deleting saved records in Personal mode. | `sessionReset` |

### Storage and modes

| Term | Meaning in this app | Not to be confused with | In code |
| --- | --- | --- | --- |
| Application | A saved Resume + Vacancy pair with its adjusted result. Personal mode only. | "The app": the web application. | `applications` table, `Application` type |
| Mode | Demo (`ALLOW_WRITES=false`, nothing stored, the Dictionary read-only) or Personal (`ALLOW_WRITES=true`). | "No AI connected": a separate state. | `ALLOW_WRITES`, `Mode` type |
| Seed | Sample Resumes and Vacancies in `data/seed.json`. | Dictionary seed: starting Terms and Relations in `data/dictionary.seed.json`. | `seed` |
