Create a Pull Request from the current branch to the base branch (master or main).

1. Run `git status`, `git log`, and `git diff <base-branch>...HEAD` in parallel to understand the full scope of changes since the branch diverged.
2. Determine the base branch: check if `master` or `main` exists and use whichever is present.
3. Analyze all commits and diffs to infer a concise PR title and a structured PR body in Korean, following the style:
   - Title: short imperative phrase (e.g. `Feature: 구글 로그인 구현`)
   - Body sections: `## 변경 사항` (bullet list of changes), `## 테스트 방법` (checklist of test steps)
4. Push the current branch to remote if it has not been pushed yet (`git push -u origin <branch>`).
5. Create the PR using `gh pr create` with the title and body via a HEREDOC.
6. Print the resulting PR URL.
