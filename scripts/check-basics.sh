#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")/.."
stage='подготовка Docker'
direct=''
temp_dir=''
compose_active=0
export HOST_PORT=0

run_dc() {
    printf '$ HOST_PORT=%q GREETING=%q' "$HOST_PORT" "$GREETING"
    printf ' %q' "${compose[@]}" "$@"
    printf '\n'
    "${compose[@]}" "$@"
}

cleanup() {
    local status=$?
    if (( status != 0 )); then
        printf 'ОШИБКА на этапе «%s» (код %s)\n' "$stage" "$status" >&2
        if [[ -n $direct ]]; then
            docker logs "$direct" >&2 || true
        fi
        if (( compose_active )); then
            "${compose[@]}" logs --tail=20 >&2 || true
        fi
    fi
    if [[ -n $direct ]]; then
        docker rm -f "$direct" >/dev/null || true
    fi
    if (( compose_active )); then
        run_dc down -v --remove-orphans || true
    fi
    if [[ -n $temp_dir ]]; then
        rmdir -- "$temp_dir" || true
    fi
    exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

curl_local() {
    curl --noproxy '*' --silent --show-error --fail --connect-timeout 2 --max-time 5 "$@"
}

expect_count() {
    local method=$1 path=$2 expected=$3 body
    body=$(curl_local -X "$method" "http://$address$path")
    printf '%s\n' "$body" | docker exec -i "$container" python -c '
import json, sys
data = json.load(sys.stdin)
if data["count"] != int(sys.argv[1]) or data["greeting"] != sys.argv[2] or data["storage"] != "sqlite":
    sys.exit(f"Unexpected response: {data!r}; expected count={sys.argv[1]}, greeting={sys.argv[2]}, storage=sqlite")
' "$expected" "$GREETING"
    printf 'curl -X %s http://%s%s → %s\n' "$method" "$address" "$path" "$body"
}

docker info --format '{{.ServerVersion}}' >/dev/null
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/hw3basics-$$-XXXXXXXX")
project=$(printf '%s' "${temp_dir##*/}" | tr '[:upper:]' '[:lower:]')
compose=(docker compose --ansi never --project-name "$project" -f compose.sqlite.yaml)
tag="hw3-basics:$project"

stage='4 балла — Docker без Compose'
printf '\n== %s ==\n' "$stage"
export GREETING='Hello from docker run'
printf '$ docker build -t %s .\n' "$tag"
docker build -t "$tag" .
printf '$ docker run -d -p 127.0.0.1:0:8000 -e GREETING="%s" %s\n' "$GREETING" "$tag"
direct=$(docker run -d -p 127.0.0.1:0:8000 -e GREETING "$tag")
container=$direct
address=$(docker port "$container" 8000/tcp)
deadline=$(( SECONDS + 30 ))
until curl_local -o /dev/null "http://$address/readyz" 2>/dev/null; do
    if (( SECONDS >= deadline )); then
        printf 'Docker-контейнер не готов за 30 секунд\n' >&2
        exit 1
    fi
    sleep 1
done
expect_count GET / 0
expect_count POST /increment 1
expect_count GET / 1
printf '$ docker logs %s\n' "$container"
docker logs "$container" 2>&1
docker rm -f "$direct" >/dev/null
direct=''

stage='6 баллов — Compose и именованный volume SQLite'
printf '\n== %s ==\n' "$stage"
export GREETING='Hello from Compose'
compose_active=1
run_dc up -d --build --wait --wait-timeout 60
container=$("${compose[@]}" ps -q app)
address=$("${compose[@]}" port app 8000)
expect_count GET / 0
expect_count POST /increment 1
volume=$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Name}}{{end}}{{end}}' "$container")
[[ -n $volume ]]
printf 'Контейнер %s и volume %s\n' "$container" "$volume"

old_container=$container
run_dc down
run_dc up -d --wait --wait-timeout 60
container=$("${compose[@]}" ps -q app)
address=$("${compose[@]}" port app 8000)
[[ -n $container && $container != "$old_container" ]]
new_volume=$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Name}}{{end}}{{end}}' "$container")
[[ $new_volume == "$volume" ]]
expect_count GET / 1
printf 'Новый контейнер %s использует прежний volume %s\n' "$container" "$volume"
run_dc down -v --remove-orphans
compose_active=0
printf '\nOK. Проверки Docker и Compose с SQLite прошли\n'
