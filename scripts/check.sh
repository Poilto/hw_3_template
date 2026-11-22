#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")/.."
export HOST_PORT=0
stage='подготовка Docker'
project=''
active=0
backup_dir=''
archive=''

dc() {
    docker compose --ansi never --project-name "$project" -f compose.yaml "$@"
}

cleanup() {
    local status=$?
    if (( status != 0 )); then
        printf 'ОШИБКА на этапе «%s» (код %s)\n' "$stage" "$status" >&2
        if (( active )); then
            dc ps -a >&2 || true
            dc logs --tail=20 >&2 || true
            dc down -v --remove-orphans >&2 || true
        fi
        if [[ -n $backup_dir ]]; then
            rm -f -- "$archive"
            rmdir -- "$backup_dir" || true
        fi
    fi
    exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

step() {
    stage=$1
    printf '\n== %s ==\n' "$stage"
}

curl_local() {
    curl --noproxy '*' --silent --show-error --connect-timeout 2 --max-time 5 "$@"
}

set_url() {
    local address
    address=$(dc port app 8000)
    url="http://$address"
    printf 'Приложение доступно на %s\n' "$url"
}

expect_count() {
    local method=$1 path=$2 expected=$3 body
    body=$(curl_local --fail -X "$method" "$url$path")
    printf '%s\n' "$body" | dc exec -T app python -c '
import json, sys
data = json.load(sys.stdin)
if data["count"] != int(sys.argv[1]) or data["storage"] != "redis":
    sys.exit(f"Unexpected response: {data!r}; expected count={sys.argv[1]}, storage=redis")
' "$expected"
    printf 'curl -X %s %s%s → %s\n' "$method" "$url" "$path" "$body"
}

expect_status() {
    local method=$1 path=$2 expected=$3 actual
    actual=$(curl_local -o /dev/null -w '%{http_code}' -X "$method" "$url$path")
    printf 'curl -X %s %s%s → HTTP %s\n' "$method" "$url" "$path" "$actual"
    [[ $actual == "$expected" ]]
}

wait_ready() {
    local deadline=$(( SECONDS + 45 ))
    until curl_local --fail -o /dev/null "$url/readyz" 2>/dev/null; do
        if (( SECONDS >= deadline )); then
            printf 'За 45 секунд /readyz не вернул успешный статус\n' >&2
            return 1
        fi
        sleep 1
    done
    expect_status GET /readyz 200
}

remove_project() {
    local volumes
    printf '$ docker compose -p %s down -v\n' "$project"
    dc down -v --remove-orphans
    volumes=$(docker volume ls -q --filter "label=com.docker.compose.project=$project")
    if [[ -n $volumes ]]; then
        printf 'Остались volumes проекта %s\n%s\n' "$project" "$volumes" >&2
        return 1
    fi
    active=0
}

docker info --format '{{.ServerVersion}}' >/dev/null
mkdir -p backups
backup_dir=$(mktemp -d "backups/hw3check-$$-XXXXXXXX")
archive="$backup_dir/redis-data.tar"
project=$(printf '%s' "${backup_dir##*/}" | tr '[:upper:]' '[:lower:]')

step 'Чистый тестовый проект'
active=1
printf '$ docker compose -p %s up -d --build --wait --wait-timeout 60\n' "$project"
dc up -d --build --wait --wait-timeout 60
set_url
wait_ready
expect_count GET / 0

step 'Ограничения приложения'
uid=$(dc exec -T app id -u)
limits=$(docker inspect --format '{{.HostConfig.ReadonlyRootfs}} {{.HostConfig.Memory}} {{.HostConfig.NanoCpus}}' "$(dc ps -q app)")
printf 'UID=%s, read_only/RAM_bytes/NanoCPUs = %s\n' "$uid" "$limits"
[[ $uid =~ ^[1-9][0-9]*$ && $limits == 'true 268435456 1000000000' ]]

step 'Три инкремента'
n=3
for ((i = 1; i <= n; ++i)); do
    expect_count POST /increment "$i"
done
expect_count GET / "$n"

step 'Пересоздание только app'
app_before=$(dc ps -q app)
redis_before=$(dc ps -q redis)
printf '$ docker compose up -d --no-deps --force-recreate --wait --wait-timeout 60 app\n'
dc up -d --no-deps --force-recreate --wait --wait-timeout 60 app
app_after=$(dc ps -q app)
redis_after=$(dc ps -q redis)
[[ -n $app_after && $app_before != "$app_after" && $redis_before == "$redis_after" ]]
set_url
expect_count GET / "$n"

step 'Сохранение данных после down и up'
printf '$ docker compose down\n$ docker compose up -d --wait --wait-timeout 60\n'
dc down
dc up -d --wait --wait-timeout 60
set_url
expect_count GET / "$n"

step 'Сбой Redis и восстановление без перезапуска app'
app_id=$(dc ps -q app)
app_started=$(docker inspect --format '{{.State.StartedAt}}' "$app_id")
printf '$ docker compose stop redis\n'
dc stop redis
expect_status GET /healthz 200
expect_status GET /readyz 503
expect_status POST /increment 503
printf '$ docker compose start redis\n'
dc start redis
wait_ready
[[ $(dc ps -q app) == "$app_id" ]]
[[ $(docker inspect --format '{{.State.StartedAt}}' "$app_id") == "$app_started" ]]
printf 'ID и время запуска app совпали с исходными\n'
expect_count GET / "$n"
saved_count=$(( n + 1 ))
expect_count POST /increment "$saved_count"

step 'Резервная копия остановленного Redis'
redis_id=$(dc ps -q redis)
printf '$ docker compose stop app redis\n'
dc stop app redis
[[ $(docker inspect --format '{{.State.ExitCode}}' "$redis_id") == 0 ]]
printf '$ docker compose run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -cpf - . > %s\n' "$archive"
dc run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -cpf - . \
    < /dev/null > "$archive"
[[ -s $archive ]]

step 'Удаление исходного тестового проекта и его volumes'
remove_project

step 'Проверка архива в новом тестовом проекте'
project="$project-restore"
active=1
printf '$ docker compose run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -xpf - < %s\n' "$archive"
dc run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -xpf - \
    < "$archive"
dc up -d --build --wait --wait-timeout 60
set_url
expect_count GET / "$saved_count"
remove_project

printf '\nOK. Все проверки Redis прошли. Архив сохранён в %s\n' "$archive"
