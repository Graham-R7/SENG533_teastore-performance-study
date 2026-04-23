# TeaStore Performance Study

## Workflow
1. Start TeaStore.
2. Run the load generator / experiment scripts.
3. Collect CSV results.
4. Run analysis scripts.

## TeaStore Server Stack
The original deployment file remains available at `deployment/docker-compose.yml`.

For the dedicated TeaStore server deployment, use:

```bash
docker compose \
  --env-file deployment/.env.server.example \
  -f deployment/docker-compose.teastore-server.yml \
  up -d
```

The server compose file keeps the existing TeaStore images and internal service
hostnames, while allowing host-side ports to be overridden through environment
variables.

Default host ports:

- `registry`: `10000`
- `db`: `3308`
- `persistence`: `1111`
- `auth`: `2222`
- `recommender`: `3333`
- `image`: `4444`
- `webui`: `8080`

## Limbo Client Stack
The remote Limbo client stack runs `director` and `loadgenerator` together from
the same image built from `load-generator-director/Dockerfile`.

Start it with:

```bash
docker compose \
  --env-file deployment/.env.client.example \
  -f deployment/docker-compose.limbo-client.yml \
  up --build
```

Important client environment variables:

- `TEASTORE_HOST`: IP or hostname of the TeaStore server.
- `TEASTORE_PORT`: TeaStore WebUI port, defaults to `8080`.
- `LOADGEN_HOST`: Director target host. Leave this as `loadgenerator` when using
  the bundled client compose stack.
- `LOADGEN_PORT`: Director target port, defaults to `5000`.
- `WORKLOAD_INTENSITY`: `low`, `med`, or `high`.
- `WARMUP_SECS`: Warmup duration for the director.
- `MAX_THREADS`: Director thread cap.
- `AUTO_START`: Set to `1` to skip the interactive confirmation prompt.

Generated client result CSV files are written under
`load-generator-director/results/`.

## Manual Director Usage
The local director helper still supports the original CLI:

```bash
./load-generator-director/director-start.sh [low|med|high]
```

It now also honors these environment variables:

- `TEASTORE_HOST`
- `TEASTORE_PORT`
- `LOADGEN_HOST`
- `LOADGEN_PORT`
- `WORKLOAD_INTENSITY`
- `WARMUP_SECS`
- `MAX_THREADS`
- `AUTO_START`

If no environment variables are provided, the existing defaults are preserved.

## Experiments
- baseline load
- ramp load
- microservice scaling

### !!!"Docker-compose" was assisted with AI(ChatGPT), the rest is not!!!
