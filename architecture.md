# System Architecture — Blog / CMS Platform

```mermaid
graph TD
  Client([Client / Browser])

  subgraph Frontend Layer
    FE["frontend (:5173)<br/>React SPA, calls gateway from the browser"]
  end

  subgraph Gateway Layer
    GW["gateway (:3000)<br/>JWT Auth & Routing"]
  end

  subgraph Microservices Layer
    US["user-service (:3002)<br/>Users, Auth, Roles"]
    CS["content-service (:3001)<br/>Posts, Categories, Comments"]
  end

  subgraph Storage Layer
    PG[("PostgreSQL (:5432)<br/>user_db & content_db")]
  end

  Client -->|"loads static app :5173"| FE
  Client -->|"HTTP REST :3000 (Authorization: Bearer)"| GW
  GW -->|":3002 /auth/register, /auth/login, /users/:id/role"| US
  GW -->|":3001 /posts/*, /categories/*, /comments/*"| CS
  US -->|"SQL: user_db"| PG
  CS -->|"SQL: content_db"| PG
```

Note: `frontend` only serves the static React bundle to the browser — the actual API traffic (`Client -->|HTTP REST :3000| GW`) is issued by JavaScript running *inside the browser*, not by the `frontend` container itself. This is why both arrows originate from `Client`, not from `FE`.

## Change delivery flow

How a change reaches `main` in any of the 5 repos (`gateway`, `user-service`, `content-service`, `frontend`, `docs`). Rules and naming: see `CONTRIBUTING.md`.

```mermaid
graph LR
  B["feature / fix / docs branch<br/>name/desc, from main, under 3 days"] -->|"push branch"| PR["Pull Request<br/>title = type(scope): subject"]
  PR -->|"partner: ≥1 line comment + approve<br/>all threads resolved"| SQ["Squash and merge<br/>(only option enabled)"]
  SQ --> M[("main<br/>1 commit per PR")]
  M -.->|"Day 23+: CI on push / PR"| CI["GitHub Actions"]
  CI -.->|"required status check<br/>(added to ruleset Day 23)"| PR
```

| Gate | Enforced by | Status |
|---|---|---|
| No direct push / force push / deletion of `main` | Repository Ruleset `Protect main` (active, bypass list empty) | on — direct push rejected with `GH013` |
| 1 approval, stale approval dismissed on new push, threads resolved | same ruleset, `pull_request` rule | on |
| Squash only, PR title becomes the commit | repo settings → Pull Requests | on |
| CI green before merge | ruleset `required_status_checks` | **off until Day 23** — needs an existing workflow check name |

Why repository-level rulesets: legacy Branch Protection and Org Rulesets need GitHub Team for private repos; repository rulesets work on the free plan, so the same setup is repeated in each repo.
