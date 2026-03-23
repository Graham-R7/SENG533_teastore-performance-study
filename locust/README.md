# TeaStore Locust Experiments

This folder contains a standalone Locust-based load-testing setup for TeaStore.

It does not modify the existing experiment scripts in the repository.

## Why Locust here

- Runs on a single machine without LIMBO's director/load-generator split.
- Uses Python, which makes TeaStore user flows easier to read and extend.
- Supports both the web UI and headless CLI execution for repeatable tests.

## What is included

- `locustfile.py`: TeaStore browsing and shopping-cart scenario.
- `requirements.txt`: Python dependency list.
- `run-locust.sh`: Convenience launcher for the Locust web UI.
- `Dockerfile`: Container image for a reproducible Locust runtime.
- `docker-compose.locust.yml`: Standalone Docker Compose file for Locust.
- `run-locust-docker.sh`: Convenience launcher for the containerized Locust UI.

## Option 1: Containerized Locust (recommended for teams)

This option keeps the runtime consistent across machines and does not require a local Python installation.

Prerequisites:

1. Start TeaStore first.
2. Make sure Docker is available.

Start the Locust UI:

```bash
bash locust/run-locust-docker.sh
```

The Locust UI will be available at `http://localhost:8089`.

Default target host from inside the container:

- `http://host.docker.internal:8080`

If TeaStore is exposed on a different host or port, override it:

```bash
TEASTORE_HOST=http://host.docker.internal:8080 \
docker compose -f locust/docker-compose.locust.yml up --build
```

## Option 2: Local Python Locust

Prerequisites:

1. Start TeaStore first.
2. Make sure Python 3 is available.
3. Install dependencies:

```bash
python3 -m pip install -r locust/requirements.txt
```

## Start Locust UI

```bash
bash locust/run-locust.sh
```

The Locust UI will be available at `http://localhost:8089`.

Default target host:

- `http://localhost:8080`

## Headless example

```bash
python3 -m locust \
  -f locust/locustfile.py \
  --host http://localhost:8080 \
  --users 20 \
  --spawn-rate 5 \
  --run-time 2m \
  --headless \
  --csv locust/results/baseline
```

## Scenario summary

The current scenario mixes:

- homepage visits
- category browsing
- product detail views
- cart views
- optional login with TeaStore's default demo credentials
- add-to-cart actions

## Notes

- The script assumes the TeaStore web UI is mounted under `/tools.descartes.teastore.webui`.
- Login uses the demo account shown by the TeaStore login form:
  - username: `user2`
  - password: `password`
- CSV output paths under `locust/results/` are intended for local run artifacts and are ignored by Git.
- The Docker setup uses `host.docker.internal` by default so the Locust container can reach a TeaStore instance published on the host machine.
