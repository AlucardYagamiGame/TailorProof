#!/usr/bin/env bash
# Builds the automatic part of a pull request description.
#
#   pr-description.sh BASE HEAD            prints the auto block
#   pr-description.sh BASE HEAD BODY_FILE  prints BODY_FILE with the block put between
#                                          the <!-- auto:start --> and <!-- auto:end --> markers
#                                          (or appended when the markers are missing)
#
# BASE and HEAD are any git revisions. Commit subjects and file names are read from git and
# only ever printed inside backticks, so they cannot start a mention or break the markdown.
set -euo pipefail

base="${1:?usage: pr-description.sh BASE HEAD [BODY_FILE]}"
head="${2:?usage: pr-description.sh BASE HEAD [BODY_FILE]}"
body_file="${3:-}"

START='<!-- auto:start -->'
END='<!-- auto:end -->'

# A backtick inside a subject or a path would end the code span: replace it.
safe() { printf '%s' "${1//\`/\'}"; }

block() {
  echo "$START"
  echo '### Commits'
  echo
  local count=0 sha subject
  while IFS=$'\t' read -r sha subject; do
    printf -- '- `%s` (%s)\n' "$(safe "$subject")" "$sha"
    count=$((count + 1))
  done < <(git log --reverse --no-merges --format='%h%x09%s' "$base..$head")
  if [ "$count" -eq 0 ]; then echo '_No commits._'; fi
  echo
  echo '### Changed files'
  echo
  local status path files=0
  while IFS=$'\t' read -r status path; do
    printf -- '- %s `%s`\n' "$status" "$(safe "$path")"
    files=$((files + 1))
  done < <(git diff --name-status --no-renames "$base...$head")
  if [ "$files" -eq 0 ]; then echo '_No changed files._'; fi
  echo "$END"
}

if [ -z "$body_file" ]; then
  block
  exit 0
fi

block_file="$(mktemp)"
trap 'rm -f "$block_file"' EXIT
block > "$block_file"

if grep -qF "$START" "$body_file" && grep -qF "$END" "$body_file"; then
  # Replace everything from the start marker to the end marker; keep the rest as it is.
  awk -v blockfile="$block_file" -v start="$START" -v end="$END" '
    !done && index($0, start) {
      while ((getline line < blockfile) > 0) print line
      skipping = 1; done = 1; next
    }
    skipping { if (index($0, end)) skipping = 0; next }
    { print }
  ' "$body_file"
else
  cat "$body_file"
  [ -s "$body_file" ] && echo
  cat "$block_file"
fi
