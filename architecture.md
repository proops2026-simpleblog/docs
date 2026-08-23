# System Architecture — Blog / CMS Platform

```mermaid
graph TD
  Client([Client / Browser / Postman])

  subgraph Gateway Layer
    GW["api-gateway (:3000)<br/>JWT Auth & Routing"]
  end

  subgraph Microservices Layer
    CS["content-service (:3001)<br/>Posts, Categories, Comments"]
    US["user-service (:3002)<br/>Users & Auth"]
  end

  subgraph Storage Layer
    PG[(PostgreSQL :5432<br/>user_db & content_db)]
  end

  Client -->|HTTP REST / Port 3000| GW
  GW -->|/posts/* & /categories/* & /comments/*| CS
  GW -->|/auth/*| US
  CS -->|reads/writes| PG
  US -->|reads/writes| PG
```
