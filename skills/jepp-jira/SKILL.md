---
name: jepp-jira
description: Use this skill for ANY Jira interaction — creating tickets, transitioning issues, checking status, assigning sprints, adding comments, listing issues, querying boards, or updating fields. This skill contains critical workarounds for API auth, JSON parsing, sprint assignment, and board-to-status mappings that prevent common failures. Always load when the user mentions ticket IDs (e.g. "CND-20081"), says "transition to done", "create a ticket", "what's the status of", "move to In Review", "current sprint", "assign to sprint", or any JIRA-related task. Do NOT use for Bitbucket PRs, git operations, or CI/CD — those have separate skills.
user-invocable: false
---

# Jira Server API Guidelines

When the user asks to interact with Jira (e.g. list issues, create tickets, update status, check sprints), use the Jira Server REST API via `curl`. Do not use any CLI tools.

## Authentication
- Use Basic Auth with `$JIRA_USERNAME` and `$JIRA_PASSWORD`
- Base URL: `$JIRA_URL/rest/api/2`

## Two Patterns You Must Follow

These workarounds are non-negotiable — without them, most Jira API calls silently fail or return garbage.

### 1. Capture curl output before piping

The Bash tool's subprocess capture interferes with pipes, causing auth headers to get lost when curl's stdout is piped directly. Capture to a variable first:

```bash
# Broken — auth fails silently:
curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" "$JIRA_URL/rest/api/2/issue/KEY-123" | python3 -m json.tool

# Works — capture first, then pipe:
result=$(curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" "$JIRA_URL/rest/api/2/issue/KEY-123") && echo "$result" | parse_json
```

### 2. Parse JSON with strict=False and .strip()

Jira responses may contain control characters (newlines in description fields, etc.) that Python's default JSON parser rejects. The response may also have trailing whitespace. Use this parsing pattern throughout:

```bash
echo "$result" | python3 -c "import sys, json; data = json.loads(sys.stdin.read().strip(), strict=False); print(json.dumps(data, indent=2))"
```

Never use `python3 -m json.tool` — it uses strict parsing and breaks on Jira responses.

For brevity, the examples below use `| parse_json` as shorthand for the full parsing command above.

## Sprint Assignment

Setting the Sprint field (`customfield_10005`) directly in issue creation or update fails with "Number value expected as the Sprint id." The Sprint field expects a different format than what the API accepts inline.

Instead, assign sprints via the Agile API after creating/updating the issue:

```bash
result=$(curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" -X POST -H "Content-Type: application/json" \
  "$JIRA_URL/rest/agile/1.0/sprint/{sprintId}/issue" \
  -d '{"issues": ["KEY-123"]}') && echo "$result"
```

## Scrum Board Status Mapping

The scrum board column names don't always match Jira workflow status names — using the wrong name causes silent failures in transitions:

- **"In Review"** on the board = **External** status (transition id: 881)
- **"Done"** on the board = **Resolved** status with resolution "Done" — do not transition further to "Closed" (that's a different workflow state)

To move a task to "In Review", transition it to "External".

## Column-Based Issue Queries

Board column names almost never match Jira status names. When a user asks to list issues by a board column (e.g. "To Do", "In Progress", "In Review"), don't query by the column name as a status — it will silently return 0 results. Instead, resolve the column to its actual status IDs first:

1. **Find the board** — `GET /rest/agile/1.0/board?name=<board_name>`
2. **Get column config** — `GET /rest/agile/1.0/board/{boardId}/configuration`, read `columnConfig.columns`
3. **Match the column** — find the entry whose `name` matches the user's request (case-insensitive)
4. **Extract status IDs** — collect all `statuses[].id` from that column
5. **Query with status IDs** — `jql=status in ({id1},{id2},{id3})`

```bash
# Step 1: Find board
board_result=$(curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" \
  "$JIRA_URL/rest/agile/1.0/board?name=My%20Board") && echo "$board_result" | parse_json

# Step 2: Get column config and extract status IDs for the target column
config=$(curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" \
  "$JIRA_URL/rest/agile/1.0/board/{boardId}/configuration") && echo "$config" | parse_json

# Step 3-5: Query issues using resolved status IDs
result=$(curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" \
  "$JIRA_URL/rest/agile/1.0/board/{boardId}/issue?jql=status%20in%20(10100,10000,10003)&maxResults=100") \
  && echo "$result" | parse_json
```

This approach is essential because columns like "To Do" often map to statuses named "Open", "Queue", etc. — never assume a 1:1 name match.

## JSON Parsing: Avoid Shell Variable Piping for Large Responses

Jira responses may contain backslashes in text fields (e.g. `CoRtes\Preferred`) that produce invalid JSON escape sequences. Piping via `echo "$result"` can mangle backslashes due to shell interpolation, causing persistent `Invalid \escape` errors that no Python-side regex fix can resolve.

**Always use temp files instead of shell variables for JSON parsing:**

```bash
tmpfile=$(mktemp)
curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" "$JIRA_URL/rest/api/2/search?jql=..." -o "$tmpfile"
JIRA_FILE="$tmpfile" python3 /tmp/parse_script.py
rm "$tmpfile"
```

**Write Python parsing logic to a separate script file** (via `cat > /tmp/script.py << 'PYEOF'`) to avoid shell escaping issues with inline `-c` code. Read the file path from an environment variable:

```python
import json, os
with open(os.environ['JIRA_FILE'], 'r') as f:
    data = json.loads(f.read().strip(), strict=False)
```

Key points:
- Use `curl -o "$tmpfile"` to write directly to file — this preserves raw bytes without shell mangling
- Use `<< 'PYEOF'` (quoted heredoc) for Python scripts to prevent shell variable expansion
- Pass the temp file path via environment variable (`JIRA_FILE="$tmpfile" python3 script.py`), not via string interpolation inside Python code
- Always clean up: `rm "$tmpfile" /tmp/script.py`

## Comments

Don't add Jira comments about implementation details unless the user explicitly asks for it — comments should be intentional, not automated noise.
