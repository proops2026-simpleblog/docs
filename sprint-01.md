# Sprint 1 Backlog — Blog / CMS Platform

**Sprint Goal:** Implement and containerize `user-service` (including role management & admin bootstrap) and set up the foundation for `api-gateway` routing and PostgreSQL connectivity.

**Team & Service Ownership (PIC):**
- **Dat Pham** — PIC for `user-service` (IRD-001)
- **Trung** — PIC for `content-service` (IRD-002)
- **Shared (Dat Pham & Trung)** — `api-gateway` & infrastructure (IRD-003), `DOP-001`

---

## Epic 1: User Service & Authentication (`user-service`) — PIC: Dat Pham

### User Story 1: User Registration
> As a new user, I want to register an account so that I can log into the blog platform.

- [ ] **Task 1.1 (Dat Pham):** Initialize `user-service` project structure, Express app, and PostgreSQL connection configuration with Prisma/Knex. *(1 day)*
- [ ] **Task 1.2 (Trung):** Implement `POST /auth/register` endpoint with bcrypt password hashing (cost factor 10) and mandatory `READER` role enforcement. *(1 day)*
- [ ] **Task 1.3 (Dat Pham):** Write unit & integration tests for registration (success 201, invalid email 400, duplicate email 409). *(1 day)*

### User Story 2: User Login & JWT Issuance
> As a registered user, I want to log in with my credentials so that I receive an authentication token for protected actions.

- [ ] **Task 2.1 (Trung):** Implement `POST /auth/login` endpoint with password comparison and JWT (HS256) generation (24h expiry, payload includes `sub` and `role`). *(1 day)*
- [ ] **Task 2.2 (Dat Pham):** Implement `GET /health` endpoint for `user-service` health checks. *(0.5 day)*
- [ ] **Task 2.3 (Trung):** Write unit & integration tests for login flow (success 200, invalid credentials 401). *(0.5 day)*

### User Story 3: Admin Bootstrap & Role Management
> As the platform operator, I want an Admin account to exist automatically on first startup, and want that Admin to be able to promote other users, so that role management has a starting point.

- [ ] **Task 3.1 (Dat Pham):** Implement startup seed logic — if `users` table is empty, insert one ADMIN row from `INITIAL_ADMIN_EMAIL` / `INITIAL_ADMIN_PASSWORD`. Idempotent (never reseeds once a user exists). *(1 day)*
- [ ] **Task 3.2 (Dat Pham):** Implement `PATCH /users/:id/role`, restricted to `ADMIN`, with full validation (400 invalid role, 403 non-admin, 404 unknown user). *(1 day)*
- [ ] **Task 3.3 (Trung):** Write tests for bootstrap idempotency and role-update authorization. *(0.5 day)*

---

## Epic 2: Gateway & Infrastructure Foundation (`api-gateway` & `infra`) — PIC: Shared

### User Story 4: Containerization & Routing Foundation
> As a DevOps engineer, I want to containerize `user-service` and set up `api-gateway` routing so that auth requests are proxied securely.

- [ ] **Task 4.1 (Dat Pham):** Write production-grade multi-stage Dockerfile for `user-service` and Docker Compose setup with PostgreSQL and health checks. *(1 day)*
- [ ] **Task 4.2 (Trung):** Set up `api-gateway` skeleton with routing to `user-service` (including `/users/:id/role`) and JWT validation middleware forwarding `X-User-Id` & `X-User-Role` headers. *(1 day)*

---

## Definition of Done (DoD)
- All `user-service` endpoints (`POST /auth/register`, `POST /auth/login`, `PATCH /users/:id/role`, `GET /health`) work correctly through `api-gateway`.
- Public registration strictly enforces role `READER`; only the automated startup seed may create an `ADMIN` directly.
- JWT contains correct payload claims (HS256) and signature verification succeeds.
- All unit and integration tests pass, including the bootstrap idempotency test.
- `docker-compose up` starts PostgreSQL, `user-service`, and `api-gateway` with passing health checks.
