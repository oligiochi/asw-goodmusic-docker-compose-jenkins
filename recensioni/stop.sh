#!/bin/bash

# Script per arrestare Postgres con Docker Compose (v2)

echo Halting Postgres Recensioni...

# docker compose down -v
cd "$(dirname "$0")" 
docker compose --profile debug down -v
