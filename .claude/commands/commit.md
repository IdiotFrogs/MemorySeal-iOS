Commit all current changes in the repository.

1. Run `git status` and `git diff` (including staged and untracked files) in parallel to understand what has changed.
2. Analyze the changes and infer a concise, meaningful Korean commit message following the existing style (e.g. `Feature: ...`, `Fix: ...`, `Refactor: ...`).
3. Stage all relevant changed, modified, and untracked files using `git add` (avoid adding `.env`, secrets, or binary files unless clearly intentional).
4. Commit with the message using a HEREDOC, appending the Co-Authored-By trailer.
5. Run `git status` to confirm the commit succeeded.
