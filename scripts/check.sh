#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")/.."
export HOST_PORT=0
stage='подготовка Docker'
project=''
active=0
backup_dir=''
archive=''

set_project() {
    project=$1
    compose=(docker compose --ansi never --project-name "$project" -f compose.yaml)
}

print_dc() {
    printf '$ HOST_PORT=%q' "$HOST_PORT"
    printf ' %q' "${compose[@]}" "$@"
}

run_dc() {
    print_dc "$@"
    printf '\n'
    "${compose[@]}" "$@"
}

cleanup() {
    local status=$?
    if (( status != 0 )); then
        printf 'ОШИБКА на этапе «%s» (код %s)\n' "$stage" "$status" >&2
        if (( active )); then
            "${compose[@]}" ps -a >&2 || true
            "${compose[@]}" logs --tail=20 >&2 || true
            run_dc down -v --remove-orphans >&2 || true
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
    address=$("${compose[@]}" port app 8000)
    url="http://$address"
    printf 'Приложение доступно на %s\n' "$url"
}

expect_count() {
    local method=$1 path=$2 expected=$3 body
    body=$(curl_local --fail -X "$method" "$url$path")
    printf '%s\n' "$body" | "${compose[@]}" exec -T app python -c '
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
    run_dc down -v --remove-orphans
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
set_project "$(printf '%s' "${backup_dir##*/}" | tr '[:upper:]' '[:lower:]')"

step 'Чистый тестовый проект'
active=1
run_dc up -d --build --wait --wait-timeout 60
set_url
wait_ready
expect_count GET / 0

step 'Ограничения приложения'
uid=$("${compose[@]}" exec -T app id -u)
limits=$(docker inspect --format '{{.HostConfig.ReadonlyRootfs}} {{.HostConfig.Memory}} {{.HostConfig.NanoCpus}}' "$("${compose[@]}" ps -q app)")
read -r read_only memory_bytes nano_cpus <<< "$limits"
printf 'UID=%s, read_only/RAM_bytes/NanoCPUs = %s\n' "$uid" "$limits"
if [[ ! $uid =~ ^[1-9][0-9]*$ || $read_only != true ]] ||
    (( memory_bytes <= 0 || memory_bytes > 256 * 1024 * 1024 ||
       nano_cpus <= 0 || nano_cpus > 1000000000 )); then
    printf 'Требуются ненулевой UID, корневая ФС только для чтения и лимиты до 256 MiB и 1 CPU\n' >&2
    exit 1
fi

step 'Три инкремента'
n=3
for ((i = 1; i <= n; ++i)); do
    expect_count POST /increment "$i"
done
expect_count GET / "$n"

step 'Пересоздание только app'
app_before=$("${compose[@]}" ps -q app)
redis_before=$("${compose[@]}" ps -q redis)
run_dc up -d --no-deps --force-recreate --wait --wait-timeout 60 app
app_after=$("${compose[@]}" ps -q app)
redis_after=$("${compose[@]}" ps -q redis)
[[ -n $app_after && $app_before != "$app_after" && $redis_before == "$redis_after" ]]
set_url
expect_count GET / "$n"

step 'Сохранение данных после down и up'
run_dc down
run_dc up -d --wait --wait-timeout 60
set_url
expect_count GET / "$n"

step 'Сбой Redis и восстановление без перезапуска app'
app_id=$("${compose[@]}" ps -q app)
app_started=$(docker inspect --format '{{.State.StartedAt}}' "$app_id")
run_dc stop redis
expect_status GET /healthz 200
expect_status GET /readyz 503
expect_status POST /increment 503
run_dc start redis
wait_ready
[[ $("${compose[@]}" ps -q app) == "$app_id" ]]
[[ $(docker inspect --format '{{.State.StartedAt}}' "$app_id") == "$app_started" ]]
printf 'ID и время запуска app совпали с исходными\n'
expect_count GET / "$n"
saved_count=$(( n + 1 ))
expect_count POST /increment "$saved_count"

step 'Резервная копия остановленного Redis'
redis_id=$("${compose[@]}" ps -q redis)
run_dc stop app redis
[[ $(docker inspect --format '{{.State.ExitCode}}' "$redis_id") == 0 ]]
archive_command=(run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data)
print_dc "${archive_command[@]}" -cpf - .
printf ' < /dev/null > %q\n' "$archive"
"${compose[@]}" "${archive_command[@]}" -cpf - . < /dev/null > "$archive"
[[ -s $archive ]]

step 'Удаление исходного тестового проекта и его volumes'
remove_project

step 'Проверка архива в новом тестовом проекте'
set_project "$project-restore"
active=1
print_dc "${archive_command[@]}" -xpf -
printf ' < %q\n' "$archive"
"${compose[@]}" "${archive_command[@]}" -xpf - < "$archive"
run_dc up -d --build --wait --wait-timeout 60
set_url
expect_count GET / "$saved_count"
remove_project

printf '\nOK. Все проверки Redis прошли. Архив сохранён в %s\n' "$archive"
