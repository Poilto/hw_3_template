# Отчёт о проверках Docker

| Проверка | Результат |
| --- | --- |
| Один контейнер | Приложение вернуло заданное приветствие и увеличило счётчик с 0 до 1. Вывод `docker logs` приведён ниже. |
| SQLite в Compose | После `down` и `up` контейнер получил другой ID, подключил прежний volume и вернул 1. |
| Redis в Compose | После пересоздания `app` и после `down`/`up` значение осталось 3. При остановке Redis запросы к `/healthz`, `/readyz` и `/increment` дали 200, 503 и 503. После восстановления следующий POST вернул 4. |
| Ограничения и резервная копия | В обоих запусках UID был 10001, корневая ФС была доступна только для чтения, лимиты составили 256 MiB и 1 CPU. Восстановленный из архива проект вернул 4 после удаления исходного volume. |

Ниже приведён вывод `./scripts/check-basics.sh` и двух последовательных запусков `./scripts/check.sh`.

## 4 и 6 баллов. Docker и Compose с SQLite

~~~text

== 4 балла — Docker без Compose ==
$ docker build -t hw3-basics:hw3basics-24489-dbckxhxz .
#0 building with "desktop-linux" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 358B done
#1 DONE 0.0s

#2 [internal] load metadata for docker.io/library/python:3.13-slim
#2 ...

#3 [auth] library/python:pull token for registry-1.docker.io
#3 DONE 0.0s

#2 [internal] load metadata for docker.io/library/python:3.13-slim
#2 DONE 1.6s

#4 [internal] load .dockerignore
#4 transferring context: 82B done
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 94B done
#5 DONE 0.0s

#6 [1/5] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90
#6 resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 done
#6 DONE 0.0s

#7 [3/5] COPY app/requirements.txt ./requirements.txt
#7 CACHED

#8 [2/5] WORKDIR /app
#8 CACHED

#9 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#9 CACHED

#10 [5/5] COPY app/app.py ./app.py
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:b775116141521ba883855abf5abdda676d650513687bad22a356d4d245f23d3b done
#11 exporting config sha256:5b69f067fb08e98dcd1655222e5b09ef71b2fdce97645d6f72bf970acaa85022 done
#11 exporting attestation manifest sha256:5703ac499c60b80c4de1572cef5858dd4d446c7ad80081696e5746e8f82875ff done
#11 exporting manifest list sha256:d732e0ba9081d6334c42aa30b682d03d1440dc71d1a429f3940379e856f8426b done
#11 naming to docker.io/library/hw3-basics:hw3basics-24489-dbckxhxz done
#11 unpacking to docker.io/library/hw3-basics:hw3basics-24489-dbckxhxz done
#11 DONE 0.0s
$ docker run -d -p 127.0.0.1:0:8000 -e GREETING="Hello from docker run" hw3-basics:hw3basics-24489-dbckxhxz
curl -X GET http://127.0.0.1:55000/ → {"greeting": "Hello from docker run", "count": 0, "hostname": "cb7188621ccd", "storage": "sqlite"}
curl -X POST http://127.0.0.1:55000/increment → {"greeting": "Hello from docker run", "count": 1, "hostname": "cb7188621ccd", "storage": "sqlite"}
curl -X GET http://127.0.0.1:55000/ → {"greeting": "Hello from docker run", "count": 1, "hostname": "cb7188621ccd", "storage": "sqlite"}
$ docker logs cb7188621ccdfba3cfcc2fc516db7d8e9206f0c53452f94ff79a0d6d55e7b0fb
2026-11-22 18:44:12,255 listening port=8000 storage=sqlite
2026-11-22 18:44:13,108 http 172.17.0.1 "GET /readyz HTTP/1.1" 200 -
2026-11-22 18:44:13,125 http 172.17.0.1 "GET / HTTP/1.1" 200 -
2026-11-22 18:44:13,255 http 172.17.0.1 "POST /increment HTTP/1.1" 200 -
2026-11-22 18:44:13,350 http 172.17.0.1 "GET / HTTP/1.1" 200 -

== 6 баллов — Compose и именованный volume SQLite ==
$ HOST_PORT=0 GREETING=Hello\ from\ Compose docker compose --ansi never --project-name hw3basics-24489-dbckxhxz -f compose.sqlite.yaml up -d --build --wait --wait-timeout 60
 Image hw3basics-24489-dbckxhxz-app Building
#1 [internal] load local bake definitions
#1 reading from stdin 704B done
#1 DONE 0.0s

#2 [internal] load build definition from Dockerfile
#2 transferring dockerfile: 358B done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/library/python:3.13-slim
#3 DONE 0.3s

#4 [internal] load .dockerignore
#4 transferring context: 82B done
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 94B done
#5 DONE 0.0s

#6 [1/5] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90
#6 resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 done
#6 DONE 0.0s

#7 [3/5] COPY app/requirements.txt ./requirements.txt
#7 CACHED

#8 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#8 CACHED

#9 [2/5] WORKDIR /app
#9 CACHED

#10 [5/5] COPY app/app.py ./app.py
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:543174212d771ef23062792121cf2ea0707592f77a679fae788f7ade938c7224 done
#11 exporting config sha256:ea974aa3490948acf69b833f92533e81a4b3eb9989624e2fc17397b2b7138d9f done
#11 exporting attestation manifest sha256:708e849c9cb847aa202e3a16ccc65002c7a03f0d998932cb4606f75415344484 done
#11 exporting manifest list sha256:ac50a7281253f634ad29db30c2a1ec96e45a5842dc5495741bd7196335af88c3 done
#11 naming to docker.io/library/hw3basics-24489-dbckxhxz-app:latest done
#11 unpacking to docker.io/library/hw3basics-24489-dbckxhxz-app:latest done
#11 DONE 0.0s

#12 resolving provenance for metadata file
#12 DONE 0.0s
 Image hw3basics-24489-dbckxhxz-app Built
 Network hw3basics-24489-dbckxhxz_default Creating
 Volume hw3basics-24489-dbckxhxz_sqlite-data Creating
 Network hw3basics-24489-dbckxhxz_default Creating
 Volume hw3basics-24489-dbckxhxz_sqlite-data Creating
 Volume hw3basics-24489-dbckxhxz_sqlite-data Created
 Volume hw3basics-24489-dbckxhxz_sqlite-data Created
 Network hw3basics-24489-dbckxhxz_default Created
 Network hw3basics-24489-dbckxhxz_default Created
 Container hw3basics-24489-dbckxhxz-app-1 Creating
 Container hw3basics-24489-dbckxhxz-app-1 Created
 Container hw3basics-24489-dbckxhxz-app-1 Starting
 Container hw3basics-24489-dbckxhxz-app-1 Started
 Container hw3basics-24489-dbckxhxz-app-1 Waiting
 Container hw3basics-24489-dbckxhxz-app-1 Healthy
curl -X GET http://127.0.0.1:55001/ → {"greeting": "Hello from Compose", "count": 0, "hostname": "3c2e7295a968", "storage": "sqlite"}
curl -X POST http://127.0.0.1:55001/increment → {"greeting": "Hello from Compose", "count": 1, "hostname": "3c2e7295a968", "storage": "sqlite"}
Контейнер 3c2e7295a96865740b2d7166c32bdc8f96f776e500a6b4299e4dd0a15128075b и volume hw3basics-24489-dbckxhxz_sqlite-data
$ HOST_PORT=0 GREETING=Hello\ from\ Compose docker compose --ansi never --project-name hw3basics-24489-dbckxhxz -f compose.sqlite.yaml down
 Container hw3basics-24489-dbckxhxz-app-1 Stopping
 Container hw3basics-24489-dbckxhxz-app-1 Stopped
 Container hw3basics-24489-dbckxhxz-app-1 Removing
 Container hw3basics-24489-dbckxhxz-app-1 Removed
 Network hw3basics-24489-dbckxhxz_default Removing
 Network hw3basics-24489-dbckxhxz_default Removed
$ HOST_PORT=0 GREETING=Hello\ from\ Compose docker compose --ansi never --project-name hw3basics-24489-dbckxhxz -f compose.sqlite.yaml up -d --wait --wait-timeout 60
 Network hw3basics-24489-dbckxhxz_default Creating
 Network hw3basics-24489-dbckxhxz_default Creating
 Network hw3basics-24489-dbckxhxz_default Created
 Network hw3basics-24489-dbckxhxz_default Created
 Container hw3basics-24489-dbckxhxz-app-1 Creating
 Container hw3basics-24489-dbckxhxz-app-1 Created
 Container hw3basics-24489-dbckxhxz-app-1 Starting
 Container hw3basics-24489-dbckxhxz-app-1 Started
 Container hw3basics-24489-dbckxhxz-app-1 Waiting
 Container hw3basics-24489-dbckxhxz-app-1 Healthy
curl -X GET http://127.0.0.1:55002/ → {"greeting": "Hello from Compose", "count": 1, "hostname": "a33e781345db", "storage": "sqlite"}
Новый контейнер a33e781345db834ec41e13e8ea4d2a7af1a614a34a34a63cd5b9ec812a77a3f5 использует прежний volume hw3basics-24489-dbckxhxz_sqlite-data
$ HOST_PORT=0 GREETING=Hello\ from\ Compose docker compose --ansi never --project-name hw3basics-24489-dbckxhxz -f compose.sqlite.yaml down -v --remove-orphans
 Container hw3basics-24489-dbckxhxz-app-1 Stopping
 Container hw3basics-24489-dbckxhxz-app-1 Stopped
 Container hw3basics-24489-dbckxhxz-app-1 Removing
 Container hw3basics-24489-dbckxhxz-app-1 Removed
 Network hw3basics-24489-dbckxhxz_default Removing
 Volume hw3basics-24489-dbckxhxz_sqlite-data Removing
 Volume hw3basics-24489-dbckxhxz_sqlite-data Removed
 Network hw3basics-24489-dbckxhxz_default Removed

OK. Проверки Docker и Compose с SQLite прошли
~~~

## 8 и 10 баллов. Redis, первый запуск

~~~text

== Чистый тестовый проект ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu -f compose.yaml up -d --build --wait --wait-timeout 60
 Image hw3check-24612-e9fx9ogu-app Building
#1 [internal] load local bake definitions
#1 reading from stdin 702B done
#1 DONE 0.0s

#2 [internal] load build definition from Dockerfile
#2 transferring dockerfile: 358B done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/library/python:3.13-slim
#3 DONE 0.3s

#4 [internal] load .dockerignore
#4 transferring context: 82B done
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 94B done
#5 DONE 0.0s

#6 [1/5] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90
#6 resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 done
#6 DONE 0.0s

#7 [2/5] WORKDIR /app
#7 CACHED

#8 [3/5] COPY app/requirements.txt ./requirements.txt
#8 CACHED

#9 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#9 CACHED

#10 [5/5] COPY app/app.py ./app.py
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:ef1059c59409afcd5d93c094164b8aec1641570bfb640c9a4bdc877e809ddab9 done
#11 exporting config sha256:2bc6b09223c13fdbdbfaa8d63fd8f6a47acc45ac7717fca25d14ac765dd2ca98 done
#11 exporting attestation manifest sha256:3ec51735c223c1f7058efef4a44b6298a0fff7fdf7e1b3b8e04c19587568a501 done
#11 exporting manifest list sha256:b60602b965e8b143bcd7201e234ee1e06474acd8281192ba6bc2b002bed32fee done
#11 naming to docker.io/library/hw3check-24612-e9fx9ogu-app:latest done
#11 unpacking to docker.io/library/hw3check-24612-e9fx9ogu-app:latest done
#11 DONE 0.0s

#12 resolving provenance for metadata file
#12 DONE 0.0s
 Image hw3check-24612-e9fx9ogu-app Built
 Network hw3check-24612-e9fx9ogu_default Creating
 Volume hw3check-24612-e9fx9ogu_redis-data Creating
 Volume hw3check-24612-e9fx9ogu_redis-data Creating
 Network hw3check-24612-e9fx9ogu_default Creating
 Volume hw3check-24612-e9fx9ogu_redis-data Created
 Volume hw3check-24612-e9fx9ogu_redis-data Created
 Network hw3check-24612-e9fx9ogu_default Created
 Network hw3check-24612-e9fx9ogu_default Created
 Container hw3check-24612-e9fx9ogu-redis-1 Creating
 Container hw3check-24612-e9fx9ogu-redis-1 Created
 Container hw3check-24612-e9fx9ogu-app-1 Creating
 Container hw3check-24612-e9fx9ogu-app-1 Created
 Container hw3check-24612-e9fx9ogu-redis-1 Starting
 Container hw3check-24612-e9fx9ogu-redis-1 Started
 Container hw3check-24612-e9fx9ogu-redis-1 Waiting
 Container hw3check-24612-e9fx9ogu-redis-1 Healthy
 Container hw3check-24612-e9fx9ogu-app-1 Starting
 Container hw3check-24612-e9fx9ogu-app-1 Started
 Container hw3check-24612-e9fx9ogu-redis-1 Waiting
 Container hw3check-24612-e9fx9ogu-app-1 Waiting
 Container hw3check-24612-e9fx9ogu-redis-1 Healthy
 Container hw3check-24612-e9fx9ogu-app-1 Healthy
Приложение доступно на http://127.0.0.1:55003
curl -X GET http://127.0.0.1:55003/readyz → HTTP 200
curl -X GET http://127.0.0.1:55003/ → {"greeting": "Hello, Docker!", "count": 0, "hostname": "5f9991bbd866", "storage": "redis"}

== Ограничения приложения ==
UID=10001, read_only/RAM_bytes/NanoCPUs = true 268435456 1000000000

== Три инкремента ==
curl -X POST http://127.0.0.1:55003/increment → {"greeting": "Hello, Docker!", "count": 1, "hostname": "5f9991bbd866", "storage": "redis"}
curl -X POST http://127.0.0.1:55003/increment → {"greeting": "Hello, Docker!", "count": 2, "hostname": "5f9991bbd866", "storage": "redis"}
curl -X POST http://127.0.0.1:55003/increment → {"greeting": "Hello, Docker!", "count": 3, "hostname": "5f9991bbd866", "storage": "redis"}
curl -X GET http://127.0.0.1:55003/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "5f9991bbd866", "storage": "redis"}

== Пересоздание только app ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu -f compose.yaml up -d --no-deps --force-recreate --wait --wait-timeout 60 app
 Container hw3check-24612-e9fx9ogu-app-1 Recreate
 Container hw3check-24612-e9fx9ogu-app-1 Recreated
 Container hw3check-24612-e9fx9ogu-app-1 Starting
 Container hw3check-24612-e9fx9ogu-app-1 Started
 Container hw3check-24612-e9fx9ogu-app-1 Waiting
 Container hw3check-24612-e9fx9ogu-app-1 Healthy
Приложение доступно на http://127.0.0.1:55004
curl -X GET http://127.0.0.1:55004/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "40e9496c33e4", "storage": "redis"}

== Сохранение данных после down и up ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu -f compose.yaml down
 Container hw3check-24612-e9fx9ogu-app-1 Stopping
 Container hw3check-24612-e9fx9ogu-app-1 Stopped
 Container hw3check-24612-e9fx9ogu-app-1 Removing
 Container hw3check-24612-e9fx9ogu-app-1 Removed
 Container hw3check-24612-e9fx9ogu-redis-1 Stopping
 Container hw3check-24612-e9fx9ogu-redis-1 Stopped
 Container hw3check-24612-e9fx9ogu-redis-1 Removing
 Container hw3check-24612-e9fx9ogu-redis-1 Removed
 Network hw3check-24612-e9fx9ogu_default Removing
 Network hw3check-24612-e9fx9ogu_default Removed
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu -f compose.yaml up -d --wait --wait-timeout 60
 Network hw3check-24612-e9fx9ogu_default Creating
 Network hw3check-24612-e9fx9ogu_default Creating
 Network hw3check-24612-e9fx9ogu_default Created
 Network hw3check-24612-e9fx9ogu_default Created
 Container hw3check-24612-e9fx9ogu-redis-1 Creating
 Container hw3check-24612-e9fx9ogu-redis-1 Created
 Container hw3check-24612-e9fx9ogu-app-1 Creating
 Container hw3check-24612-e9fx9ogu-app-1 Created
 Container hw3check-24612-e9fx9ogu-redis-1 Starting
 Container hw3check-24612-e9fx9ogu-redis-1 Started
 Container hw3check-24612-e9fx9ogu-redis-1 Waiting
 Container hw3check-24612-e9fx9ogu-redis-1 Healthy
 Container hw3check-24612-e9fx9ogu-app-1 Starting
 Container hw3check-24612-e9fx9ogu-app-1 Started
 Container hw3check-24612-e9fx9ogu-app-1 Waiting
 Container hw3check-24612-e9fx9ogu-redis-1 Waiting
 Container hw3check-24612-e9fx9ogu-redis-1 Healthy
 Container hw3check-24612-e9fx9ogu-app-1 Healthy
Приложение доступно на http://127.0.0.1:55005
curl -X GET http://127.0.0.1:55005/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "fa78320dc1b4", "storage": "redis"}

== Сбой Redis и восстановление без перезапуска app ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu -f compose.yaml stop redis
 Container hw3check-24612-e9fx9ogu-redis-1 Stopping
 Container hw3check-24612-e9fx9ogu-redis-1 Stopped
curl -X GET http://127.0.0.1:55005/healthz → HTTP 200
curl -X GET http://127.0.0.1:55005/readyz → HTTP 503
curl -X POST http://127.0.0.1:55005/increment → HTTP 503
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu -f compose.yaml start redis
 Container hw3check-24612-e9fx9ogu-redis-1 Starting
 Container hw3check-24612-e9fx9ogu-redis-1 Started
curl -X GET http://127.0.0.1:55005/readyz → HTTP 200
ID и время запуска app совпали с исходными
curl -X GET http://127.0.0.1:55005/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "fa78320dc1b4", "storage": "redis"}
curl -X POST http://127.0.0.1:55005/increment → {"greeting": "Hello, Docker!", "count": 4, "hostname": "fa78320dc1b4", "storage": "redis"}

== Резервная копия остановленного Redis ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu -f compose.yaml stop app redis
 Container hw3check-24612-e9fx9ogu-app-1 Stopping
 Container hw3check-24612-e9fx9ogu-app-1 Stopped
 Container hw3check-24612-e9fx9ogu-redis-1 Stopping
 Container hw3check-24612-e9fx9ogu-redis-1 Stopped
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu -f compose.yaml run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -cpf - . < /dev/null > backups/hw3check-24612-e9Fx9OGu/redis-data.tar
 Container hw3check-24612-e9fx9ogu-redis-run-a49dcd698935 Creating
 Container hw3check-24612-e9fx9ogu-redis-run-a49dcd698935 Created

== Удаление исходного тестового проекта и его volumes ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu -f compose.yaml down -v --remove-orphans
 Container hw3check-24612-e9fx9ogu-app-1 Stopping
 Container hw3check-24612-e9fx9ogu-app-1 Stopped
 Container hw3check-24612-e9fx9ogu-app-1 Removing
 Container hw3check-24612-e9fx9ogu-app-1 Removed
 Container hw3check-24612-e9fx9ogu-redis-1 Stopping
 Container hw3check-24612-e9fx9ogu-redis-1 Stopped
 Container hw3check-24612-e9fx9ogu-redis-1 Removing
 Container hw3check-24612-e9fx9ogu-redis-1 Removed
 Network hw3check-24612-e9fx9ogu_default Removing
 Volume hw3check-24612-e9fx9ogu_redis-data Removing
 Volume hw3check-24612-e9fx9ogu_redis-data Removed
 Network hw3check-24612-e9fx9ogu_default Removed

== Проверка архива в новом тестовом проекте ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu-restore -f compose.yaml run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -xpf - < backups/hw3check-24612-e9Fx9OGu/redis-data.tar
 Volume hw3check-24612-e9fx9ogu-restore_redis-data Creating
 Volume hw3check-24612-e9fx9ogu-restore_redis-data Creating
 Network hw3check-24612-e9fx9ogu-restore_default Creating
 Network hw3check-24612-e9fx9ogu-restore_default Creating
 Volume hw3check-24612-e9fx9ogu-restore_redis-data Created
 Volume hw3check-24612-e9fx9ogu-restore_redis-data Created
 Network hw3check-24612-e9fx9ogu-restore_default Created
 Network hw3check-24612-e9fx9ogu-restore_default Created
 Container hw3check-24612-e9fx9ogu-restore-redis-run-46c81cd83f32 Creating
 Container hw3check-24612-e9fx9ogu-restore-redis-run-46c81cd83f32 Created
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu-restore -f compose.yaml up -d --build --wait --wait-timeout 60
 Image hw3check-24612-e9fx9ogu-restore-app Building
#1 [internal] load local bake definitions
#1 reading from stdin 718B done
#1 DONE 0.0s

#2 [internal] load build definition from Dockerfile
#2 transferring dockerfile: 358B done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/library/python:3.13-slim
#3 DONE 0.3s

#4 [internal] load .dockerignore
#4 transferring context: 82B done
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 94B done
#5 DONE 0.0s

#6 [1/5] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90
#6 resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 0.0s done
#6 DONE 0.0s

#7 [2/5] WORKDIR /app
#7 CACHED

#8 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#8 CACHED

#9 [3/5] COPY app/requirements.txt ./requirements.txt
#9 CACHED

#10 [5/5] COPY app/app.py ./app.py
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:de9355dda942502acaab4d90c744df83c9a5a0fd8c7686afc3206c1721993d86 done
#11 exporting config sha256:c61fa7be088dd9a696c4022bf28b3ea806c79ba21c147dc894e4151d035b0ae9 done
#11 exporting attestation manifest sha256:bff4a64ccf6dffff417052882ddcd67bd23439da2aac9d77ae4d9dc542984d88 done
#11 exporting manifest list sha256:3ac8577bcf7c90fb75605c109afe80dcbe00cdb48a967eacd451e923ee43eec8 0.0s done
#11 naming to docker.io/library/hw3check-24612-e9fx9ogu-restore-app:latest done
#11 unpacking to docker.io/library/hw3check-24612-e9fx9ogu-restore-app:latest done
#11 DONE 0.0s

#12 resolving provenance for metadata file
#12 DONE 0.0s
 Image hw3check-24612-e9fx9ogu-restore-app Built
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Creating
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Created
 Container hw3check-24612-e9fx9ogu-restore-app-1 Creating
 Container hw3check-24612-e9fx9ogu-restore-app-1 Created
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Starting
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Started
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Waiting
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Healthy
 Container hw3check-24612-e9fx9ogu-restore-app-1 Starting
 Container hw3check-24612-e9fx9ogu-restore-app-1 Started
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Waiting
 Container hw3check-24612-e9fx9ogu-restore-app-1 Waiting
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Healthy
 Container hw3check-24612-e9fx9ogu-restore-app-1 Healthy
Приложение доступно на http://127.0.0.1:55006
curl -X GET http://127.0.0.1:55006/ → {"greeting": "Hello, Docker!", "count": 4, "hostname": "955278a86712", "storage": "redis"}
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-24612-e9fx9ogu-restore -f compose.yaml down -v --remove-orphans
 Container hw3check-24612-e9fx9ogu-restore-app-1 Stopping
 Container hw3check-24612-e9fx9ogu-restore-app-1 Stopped
 Container hw3check-24612-e9fx9ogu-restore-app-1 Removing
 Container hw3check-24612-e9fx9ogu-restore-app-1 Removed
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Stopping
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Stopped
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Removing
 Container hw3check-24612-e9fx9ogu-restore-redis-1 Removed
 Volume hw3check-24612-e9fx9ogu-restore_redis-data Removing
 Network hw3check-24612-e9fx9ogu-restore_default Removing
 Volume hw3check-24612-e9fx9ogu-restore_redis-data Removed
 Network hw3check-24612-e9fx9ogu-restore_default Removed

OK. Все проверки Redis прошли. Архив сохранён в backups/hw3check-24612-e9Fx9OGu/redis-data.tar
~~~

## 8 и 10 баллов. Redis, второй запуск

~~~text

== Чистый тестовый проект ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00 -f compose.yaml up -d --build --wait --wait-timeout 60
 Image hw3check-25284-acamhb00-app Building
#1 [internal] load local bake definitions
#1 reading from stdin 702B done
#1 DONE 0.0s

#2 [internal] load build definition from Dockerfile
#2 transferring dockerfile: 358B done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/library/python:3.13-slim
#3 DONE 0.3s

#4 [internal] load .dockerignore
#4 transferring context: 82B done
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 94B done
#5 DONE 0.0s

#6 [1/5] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90
#6 resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 done
#6 DONE 0.0s

#7 [2/5] WORKDIR /app
#7 CACHED

#8 [3/5] COPY app/requirements.txt ./requirements.txt
#8 CACHED

#9 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#9 CACHED

#10 [5/5] COPY app/app.py ./app.py
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:8b9a84f19b9c0895c43f2fc2418d274789ebf123b8349c02f4e2c3a46c5af582 done
#11 exporting config sha256:755ee660a47de48e0ff80fff36ae85fb99752e0a831aac626dda27ffbfe59ce0 done
#11 exporting attestation manifest sha256:4e94588fa2b95a33742e94a9a2b239ceef48d7a024651d5e4689fc65455151dd done
#11 exporting manifest list sha256:58da3c09af06e57803b7cd90ab4eb5357628f5edc2b7f9ffb72eb5fa5c8b1306 done
#11 naming to docker.io/library/hw3check-25284-acamhb00-app:latest done
#11 unpacking to docker.io/library/hw3check-25284-acamhb00-app:latest done
#11 DONE 0.0s

#12 resolving provenance for metadata file
#12 DONE 0.0s
 Image hw3check-25284-acamhb00-app Built
 Network hw3check-25284-acamhb00_default Creating
 Network hw3check-25284-acamhb00_default Creating
 Volume hw3check-25284-acamhb00_redis-data Creating
 Volume hw3check-25284-acamhb00_redis-data Creating
 Volume hw3check-25284-acamhb00_redis-data Created
 Volume hw3check-25284-acamhb00_redis-data Created
 Network hw3check-25284-acamhb00_default Created
 Network hw3check-25284-acamhb00_default Created
 Container hw3check-25284-acamhb00-redis-1 Creating
 Container hw3check-25284-acamhb00-redis-1 Created
 Container hw3check-25284-acamhb00-app-1 Creating
 Container hw3check-25284-acamhb00-app-1 Created
 Container hw3check-25284-acamhb00-redis-1 Starting
 Container hw3check-25284-acamhb00-redis-1 Started
 Container hw3check-25284-acamhb00-redis-1 Waiting
 Container hw3check-25284-acamhb00-redis-1 Healthy
 Container hw3check-25284-acamhb00-app-1 Starting
 Container hw3check-25284-acamhb00-app-1 Started
 Container hw3check-25284-acamhb00-redis-1 Waiting
 Container hw3check-25284-acamhb00-app-1 Waiting
 Container hw3check-25284-acamhb00-redis-1 Healthy
 Container hw3check-25284-acamhb00-app-1 Healthy
Приложение доступно на http://127.0.0.1:55007
curl -X GET http://127.0.0.1:55007/readyz → HTTP 200
curl -X GET http://127.0.0.1:55007/ → {"greeting": "Hello, Docker!", "count": 0, "hostname": "f9c2644993bd", "storage": "redis"}

== Ограничения приложения ==
UID=10001, read_only/RAM_bytes/NanoCPUs = true 268435456 1000000000

== Три инкремента ==
curl -X POST http://127.0.0.1:55007/increment → {"greeting": "Hello, Docker!", "count": 1, "hostname": "f9c2644993bd", "storage": "redis"}
curl -X POST http://127.0.0.1:55007/increment → {"greeting": "Hello, Docker!", "count": 2, "hostname": "f9c2644993bd", "storage": "redis"}
curl -X POST http://127.0.0.1:55007/increment → {"greeting": "Hello, Docker!", "count": 3, "hostname": "f9c2644993bd", "storage": "redis"}
curl -X GET http://127.0.0.1:55007/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "f9c2644993bd", "storage": "redis"}

== Пересоздание только app ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00 -f compose.yaml up -d --no-deps --force-recreate --wait --wait-timeout 60 app
 Container hw3check-25284-acamhb00-app-1 Recreate
 Container hw3check-25284-acamhb00-app-1 Recreated
 Container hw3check-25284-acamhb00-app-1 Starting
 Container hw3check-25284-acamhb00-app-1 Started
 Container hw3check-25284-acamhb00-app-1 Waiting
 Container hw3check-25284-acamhb00-app-1 Healthy
Приложение доступно на http://127.0.0.1:55008
curl -X GET http://127.0.0.1:55008/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "a5228c228b4c", "storage": "redis"}

== Сохранение данных после down и up ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00 -f compose.yaml down
 Container hw3check-25284-acamhb00-app-1 Stopping
 Container hw3check-25284-acamhb00-app-1 Stopped
 Container hw3check-25284-acamhb00-app-1 Removing
 Container hw3check-25284-acamhb00-app-1 Removed
 Container hw3check-25284-acamhb00-redis-1 Stopping
 Container hw3check-25284-acamhb00-redis-1 Stopped
 Container hw3check-25284-acamhb00-redis-1 Removing
 Container hw3check-25284-acamhb00-redis-1 Removed
 Network hw3check-25284-acamhb00_default Removing
 Network hw3check-25284-acamhb00_default Removed
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00 -f compose.yaml up -d --wait --wait-timeout 60
 Network hw3check-25284-acamhb00_default Creating
 Network hw3check-25284-acamhb00_default Creating
 Network hw3check-25284-acamhb00_default Created
 Network hw3check-25284-acamhb00_default Created
 Container hw3check-25284-acamhb00-redis-1 Creating
 Container hw3check-25284-acamhb00-redis-1 Created
 Container hw3check-25284-acamhb00-app-1 Creating
 Container hw3check-25284-acamhb00-app-1 Created
 Container hw3check-25284-acamhb00-redis-1 Starting
 Container hw3check-25284-acamhb00-redis-1 Started
 Container hw3check-25284-acamhb00-redis-1 Waiting
 Container hw3check-25284-acamhb00-redis-1 Healthy
 Container hw3check-25284-acamhb00-app-1 Starting
 Container hw3check-25284-acamhb00-app-1 Started
 Container hw3check-25284-acamhb00-redis-1 Waiting
 Container hw3check-25284-acamhb00-app-1 Waiting
 Container hw3check-25284-acamhb00-redis-1 Healthy
 Container hw3check-25284-acamhb00-app-1 Healthy
Приложение доступно на http://127.0.0.1:55010
curl -X GET http://127.0.0.1:55010/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "ccbef256478e", "storage": "redis"}

== Сбой Redis и восстановление без перезапуска app ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00 -f compose.yaml stop redis
 Container hw3check-25284-acamhb00-redis-1 Stopping
 Container hw3check-25284-acamhb00-redis-1 Stopped
curl -X GET http://127.0.0.1:55010/healthz → HTTP 200
curl -X GET http://127.0.0.1:55010/readyz → HTTP 503
curl -X POST http://127.0.0.1:55010/increment → HTTP 503
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00 -f compose.yaml start redis
 Container hw3check-25284-acamhb00-redis-1 Starting
 Container hw3check-25284-acamhb00-redis-1 Started
curl -X GET http://127.0.0.1:55010/readyz → HTTP 200
ID и время запуска app совпали с исходными
curl -X GET http://127.0.0.1:55010/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "ccbef256478e", "storage": "redis"}
curl -X POST http://127.0.0.1:55010/increment → {"greeting": "Hello, Docker!", "count": 4, "hostname": "ccbef256478e", "storage": "redis"}

== Резервная копия остановленного Redis ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00 -f compose.yaml stop app redis
 Container hw3check-25284-acamhb00-app-1 Stopping
 Container hw3check-25284-acamhb00-app-1 Stopped
 Container hw3check-25284-acamhb00-redis-1 Stopping
 Container hw3check-25284-acamhb00-redis-1 Stopped
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00 -f compose.yaml run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -cpf - . < /dev/null > backups/hw3check-25284-aCaMhB00/redis-data.tar
 Container hw3check-25284-acamhb00-redis-run-7f41b53f1040 Creating
 Container hw3check-25284-acamhb00-redis-run-7f41b53f1040 Created

== Удаление исходного тестового проекта и его volumes ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00 -f compose.yaml down -v --remove-orphans
 Container hw3check-25284-acamhb00-app-1 Stopping
 Container hw3check-25284-acamhb00-app-1 Stopped
 Container hw3check-25284-acamhb00-app-1 Removing
 Container hw3check-25284-acamhb00-app-1 Removed
 Container hw3check-25284-acamhb00-redis-1 Stopping
 Container hw3check-25284-acamhb00-redis-1 Stopped
 Container hw3check-25284-acamhb00-redis-1 Removing
 Container hw3check-25284-acamhb00-redis-1 Removed
 Volume hw3check-25284-acamhb00_redis-data Removing
 Network hw3check-25284-acamhb00_default Removing
 Volume hw3check-25284-acamhb00_redis-data Removed
 Network hw3check-25284-acamhb00_default Removed

== Проверка архива в новом тестовом проекте ==
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00-restore -f compose.yaml run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -xpf - < backups/hw3check-25284-aCaMhB00/redis-data.tar
 Volume hw3check-25284-acamhb00-restore_redis-data Creating
 Volume hw3check-25284-acamhb00-restore_redis-data Creating
 Network hw3check-25284-acamhb00-restore_default Creating
 Network hw3check-25284-acamhb00-restore_default Creating
 Volume hw3check-25284-acamhb00-restore_redis-data Created
 Volume hw3check-25284-acamhb00-restore_redis-data Created
 Network hw3check-25284-acamhb00-restore_default Created
 Network hw3check-25284-acamhb00-restore_default Created
 Container hw3check-25284-acamhb00-restore-redis-run-bbb1a493100e Creating
 Container hw3check-25284-acamhb00-restore-redis-run-bbb1a493100e Created
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00-restore -f compose.yaml up -d --build --wait --wait-timeout 60
 Image hw3check-25284-acamhb00-restore-app Building
#1 [internal] load local bake definitions
#1 reading from stdin 718B done
#1 DONE 0.0s

#2 [internal] load build definition from Dockerfile
#2 transferring dockerfile: 358B done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/library/python:3.13-slim
#3 DONE 0.3s

#4 [internal] load .dockerignore
#4 transferring context: 82B done
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 94B done
#5 DONE 0.0s

#6 [1/5] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90
#6 resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 done
#6 DONE 0.0s

#7 [2/5] WORKDIR /app
#7 CACHED

#8 [3/5] COPY app/requirements.txt ./requirements.txt
#8 CACHED

#9 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#9 CACHED

#10 [5/5] COPY app/app.py ./app.py
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:dc91ebf4cb36862e54173c131421a3faef55ccee61ef4f2a06bafe63f00b3c67 done
#11 exporting config sha256:de4e6dc5fc5bc55ed123a5198693185d649b821a7d3496263e76a43049c7e36f done
#11 exporting attestation manifest sha256:8764f55c8afe8c81e0473ba806383c5180c5d4ae9c454954c5eeb361f3405ea8 done
#11 exporting manifest list sha256:2c2e37171bb37f05e737047b487380394efbc14592c353c7bfa0979a813acc32 done
#11 naming to docker.io/library/hw3check-25284-acamhb00-restore-app:latest done
#11 unpacking to docker.io/library/hw3check-25284-acamhb00-restore-app:latest done
#11 DONE 0.0s

#12 resolving provenance for metadata file
#12 DONE 0.0s
 Image hw3check-25284-acamhb00-restore-app Built
 Container hw3check-25284-acamhb00-restore-redis-1 Creating
 Container hw3check-25284-acamhb00-restore-redis-1 Created
 Container hw3check-25284-acamhb00-restore-app-1 Creating
 Container hw3check-25284-acamhb00-restore-app-1 Created
 Container hw3check-25284-acamhb00-restore-redis-1 Starting
 Container hw3check-25284-acamhb00-restore-redis-1 Started
 Container hw3check-25284-acamhb00-restore-redis-1 Waiting
 Container hw3check-25284-acamhb00-restore-redis-1 Healthy
 Container hw3check-25284-acamhb00-restore-app-1 Starting
 Container hw3check-25284-acamhb00-restore-app-1 Started
 Container hw3check-25284-acamhb00-restore-app-1 Waiting
 Container hw3check-25284-acamhb00-restore-redis-1 Waiting
 Container hw3check-25284-acamhb00-restore-redis-1 Healthy
 Container hw3check-25284-acamhb00-restore-app-1 Healthy
Приложение доступно на http://127.0.0.1:55012
curl -X GET http://127.0.0.1:55012/ → {"greeting": "Hello, Docker!", "count": 4, "hostname": "3d47794ae5b9", "storage": "redis"}
$ HOST_PORT=0 docker compose --ansi never --project-name hw3check-25284-acamhb00-restore -f compose.yaml down -v --remove-orphans
 Container hw3check-25284-acamhb00-restore-app-1 Stopping
 Container hw3check-25284-acamhb00-restore-app-1 Stopped
 Container hw3check-25284-acamhb00-restore-app-1 Removing
 Container hw3check-25284-acamhb00-restore-app-1 Removed
 Container hw3check-25284-acamhb00-restore-redis-1 Stopping
 Container hw3check-25284-acamhb00-restore-redis-1 Stopped
 Container hw3check-25284-acamhb00-restore-redis-1 Removing
 Container hw3check-25284-acamhb00-restore-redis-1 Removed
 Network hw3check-25284-acamhb00-restore_default Removing
 Volume hw3check-25284-acamhb00-restore_redis-data Removing
 Volume hw3check-25284-acamhb00-restore_redis-data Removed
 Network hw3check-25284-acamhb00-restore_default Removed

OK. Все проверки Redis прошли. Архив сохранён в backups/hw3check-25284-aCaMhB00/redis-data.tar
~~~
