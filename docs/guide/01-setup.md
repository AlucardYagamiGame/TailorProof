# Step 1. Setup

**Goal:** your own copy of the starter runs on your computer, and Claude Code works in it.

## 1.1 Install the tools

| Tool | Get it |
| --- | --- |
| Git | [git-scm.com/downloads](https://git-scm.com/downloads) |
| Node.js **22.18+** (LTS) | [nodejs.org](https://nodejs.org/en/download) |
| Code editor | for example [VS Code](https://code.visualstudio.com/) |
| GitHub account | [github.com/signup](https://github.com/signup) |

Check:

```bash
git --version
node --version   # v22.18 or newer
```

> **Windows:** use PowerShell or Git Bash. Where commands differ, the PowerShell version is given.

## 1.2 Create your repository

1. Open the starter repository on GitHub (your teacher gives you the link).
2. Click **Use this template → Create a new repository**.
3. Owner: your account. Name: anything (you can rename it later to match your app). Visibility: **Public**.
4. Clone **your** repository:

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

## 1.3 Run the app

```bash
npm install
npm run dev
```

Open [http://localhost:5173](http://localhost:5173). You should see **"Welcome! Your workspace is ready."** and the Backend card says **"Connected to api v0.1.0"**.

Keep this terminal open. Stop the servers with `Ctrl+C`.

## 1.4 Run the tests

In a **second** terminal:

```bash
npm run test               # unit tests
npm run test:e2e:install   # once: downloads a browser for Playwright
npm run test:e2e           # end-to-end tests
```

Everything should be green. Problems? See [Troubleshooting](../development.md#troubleshooting).

## 1.5 Install Claude Code

Follow the current instructions at [code.claude.com/docs](https://code.claude.com/docs). For example, with npm:

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

## 1.6 Sign in

Always start Claude Code **from the repository root**, so it picks up the project configuration:

```bash
claude
```

Then inside Claude Code:

1. `/login` → sign in with your Claude subscription (Pro or higher) or an Anthropic Console account with API credits.
2. `/model` → pick a model. A stronger model costs more usage; a lighter one is enough for small steps.

Good to know:

- Claude Code is not free: it uses your subscription limits or API credits. Small steps and short context (see Step 6) save both.
- If you hit a usage limit, wait for it to reset or switch to a lighter model with `/model`.
- **Never paste passwords, API keys or personal data into the chat.**

## 1.7 Meet the AI setup

| Thing | What it is |
| --- | --- |
| Default mode | Reads and edits files, runs commands; asks you before risky actions. |
| Plan mode | Read-only. Thinks and plans, never edits. Switch modes with `Shift+Tab`. |
| `analyst` agent | Ours. Writes requirements, glossary and feature files. Can edit only `docs/` and `data/`, never code. Asks questions before writing. Start it with `claude --agent analyst`. |
| `frontend`, `backend` subagents | Specialists the main agent can delegate to. Can edit files. |
| `reviewer` subagent | Reviews changes. Cannot edit anything. |
| `/plan-feature` | Plans a feature: API, acceptance criteria, steps. No code changes. Run it in plan mode. |
| `/implement` | Implements a feature or the agreed plan, adds tests, runs checks. |
| `/verify` | Runs lint, typecheck, tests, build, E2E and a review. Reports PASS / FAIL. |
| `CLAUDE.md` | The file Claude Code reads first. It imports `AGENTS.md`, requirements, architecture and glossary. |
| `AGENTS.md` | Rules every agent reads. If the agent keeps doing something wrong, add a rule here. |
| `.claude/settings.json` | Permissions: safe `npm` and `git` read commands are allowed, other shell commands ask you, `git push` is forbidden. |

All of these are plain text files. Open them and read them: this is exactly what the agent "knows".

Useful keys: `/clear` new conversation, `/rewind` undo the last changes, `@` attach a file, `/` list all commands, `/agents` list agents.

## 1.8 First prompt

Make sure the agent can read the project:

```text
Read AGENTS.md and docs/architecture.md. Summarize this project in 5 bullet points
and list the npm commands I can use to check my work. Do not change any files.
```

**Expected agent behavior:** it reads the files (you see the tool calls), answers with a short summary that mentions React, Express, the `/api` proxy and the test commands, and changes nothing.

## ✅ Result

- [ ] Your own repository on GitHub, cloned locally.
- [ ] `npm run dev` shows "Connected to api v0.1.0".
- [ ] `npm run test` and `npm run test:e2e` pass.
- [ ] Claude Code answered the first prompt.

Next: [Step 2. Idea and scope](02-idea-and-scope.md)
