# Repository Guidelines

## Project Structure & Module Organization

- `docker-compose.yml`: stack for AWS/production, wiring pre-built images (`stevenrq/*`) with managed databases.
- `docker-compose.dev.yml`: local-friendly stack that spins up databases and Zipkin automatically.
- `.env` / `.env.dev`: environment variables; keep real secrets out of git. Copy from templates, never commit credentials.
- `copy-from-local-to-remote.sh`: helper to sync artifacts to remote hosts; adjust paths before use.
- `sgivu-ec2-keypair.pem`: private key; ensure `chmod 400` and avoid bundling it in images or logs.

## Build, Test, and Development Commands

- `docker compose -f docker-compose.dev.yml --env-file .env.dev up -d`: start the full local stack.
- `docker compose up -d`: start the production-oriented stack using `.env`.
- `docker compose down [-v]`: stop stack; add `-v` to clean volumes when resetting databases.
- `docker compose -f docker-compose.dev.yml config`: validate merged configuration before boot.

## Coding Style & Naming Conventions

- Compose files: 2-space YAML indentation; align service keys (image, ports, environment) consistently.
- Service names should mirror microservice names (`auth`, `user`, `client`, `gateway`) to keep network aliases predictable.
- Use uppercase snake case for environment keys and placeholders (`DB_PASSWORD`, `JWT_SECRET`); avoid hardcoding secrets.
- Tag images explicitly (`stevenrq/sgivu-auth:v1.3.0`) to prevent unintended upgrades.

## Testing Guidelines

- Prefer `docker compose ... config` to catch schema or variable typos.
- Smoke check after changes: `docker compose -f docker-compose.dev.yml up -d && docker compose ps` then `docker compose logs -f <service>`.
- Validate inter-service connectivity by curling gateway/auth endpoints from inside containers (`docker compose exec gateway curl http://auth:8080/actuator/health`).
- If adding services, include healthchecks so dependent containers wait for readiness.

## Commit & Pull Request Guidelines

- Commits: short, imperative subjects (e.g., `Add gateway rate limits`, `Update auth image tag`); group related compose/env changes together.
- PRs: describe the change, impacted services, and required env additions; link related tickets. Mention any data resets (`-v`) or manual steps.
- Include command examples in the PR body for reviewers to reproduce (`docker compose -f docker-compose.dev.yml up -d auth gateway`).

## Security & Configuration Tips

- Do not commit real `.env` content or private keys; use placeholders and share secrets via secure channels.
- Restrict exposed ports to what the gateway needs; prefer internal networks for DBs and Zipkin.
- Rotate image tags when updating dependencies and document breaking changes (ports, env vars, volume names) in the PR.
