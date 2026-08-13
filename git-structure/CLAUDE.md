# Claude Code Preferences

## Directory Structure

Repos are organized into project folders by prefix under `~/git/`:

```
~/git/
├── project-a/                  # Project A repos (rename to your project prefix)
├── project-b/                  # Project B repos
├── week-of-*/                  # Weekly session folders (done files, notes, summaries)
├── todo.txt
├── todo_deferred.txt
├── todo_delegated.txt
└── CLAUDE.md
```

Each project folder gets its own CLAUDE.md describing that project; each repo may
add a third-level CLAUDE.md for repo-specific detail. Rename the placeholder
folders to real project prefixes and update this tree to match.

## General Behavior

- Do not make changes without understanding the existing code first. Always read relevant files before proposing or making edits.
- Do not over-explain. Keep responses concise and direct.
- When something is unclear or could go multiple ways, ask before acting.
- When a file or resource needs investigation before deciding on a fix, investigate first and present findings before proposing changes.
- Suggest changes or additions to CLAUDE.md if repeated patterns are detected.
- Never make assumptions or infer anything without verification. Before every response and every claim, ask: "did I make any assumptions or infer anything here?" If the answer is yes, do not present the claim as fact — call out explicitly what was assumed and why, then fill the gap by investigating (reading files, running commands, checking output) or asking a question. This applies to all domains: code behavior, infrastructure state, what a tool run will do, what another person intended, what a prior session established. A code diff does not tell you what is deployed. A log message does not tell you what caused it. A test passing does not tell you the system is correct. Verify, do not infer.
- When presenting findings or analysis, clearly distinguish between confirmed facts and working hypotheses.
- Do not jump ahead to the next task while a deployment or long-running operation is still in progress. Wait for confirmation of completion before proceeding unless explicitly told otherwise.
- Do not log session workflow items in done files — e.g. updating CLAUDE.md, maintaining todo files, or other housekeeping. Done files are for substantive work only.

## Writing Style
- Write like an experienced engineer explaining something to another engineer. Aim for clear technical writing, not a blog post. Example: "This retries on timeout" over "This gracefully weathers the storm of network failures."
- Use direct language. Prefer literal wording over metaphors or idioms. Example: "the cache fills up" not "the cache drowns."
- Avoid rhetorical contrast like "X, not Y" or "this isn't X, it's Y." State the point directly.
- Skip stock phrases (table stakes, game changer, silver bullet, footgun). Explain why something matters instead.
- Use precise terms over slang, e.g. "dispatch to the main queue" not "hop back to main," "create" not "spin up."
- Cut filler (actually, just, very) and empty openers ("It's important to note that..."). Start with the point.
- Keep real technical terms for APIs, patterns, and data structures. Simplify the prose around them, not the terms. Example: keep "debounce" and "idempotent," don't water them down to "wait a bit" or "safe to repeat."
- Plain isn't the same as terse. Keep qualifiers, caveats, and examples that carry meaning. Example: keep "this fails if the token expired" rather than cutting it for brevity.

## Git

- Always check the current branch before making changes.
- Commit messages follow the format `type(scope): description` (e.g. `fix(ci): gate downstream deploy on upstream result`). Common types: `feat`, `fix`, `refactor`, `docs`, `chore`. Scope is optional but should be included when it meaningfully narrows the change (e.g. a filename, workflow name, or component).
- Always pull latest changes before starting work in a repo.
- Do not push unless explicitly asked. Never chain `git push` with other commands in a single shell call — a push must always be its own standalone, explicitly approved command.
- When a commit fails to push due to a remote update, pull with rebase.

## Deployment Promotion Flow

- For projects that use environment promotion (e.g. dev → uat → prod), never skip an environment and never deploy or merge directly to a downstream environment from a non-adjacent source.
- When dispatching a workflow, use the branch matching the target environment, not whatever branch happens to be current.
- Before any deployment or promotion action, state the target environment, the source branch/environment, and that the order is being followed; then stop and ask for confirmation before executing.

## Meeting & Standup Prep File

- When a meeting or recurring standup is planned, create a prep file at `~/git/week-of-(date)/(meeting)_(date).txt`, where `(meeting)` is a short slug for the meeting or person (e.g. `standup_(date).txt`, `(name)_(date).txt`).
- Include a talking points section with context for each item — enough that the user can speak to it without needing to look anything up.
- For daily standup updates, structure talking points as what was done, what's in progress, and any blockers, drawing on recent done files and current todos.
- Leave a NOTES section at the bottom for the user to fill in during the meeting.
- File lives in the current week's folder.

## Todo File

- Maintain a todo file at `~/git/todo.txt`.
- Only add items that need to be revisited later (unknowns, deferred decisions, external dependencies).
- Do not add items for work that is currently in progress or already planned.
- Keep entries concise but with enough context to act on them without needing to look things up.
- Prefix items blocked on external dependencies with `BLOCKED:`.
- Prefix items that require a discussion before any work can happen with `DISCUSS:`.

## Deferred File

- Maintain a deferred file at `~/git/todo_deferred.txt`.
- Move items from todo.txt here when they have no near-term unblock path (e.g. blocked on infrastructure that doesn't exist yet, or on an external migration with no timeline).
- Same format as todo.txt. Items can be moved back to todo.txt when they become actionable.

## Delegated File

- Maintain a delegated file at `~/git/todo_delegated.txt`.
- Use this for items that have been explicitly assigned to another person (a named teammate). These should not appear in todo.txt.
- Include the assignee, what they need to do, and any handoff notes or supporting files.
- Review and close items when the assignee confirms completion. If the completed work unblocks something in todo.txt, update that item accordingly.
- Same format as todo.txt.

## Done File

- At the start of each session, create a done file at `~/git/done_(date).txt` (e.g. `done_03062026.txt`).
- Log completed tasks and resolved blockers as they are finished during the session.
- Include enough context to understand what was done and why, without needing to look things up (commit hash, run ID, key decisions made).
- Entries must be kept in chronological order (earliest first). When adding a new entry, it must always be appended it at the bottom.
- After adding a new entry, check to see if it was appended to the bottom of the file.
- The done file lives in the current week's folder — move it there after creating it.
- Format: plain text, header line `Done - MM/DD/YYYY`, entries as bullet points starting with `- `. Each item should have a succinct header followed by an empty line before the additional context. Match the style of existing done files exactly.

## Weekly Folders

- Notes, status updates, done files, and other session artifacts are organized into weekly folders at `~/git/week-of-(date)/` (e.g. `week-of-03022026/`).
- At the end of a session or when organizing, move all markdown and text files from the git root into the current week's folder, except for `todo.txt`, `todo_deferred.txt`, `todo_delegated.txt`, `CLAUDE.md`, and any long-lived reference file kept at the root on purpose.

## Code Style

- Prefer editing existing files over creating new ones.
- Avoid using overly verbose comments unless the logic is non-obvious.
- Do not add docstrings, type annotations, or error handling beyond what already exists in the surrounding code.
- Match the style and conventions of the existing file being edited.
- Never use emojis in any output, files, or messages.
