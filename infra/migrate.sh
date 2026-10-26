#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose run --rm api alembic -c /workspace/services/api/alembic.ini upgrade head
