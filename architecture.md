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
