# Счётчик в Docker

Приложение из `app/` запускается в Docker с SQLite или Redis. Нужны работающий Docker с Compose и `curl`.

## Запуск с Redis

```sh
cp .env.example .env
docker compose up -d --build --wait --wait-timeout 60
curl -fsS --max-time 5 http://127.0.0.1:8080/
curl -fsS --max-time 5 -X POST http://127.0.0.1:8080/increment
docker compose down
```

В `.env` можно задать приветствие `GREETING` и порт `HOST_PORT`. При смене порта подставьте его и в URL. Порт Redis доступен внутри сети Compose, приложение подключается к `redis://redis:6379/0`.

Redis включает AOF и хранит файлы в именованном volume `redis-data`. `docker compose down` сохраняет этот volume. Приложение запускается с UID `10001`, корневой файловой системой только для чтения, лимитом памяти 256 MiB и лимитом в одно ядро CPU. Healthcheck приложения проверяет `/readyz`, а healthcheck Redis ждёт `PONG`.

## Запуск с SQLite

```sh
docker build -t hw3-counter .
docker run --rm -d --name hw3-counter -p 127.0.0.1:8080:8000 -e GREETING='Hello from Docker' hw3-counter
curl -fsS --max-time 5 http://127.0.0.1:8080/
curl -fsS --max-time 5 -X POST http://127.0.0.1:8080/increment
docker logs hw3-counter
docker stop hw3-counter
```

Compose с SQLite использует те же настройки `.env` и отдельный именованный volume `sqlite-data`.

```sh
docker compose -f compose.sqlite.yaml up -d --build --wait --wait-timeout 60
curl -fsS --max-time 5 -X POST http://127.0.0.1:8080/increment
docker compose -f compose.sqlite.yaml down
docker compose -f compose.sqlite.yaml up -d --wait --wait-timeout 60
curl -fsS --max-time 5 http://127.0.0.1:8080/
docker compose -f compose.sqlite.yaml down
```

## Автоматические проверки

```sh
./scripts/check.sh
```

Скрипт выделяет отдельный Compose-проект и свободный порт. Он проверяет начальное значение, инкременты, пересоздание приложения, полный перезапуск Compose с сохранением volume и поведение API при остановке Redis. После штатной остановки сервисов он архивирует весь каталог `/data`, удаляет исходный проект с его volume, распаковывает архив в volume нового проекта и сверяет счётчик. Архив остаётся в `backups/`. При ошибке скрипт печатает этап, завершает работу с ненулевым кодом и пытается очистить ресурсы своего проекта.

Для отчёта по всем уровням выполните одну команду.

```sh
./scripts/report.sh
```

Она проверяет обычный запуск и SQLite в Compose, затем дважды запускает `check.sh`. При успехе `REPORT.md` содержит фактический вывод всех прогонов. Путь к текущему логу печатается сразу, чтобы его можно было открыть при ошибке.
