# Sprint 1 Backlog — Blog / CMS Platform

**Sprint Goal:** Implement and containerize `user-service` and set up the foundation for `api-gateway` routing and PostgreSQL connectivity.

**Team:**
- **Person A (Product Owner / Developer):** Dat Pham (`datpham-devops`)
- **Person B (Scrum Master / Developer):** Partner

---

## Epic 1: User Service & Authentication (`user-service`)

### User Story 1: User Registration
> As a new user, I want to register an account so that I can log into the blog platform.

- [ ] **Task 1.1 (Person A):** Initialize `user-service` project structure, Express app, and PostgreSQL connection configuration with Prisma/Knex. *(1 day)*
- [ ] **Task 1.2 (Person B):** Implement `POST /auth/register` endpoint with bcrypt password hashing and mandatory `READER` role enforcement. *(1 day)*
- [ ] **Task 1.3 (Person A):** Write unit & integration tests for registration (success 201, invalid email 400, duplicate email 409). *(1 day)*

### User Story 2: User Login & JWT Issuance
> As a registered user, I want to log in with my credentials so that I receive an authentication token for protected actions.

- [ ] **Task 2.1 (Person B):** Implement `POST /auth/login` endpoint with password comparison and JWT token generation (24h expiry, payload includes `sub` and `role`). *(1 day)*
- [ ] **Task 2.2 (Person A):** Implement `GET /health` endpoint for `user-service` health checks. *(0.5 day)*
- [ ] **Task 2.3 (Person B):** Write unit & integration tests for login flow (success 200, invalid credentials 401). *(0.5 day)*

---

## Epic 2: Gateway & Infrastructure Foundation (`api-gateway` & `infra`)

### User Story 3: Containerization & Routing Foundation
> As a DevOps engineer, I want to containerize `user-service` and set up `api-gateway` routing so that auth requests are proxied securely.

- [ ] **Task 3.1 (Person A):** Write production-grade multi-stage Dockerfile for `user-service` and Docker Compose setup with PostgreSQL and healthchecks. *(1 day)*
- [ ] **Task 3.2 (Person B):** Set up `api-gateway` skeleton with routing to `user-service` and JWT validation middleware forwarding `X-User-Id` & `X-User-Role` headers. *(1 day)*

---

## Definition of Done (DoD)
- All `user-service` endpoints (`POST /auth/register`, `POST /auth/login`, `GET /health`) work correctly through `api-gateway`.
- Public registration strictly enforces role `READER`.
- JWT contains correct payload claims and signature verification succeeds.
- All unit and integration tests pass.
- `docker-compose up` starts PostgreSQL, `user-service`, and `api-gateway` with passing health checks.
