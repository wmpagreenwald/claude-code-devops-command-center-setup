---
name: jepp-confluence
description: Use this skill for ANY Confluence interaction — reading pages, searching for content, browsing spaces, viewing page history, or fetching attachments. This skill contains the correct base URL, auth pattern, and JSON parsing workarounds needed for reliable Confluence REST API access. Always load when the user mentions Confluence URLs (containing "/confluence/"), space keys, page titles, or asks about documentation stored in Confluence. Do NOT use for Jama, Jira, Bitbucket, or git operations — those have separate skills.
user-invocable: false
---

# Confluence REST API Guidelines

When the user asks to interact with Confluence, use the Confluence REST API via `curl`. Do not use any CLI tools.

## Authentication
- Use Basic Auth with `$CONFLUENCE_USERNAME` and `$CONFLUENCE_PASSWORD`
- Base URL: `$CONFLUENCE_URL/rest/api`

## URL Parsing

When the user provides a Confluence URL like:
```
https://confluence.example.com/confluence/display/ABC/Release+Management
```
Extract:
- **Space Key**: `ABC` (from `/display/{spaceKey}/`)
- **Page Title**: `Release Management` (from the last segment, `+` = space)

When the user provides a URL like:
```
https://confluence.example.com/confluence/spaces/XYZ/pages/26812072/Tool+Qualification+Self-Help+Home+Page
```
Extract:
- **Space Key**: `XYZ` (from `/spaces/{spaceKey}/`)
- **Page ID**: `26812072` (from `/pages/{pageId}/`)
- **Page Title**: `Tool Qualification Self-Help Home Page`

## Two Patterns You Must Follow

These workarounds are the same as for Jama/Jira — without them, API calls silently fail.

### 1. Capture curl output before piping

```bash
# Broken — auth fails silently:
curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_PASSWORD" "$CONFLUENCE_URL/rest/api/content/123" | python3 -m json.tool

# Works — capture first, then pipe:
result=$(curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_PASSWORD" "$CONFLUENCE_URL/rest/api/content/123") && echo "$result" | parse_json
```

### 2. Parse JSON with strict=False and .strip()

Confluence responses contain HTML in body fields with control characters. Use this parsing pattern:

```bash
echo "$result" | python3 -c "import sys, json; data = json.loads(sys.stdin.read().strip(), strict=False); print(json.dumps(data, indent=2))"
```

Never use `python3 -m json.tool`. For brevity, examples below use `| parse_json` as shorthand.

### 3. Use temp files for large responses

Confluence pages often contain large HTML bodies. Use temp files to avoid shell mangling:

```bash
tmpfile=$(mktemp)
curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_PASSWORD" "$CONFLUENCE_URL/rest/api/content/123?expand=body.storage" -o "$tmpfile"
CONF_FILE="$tmpfile" python3 -c "
import json, os
with open(os.environ['CONF_FILE'], 'r') as f:
    data = json.loads(f.read().strip(), strict=False)
print(json.dumps(data, indent=2))
"
rm "$tmpfile"
```

## Common API Endpoints

### Get a page by ID
```bash
GET /rest/api/content/{pageId}?expand=body.storage,version,ancestors
```
Returns: page title, body (HTML), version info, ancestors (parent pages).

### Get a page by ID (body as plain text view)
```bash
GET /rest/api/content/{pageId}?expand=body.view
```
The `body.view` expansion returns rendered HTML which is easier to parse for text content.

### Search for content (CQL)
```bash
GET /rest/api/content/search?cql=space="{spaceKey}" AND title~"{searchText}"&limit=20
```
CQL (Confluence Query Language) supports:
- `space="KEY"` — filter by space
- `title~"text"` — title contains text
- `text~"text"` — full-text search in body
- `type="page"` — pages only (vs blogpost, comment)
- `ancestor={pageId}` — descendants of a page

### Get page children
```bash
GET /rest/api/content/{pageId}/child/page?limit=50
```

### Get page by space key and title
```bash
GET /rest/api/content?spaceKey={spaceKey}&title={pageTitle}&expand=body.storage
```

### Get space info
```bash
GET /rest/api/space/{spaceKey}
```

### Get page attachments
```bash
GET /rest/api/content/{pageId}/child/attachment?limit=50
```

### Download an attachment
```bash
curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_PASSWORD" "$CONFLUENCE_URL{attachmentDownloadPath}" -o output_file
```
The download path comes from `attachment._links.download`.

### Get page history/versions
```bash
GET /rest/api/content/{pageId}/version?limit=20
```

### Get page labels
```bash
GET /rest/api/content/{pageId}/label
```

## Pagination

Confluence uses `start` and `limit` parameters:
```json
{
  "start": 0,
  "limit": 25,
  "size": 25,
  "_links": {
    "next": "/rest/api/content/search?cql=...&start=25&limit=25"
  }
}
```

Use `start` and `limit` query parameters to page through results.

## Key Fields in Page Response

- `id` — numeric page ID
- `title` — page title
- `type` — "page" or "blogpost"
- `space.key` — space key
- `version.number` — current version number
- `version.when` — last modified date
- `version.by.displayName` — last modifier
- `body.storage.value` — page body as Confluence storage format (HTML/XML)
- `body.view.value` — page body as rendered HTML
- `ancestors` — array of parent pages (when expanded)
- `_links.webui` — relative URL to view the page in browser

## Tips

- Page bodies are HTML — strip tags with `python3` if you need plain text:
  ```python
  from html.parser import HTMLParser
  class S(HTMLParser):
      def __init__(self):
          super().__init__()
          self.text = []
      def handle_data(self, d):
          self.text.append(d)
  s = S()
  s.feed(html_content)
  print(''.join(s.text))
  ```
- Use `expand=body.storage` for raw content, `expand=body.view` for rendered HTML
- CQL queries must be URL-encoded when passed via curl
- To get a full page tree, recursively fetch `/child/page` for each level
- Confluence may return 403 if the user doesn't have access to a space — check permissions
