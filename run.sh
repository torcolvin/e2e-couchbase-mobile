#!/bin/bash

set -eux -o pipefail

env DOCKER_SCAN_SUGGEST=false COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker compose up --build
