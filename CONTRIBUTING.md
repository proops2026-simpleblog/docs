# Contributing — Simple Blog/CMS

Applies to every repo in `proops2026-simpleblog`: `gateway`, `user-service`, `content-service`, `frontend`, `docs`.

## Workflow (GitHub Flow)
1. Branch from `main`: `feature|fix|docs/<name>/<short-desc>` (e.g. `feature/trung/patch-post-route`). Keep it under 3 days.
2. Open a PR into `main` using the PR template. Request review from your partner.
3. The reviewer comments on at least one line and approves. New pushes dismiss the approval; resolve every conversation.
4. The author merges with **Squash and merge**, the only option enabled. The branch is deleted automatically.

`main` is protected by the "Protect main" ruleset: no direct pushes, no force pushes, no deletion, 1 approval required, no bypass.

## Commit / PR title format (Conventional Commits)
Squash uses the PR title as the commit on `main`, so the **PR title** must follow:

```
<type>(<scope>): <subject>
```

- Types: `feat` `fix` `chore` `docs` `refactor` `test` `ci`
- Scopes: `gateway` `user-service` `content-service` `frontend` `k8s` `infra` `docs` `github`
- Breaking change: add `BREAKING CHANGE: <details>` to the PR body.

Examples: `feat(content-service): add PATCH /posts/:id` · `fix(gateway): reject expired JWT` · `docs(github): add PR template`
