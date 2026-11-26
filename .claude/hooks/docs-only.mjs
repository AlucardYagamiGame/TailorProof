// PreToolUse hook for the analyst agent: allow edits only inside docs/ and data/.
// Claude Code passes the tool call as JSON on stdin; exit code 2 blocks the call
// and sends stderr back to the agent.
import { relative, resolve, sep } from 'node:path';

let raw = '';
for await (const chunk of process.stdin) raw += chunk;

const input = JSON.parse(raw);
const root = process.env.CLAUDE_PROJECT_DIR ?? input.cwd ?? process.cwd();
const filePath = input.tool_input?.file_path;

if (filePath) {
  const rel = relative(resolve(root), resolve(root, filePath));
  const top = rel.split(sep)[0];
  if (rel.startsWith('..') || (top !== 'docs' && top !== 'data')) {
    console.error(`The analyst may only edit files in docs/ and data/, not "${rel}".`);
    process.exit(2);
  }
}
