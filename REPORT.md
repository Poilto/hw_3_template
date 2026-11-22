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
$ docker build -t hw3-basics:hw3basics-18957-dzlozkrw .
#0 building with "desktop-linux" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 358B done
#1 DONE 0.0s

#2 [internal] load metadata for docker.io/library/python:3.13-slim
#2 ...

#3 [auth] library/python:pull token for registry-1.docker.io
#3 DONE 0.0s

#2 [internal] load metadata for docker.io/library/python:3.13-slim
#2 DONE 3.0s

#4 [internal] load .dockerignore
#4 transferring context: 82B done
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 5.95kB done
#5 DONE 0.0s

#6 [1/5] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90
#6 resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 0.0s done
#6 sha256:42ebab0032b11085076fe636a4286d0178552541033ccc92fb0397048dbedc12 0B / 250B 0.2s
#6 sha256:0e670227450615dd602171dd44b95920546465dfe6074f45e8a41a66b7723d83 0B / 1.27MB 0.2s
#6 sha256:42ebab0032b11085076fe636a4286d0178552541033ccc92fb0397048dbedc12 250B / 250B 0.2s done
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 0B / 11.86MB 0.2s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 0B / 30.21MB 0.2s
#6 sha256:0e670227450615dd602171dd44b95920546465dfe6074f45e8a41a66b7723d83 1.27MB / 1.27MB 0.9s done
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 1.05MB / 11.86MB 1.4s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 2.10MB / 11.86MB 1.7s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 2.10MB / 30.21MB 1.7s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 3.15MB / 11.86MB 2.0s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 4.19MB / 11.86MB 2.1s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 5.24MB / 11.86MB 2.4s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 4.19MB / 30.21MB 2.3s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 6.29MB / 11.86MB 2.6s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 7.34MB / 11.86MB 2.9s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 6.29MB / 30.21MB 2.7s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 8.39MB / 11.86MB 3.2s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 9.44MB / 11.86MB 3.5s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 8.39MB / 30.21MB 3.3s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 10.49MB / 11.86MB 3.6s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 11.53MB / 11.86MB 3.9s
#6 sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 11.86MB / 11.86MB 4.0s done
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 11.53MB / 30.21MB 4.1s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 13.63MB / 30.21MB 4.5s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 15.73MB / 30.21MB 4.8s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 17.83MB / 30.21MB 5.1s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 19.92MB / 30.21MB 5.4s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 22.02MB / 30.21MB 5.7s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 24.12MB / 30.21MB 6.0s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 26.21MB / 30.21MB 6.3s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 28.31MB / 30.21MB 6.6s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 30.21MB / 30.21MB 6.9s
#6 sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 30.21MB / 30.21MB 6.9s done
#6 extracting sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef
#6 extracting sha256:acd43e9bebc37bc4ba7a5f47bd7598913337803e53d468f37d940f11f5d5f1ef 0.4s done
#6 DONE 7.4s

#6 [1/5] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90
#6 extracting sha256:0e670227450615dd602171dd44b95920546465dfe6074f45e8a41a66b7723d83 0.0s done
#6 extracting sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f
#6 extracting sha256:174bfd419dd81cd676d1a8618deb0ba079dc16f9e053afe66908dd3727c3cc3f 0.2s done
#6 DONE 7.6s

#6 [1/5] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90
#6 extracting sha256:42ebab0032b11085076fe636a4286d0178552541033ccc92fb0397048dbedc12 done
#6 DONE 7.6s

#7 [2/5] WORKDIR /app
#7 DONE 1.1s

#8 [3/5] COPY app/requirements.txt ./requirements.txt
#8 DONE 0.0s

#9 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#9 1.732 Collecting redis==5.2.1 (from -r requirements.txt (line 1))
#9 2.148   Downloading redis-5.2.1-py3-none-any.whl.metadata (9.1 kB)
#9 2.232 Downloading redis-5.2.1-py3-none-any.whl (261 kB)
#9 2.509 Installing collected packages: redis
#9 2.628 Successfully installed redis-5.2.1
#9 2.628 WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager, possibly rendering your system unusable. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv. Use the --root-user-action option if you know what you are doing and want to suppress this warning.
#9 2.629 
#9 2.629 [notice] A new release of pip is available: 26.2.2 -> 26.3
#9 2.629 [notice] To update, run: pip install --upgrade pip
#9 DONE 2.7s

#10 [5/5] COPY app/app.py ./app.py
#10 DONE 0.0s

#11 exporting to image
#11 exporting layers 0.1s done
#11 exporting manifest sha256:b775116141521ba883855abf5abdda676d650513687bad22a356d4d245f23d3b done
#11 exporting config sha256:5b69f067fb08e98dcd1655222e5b09ef71b2fdce97645d6f72bf970acaa85022 done
#11 exporting attestation manifest sha256:8b7b2ff48b7417548f53a8a98c89d85d3ea8b57af4363c212c3e672e7dd39301 done
#11 exporting manifest list sha256:19baa46de2005186c3fef750892be5ca05be72c2fe146272b3cac7b211913610 done
#11 naming to docker.io/library/hw3-basics:hw3basics-18957-dzlozkrw done
#11 unpacking to docker.io/library/hw3-basics:hw3basics-18957-dzlozkrw
#11 unpacking to docker.io/library/hw3-basics:hw3basics-18957-dzlozkrw 0.7s done
#11 DONE 0.8s
$ docker run -d -p 127.0.0.1:0:8000 -e GREETING="Hello from docker run" hw3-basics:hw3basics-18957-dzlozkrw
curl -X GET http://127.0.0.1:55000/ → {"greeting": "Hello from docker run", "count": 0, "hostname": "2c2a13cf9579", "storage": "sqlite"}
curl -X POST http://127.0.0.1:55000/increment → {"greeting": "Hello from docker run", "count": 1, "hostname": "2c2a13cf9579", "storage": "sqlite"}
curl -X GET http://127.0.0.1:55000/ → {"greeting": "Hello from docker run", "count": 1, "hostname": "2c2a13cf9579", "storage": "sqlite"}
$ docker logs 2c2a13cf9579de04ca85a9cce5f85b67c30bc1ac6a265c6c576b1f1a70ebede0
2026-11-22 18:35:18,348 listening port=8000 storage=sqlite
2026-11-22 18:35:19,274 http 172.17.0.1 "GET /readyz HTTP/1.1" 200 -
2026-11-22 18:35:19,291 http 172.17.0.1 "GET / HTTP/1.1" 200 -
2026-11-22 18:35:19,426 http 172.17.0.1 "POST /increment HTTP/1.1" 200 -
2026-11-22 18:35:19,522 http 172.17.0.1 "GET / HTTP/1.1" 200 -

== 6 баллов — Compose и именованный volume SQLite ==
$ HOST_PORT=0 GREETING="Hello from Compose" docker compose -f compose.sqlite.yaml up -d --build --wait
 Image hw3basics-18957-dzlozkrw-app Building 
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

#7 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#7 CACHED

#8 [2/5] WORKDIR /app
#8 CACHED

#9 [3/5] COPY app/requirements.txt ./requirements.txt
#9 CACHED

#10 [5/5] COPY app/app.py ./app.py
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:73f680d3cd47525fd407725fb0241ddd17712f74791a5f1c89377e52e2191e79 done
#11 exporting config sha256:c3020f8efe2f02893497d7de4283d45f7f3c64bede459c191630fa9191755e44 done
#11 exporting attestation manifest sha256:cf343a7ec5b17c9fdd4c425bdb178888a4ac871f41e2bb5138580c83714499c5 done
#11 exporting manifest list sha256:d8b867a00ea56d6c36432e210a12c490d179866dd935094980ebe8ab7a12dc10 done
#11 naming to docker.io/library/hw3basics-18957-dzlozkrw-app:latest done
#11 unpacking to docker.io/library/hw3basics-18957-dzlozkrw-app:latest done
#11 DONE 0.0s

#12 resolving provenance for metadata file
#12 DONE 0.0s
 Image hw3basics-18957-dzlozkrw-app Built 
 Volume hw3basics-18957-dzlozkrw_sqlite-data Creating 
 Volume hw3basics-18957-dzlozkrw_sqlite-data Creating 
 Network hw3basics-18957-dzlozkrw_default Creating 
 Network hw3basics-18957-dzlozkrw_default Creating 
 Volume hw3basics-18957-dzlozkrw_sqlite-data Created 
 Volume hw3basics-18957-dzlozkrw_sqlite-data Created 
 Network hw3basics-18957-dzlozkrw_default Created 
 Network hw3basics-18957-dzlozkrw_default Created 
 Container hw3basics-18957-dzlozkrw-app-1 Creating 
 Container hw3basics-18957-dzlozkrw-app-1 Created 
 Container hw3basics-18957-dzlozkrw-app-1 Starting 
 Container hw3basics-18957-dzlozkrw-app-1 Started 
 Container hw3basics-18957-dzlozkrw-app-1 Waiting 
 Container hw3basics-18957-dzlozkrw-app-1 Healthy 
curl -X GET http://127.0.0.1:55001/ → {"greeting": "Hello from Compose", "count": 0, "hostname": "3cf768dd546d", "storage": "sqlite"}
curl -X POST http://127.0.0.1:55001/increment → {"greeting": "Hello from Compose", "count": 1, "hostname": "3cf768dd546d", "storage": "sqlite"}
Контейнер 3cf768dd546daffb97eca238a2c741f7e41a12117d8e6d28fd70bf845ac83530 и volume hw3basics-18957-dzlozkrw_sqlite-data
$ docker compose -f compose.sqlite.yaml down
$ docker compose -f compose.sqlite.yaml up -d --wait
 Container hw3basics-18957-dzlozkrw-app-1 Stopping 
 Container hw3basics-18957-dzlozkrw-app-1 Stopped 
 Container hw3basics-18957-dzlozkrw-app-1 Removing 
 Container hw3basics-18957-dzlozkrw-app-1 Removed 
 Network hw3basics-18957-dzlozkrw_default Removing 
 Network hw3basics-18957-dzlozkrw_default Removed 
 Network hw3basics-18957-dzlozkrw_default Creating 
 Network hw3basics-18957-dzlozkrw_default Creating 
 Network hw3basics-18957-dzlozkrw_default Created 
 Network hw3basics-18957-dzlozkrw_default Created 
 Container hw3basics-18957-dzlozkrw-app-1 Creating 
 Container hw3basics-18957-dzlozkrw-app-1 Created 
 Container hw3basics-18957-dzlozkrw-app-1 Starting 
 Container hw3basics-18957-dzlozkrw-app-1 Started 
 Container hw3basics-18957-dzlozkrw-app-1 Waiting 
 Container hw3basics-18957-dzlozkrw-app-1 Healthy 
curl -X GET http://127.0.0.1:55002/ → {"greeting": "Hello from Compose", "count": 1, "hostname": "bfefb205ca08", "storage": "sqlite"}
Новый контейнер bfefb205ca08734c5c08c55d9b15323d711e96c0bf10ceac27074dc2b7e42f3d использует прежний volume hw3basics-18957-dzlozkrw_sqlite-data
 Container hw3basics-18957-dzlozkrw-app-1 Stopping 
 Container hw3basics-18957-dzlozkrw-app-1 Stopped 
 Container hw3basics-18957-dzlozkrw-app-1 Removing 
 Container hw3basics-18957-dzlozkrw-app-1 Removed 
 Network hw3basics-18957-dzlozkrw_default Removing 
 Volume hw3basics-18957-dzlozkrw_sqlite-data Removing 
 Volume hw3basics-18957-dzlozkrw_sqlite-data Removed 
 Network hw3basics-18957-dzlozkrw_default Removed 

OK. Проверки Docker и Compose с SQLite прошли
~~~

## 8 и 10 баллов. Redis, первый запуск

~~~text

== Чистый тестовый проект ==
$ docker compose -p hw3check-19630-i1hbeb80 up -d --build --wait --wait-timeout 60
 Image redis:7.4-alpine Pulling 
 16cda2556898 Pulling fs layer 0B
 54abef31ddd9 Pulling fs layer 0B
 e8978eba2bb2 Pulling fs layer 0B
 8fe75981dbac Pulling fs layer 0B
 fb602ba0b128 Pulling fs layer 0B
 4f4fb700ef54 Pulling fs layer 0B
 fea5b91588ca Pulling fs layer 0B
 a99ab7f50347 Download complete 0B
 4704a97c8705 Download complete 0B
 fb602ba0b128 Download complete 0B
 8fe75981dbac Download complete 0B
 fea5b91588ca Downloading 1.049MB
 fea5b91588ca Downloading 2.097MB
 fea5b91588ca Downloading 2.097MB
 fea5b91588ca Downloading 3.146MB
 4f4fb700ef54 Download complete 0B
 fea5b91588ca Download complete 0B
 fea5b91588ca Extracting 1B
 fb602ba0b128 Pull complete 0B
 8fe75981dbac Pull complete 0B
 fea5b91588ca Pull complete 0B
 16cda2556898 Download complete 0B
 e8978eba2bb2 Download complete 0B
 54abef31ddd9 Downloading 1.049MB
 54abef31ddd9 Downloading 1.049MB
 54abef31ddd9 Downloading 1.049MB
 54abef31ddd9 Downloading 2.097MB
 54abef31ddd9 Downloading 3.146MB
 54abef31ddd9 Downloading 4.194MB
 54abef31ddd9 Downloading 4.194MB
 54abef31ddd9 Downloading 5.243MB
 54abef31ddd9 Downloading 5.243MB
 54abef31ddd9 Downloading 5.243MB
 54abef31ddd9 Downloading 5.243MB
 54abef31ddd9 Downloading 7.34MB
 54abef31ddd9 Downloading 7.34MB
 54abef31ddd9 Downloading 8.389MB
 54abef31ddd9 Downloading 9.437MB
 54abef31ddd9 Downloading 9.437MB
 54abef31ddd9 Downloading 10.49MB
 54abef31ddd9 Downloading 10.49MB
 54abef31ddd9 Downloading 10.49MB
 54abef31ddd9 Downloading 12.58MB
 54abef31ddd9 Download complete 0B
 54abef31ddd9 Extracting 1B
 4f4fb700ef54 Pull complete 0B
 16cda2556898 Pull complete 0B
 e8978eba2bb2 Pull complete 0B
 54abef31ddd9 Pull complete 0B
 Image redis:7.4-alpine Pulled 
 Image hw3check-19630-i1hbeb80-app Building 
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
#6 resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 0.0s done
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
#11 exporting manifest sha256:733f5e538762a17fcd526d78720ddbb5c46f5b6fa8920189718d651a5f951f98 done
#11 exporting config sha256:e6686776e5f9636ef6c50702d9e06feaa3693cc5465ba7f683487119fad59241 done
#11 exporting attestation manifest sha256:39a953bdf94edda43c0e8e5189309600993c44addffbcf2d3ad8d436d633a025 done
#11 exporting manifest list sha256:f1575b5c1617eba535ea7ee51c13859f64f84d0aa577c6ba033237714f641a9d done
#11 naming to docker.io/library/hw3check-19630-i1hbeb80-app:latest done
#11 unpacking to docker.io/library/hw3check-19630-i1hbeb80-app:latest done
#11 DONE 0.0s

#12 resolving provenance for metadata file
#12 DONE 0.0s
 Image hw3check-19630-i1hbeb80-app Built 
 Network hw3check-19630-i1hbeb80_default Creating 
 Network hw3check-19630-i1hbeb80_default Creating 
 Volume hw3check-19630-i1hbeb80_redis-data Creating 
 Volume hw3check-19630-i1hbeb80_redis-data Creating 
 Volume hw3check-19630-i1hbeb80_redis-data Created 
 Volume hw3check-19630-i1hbeb80_redis-data Created 
 Network hw3check-19630-i1hbeb80_default Created 
 Network hw3check-19630-i1hbeb80_default Created 
 Container hw3check-19630-i1hbeb80-redis-1 Creating 
 Container hw3check-19630-i1hbeb80-redis-1 Created 
 Container hw3check-19630-i1hbeb80-app-1 Creating 
 Container hw3check-19630-i1hbeb80-app-1 Created 
 Container hw3check-19630-i1hbeb80-redis-1 Starting 
 Container hw3check-19630-i1hbeb80-redis-1 Started 
 Container hw3check-19630-i1hbeb80-redis-1 Waiting 
 Container hw3check-19630-i1hbeb80-redis-1 Healthy 
 Container hw3check-19630-i1hbeb80-app-1 Starting 
 Container hw3check-19630-i1hbeb80-app-1 Started 
 Container hw3check-19630-i1hbeb80-app-1 Waiting 
 Container hw3check-19630-i1hbeb80-redis-1 Waiting 
 Container hw3check-19630-i1hbeb80-redis-1 Healthy 
 Container hw3check-19630-i1hbeb80-app-1 Healthy 
Приложение доступно на http://127.0.0.1:55003
curl -X GET http://127.0.0.1:55003/readyz → HTTP 200
curl -X GET http://127.0.0.1:55003/ → {"greeting": "Hello, Docker!", "count": 0, "hostname": "2728a51d7a6e", "storage": "redis"}

== Ограничения приложения ==
UID=10001, read_only/RAM_bytes/NanoCPUs = true 268435456 1000000000

== Три инкремента ==
curl -X POST http://127.0.0.1:55003/increment → {"greeting": "Hello, Docker!", "count": 1, "hostname": "2728a51d7a6e", "storage": "redis"}
curl -X POST http://127.0.0.1:55003/increment → {"greeting": "Hello, Docker!", "count": 2, "hostname": "2728a51d7a6e", "storage": "redis"}
curl -X POST http://127.0.0.1:55003/increment → {"greeting": "Hello, Docker!", "count": 3, "hostname": "2728a51d7a6e", "storage": "redis"}
curl -X GET http://127.0.0.1:55003/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "2728a51d7a6e", "storage": "redis"}

== Пересоздание только app ==
$ docker compose up -d --no-deps --force-recreate --wait --wait-timeout 60 app
 Container hw3check-19630-i1hbeb80-app-1 Recreate 
 Container hw3check-19630-i1hbeb80-app-1 Recreated 
 Container hw3check-19630-i1hbeb80-app-1 Starting 
 Container hw3check-19630-i1hbeb80-app-1 Started 
 Container hw3check-19630-i1hbeb80-app-1 Waiting 
 Container hw3check-19630-i1hbeb80-app-1 Healthy 
Приложение доступно на http://127.0.0.1:55004
curl -X GET http://127.0.0.1:55004/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "f8abc1b042a9", "storage": "redis"}

== Сохранение данных после down и up ==
$ docker compose down
$ docker compose up -d --wait --wait-timeout 60
 Container hw3check-19630-i1hbeb80-app-1 Stopping 
 Container hw3check-19630-i1hbeb80-app-1 Stopped 
 Container hw3check-19630-i1hbeb80-app-1 Removing 
 Container hw3check-19630-i1hbeb80-app-1 Removed 
 Container hw3check-19630-i1hbeb80-redis-1 Stopping 
 Container hw3check-19630-i1hbeb80-redis-1 Stopped 
 Container hw3check-19630-i1hbeb80-redis-1 Removing 
 Container hw3check-19630-i1hbeb80-redis-1 Removed 
 Network hw3check-19630-i1hbeb80_default Removing 
 Network hw3check-19630-i1hbeb80_default Removed 
 Network hw3check-19630-i1hbeb80_default Creating 
 Network hw3check-19630-i1hbeb80_default Creating 
 Network hw3check-19630-i1hbeb80_default Created 
 Network hw3check-19630-i1hbeb80_default Created 
 Container hw3check-19630-i1hbeb80-redis-1 Creating 
 Container hw3check-19630-i1hbeb80-redis-1 Created 
 Container hw3check-19630-i1hbeb80-app-1 Creating 
 Container hw3check-19630-i1hbeb80-app-1 Created 
 Container hw3check-19630-i1hbeb80-redis-1 Starting 
 Container hw3check-19630-i1hbeb80-redis-1 Started 
 Container hw3check-19630-i1hbeb80-redis-1 Waiting 
 Container hw3check-19630-i1hbeb80-redis-1 Healthy 
 Container hw3check-19630-i1hbeb80-app-1 Starting 
 Container hw3check-19630-i1hbeb80-app-1 Started 
 Container hw3check-19630-i1hbeb80-redis-1 Waiting 
 Container hw3check-19630-i1hbeb80-app-1 Waiting 
 Container hw3check-19630-i1hbeb80-redis-1 Healthy 
 Container hw3check-19630-i1hbeb80-app-1 Healthy 
Приложение доступно на http://127.0.0.1:55005
curl -X GET http://127.0.0.1:55005/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "db4e166fe5f6", "storage": "redis"}

== Сбой Redis и восстановление без перезапуска app ==
$ docker compose stop redis
 Container hw3check-19630-i1hbeb80-redis-1 Stopping 
 Container hw3check-19630-i1hbeb80-redis-1 Stopped 
curl -X GET http://127.0.0.1:55005/healthz → HTTP 200
curl -X GET http://127.0.0.1:55005/readyz → HTTP 503
curl -X POST http://127.0.0.1:55005/increment → HTTP 503
$ docker compose start redis
 Container hw3check-19630-i1hbeb80-redis-1 Starting 
 Container hw3check-19630-i1hbeb80-redis-1 Started 
curl -X GET http://127.0.0.1:55005/readyz → HTTP 200
ID и время запуска app совпали с исходными
curl -X GET http://127.0.0.1:55005/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "db4e166fe5f6", "storage": "redis"}
curl -X POST http://127.0.0.1:55005/increment → {"greeting": "Hello, Docker!", "count": 4, "hostname": "db4e166fe5f6", "storage": "redis"}

== Резервная копия остановленного Redis ==
$ docker compose stop app redis
 Container hw3check-19630-i1hbeb80-app-1 Stopping 
 Container hw3check-19630-i1hbeb80-app-1 Stopped 
 Container hw3check-19630-i1hbeb80-redis-1 Stopping 
 Container hw3check-19630-i1hbeb80-redis-1 Stopped 
$ docker compose run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -cpf - . > backups/hw3check-19630-i1HbEb80/redis-data.tar
 Container hw3check-19630-i1hbeb80-redis-run-92a6878c1a35 Creating 
 Container hw3check-19630-i1hbeb80-redis-run-92a6878c1a35 Created 

== Удаление исходного тестового проекта и его volumes ==
$ docker compose -p hw3check-19630-i1hbeb80 down -v
 Container hw3check-19630-i1hbeb80-app-1 Stopping 
 Container hw3check-19630-i1hbeb80-app-1 Stopped 
 Container hw3check-19630-i1hbeb80-app-1 Removing 
 Container hw3check-19630-i1hbeb80-app-1 Removed 
 Container hw3check-19630-i1hbeb80-redis-1 Stopping 
 Container hw3check-19630-i1hbeb80-redis-1 Stopped 
 Container hw3check-19630-i1hbeb80-redis-1 Removing 
 Container hw3check-19630-i1hbeb80-redis-1 Removed 
 Network hw3check-19630-i1hbeb80_default Removing 
 Volume hw3check-19630-i1hbeb80_redis-data Removing 
 Volume hw3check-19630-i1hbeb80_redis-data Removed 
 Network hw3check-19630-i1hbeb80_default Removed 

== Проверка архива в новом тестовом проекте ==
$ docker compose run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -xpf - < backups/hw3check-19630-i1HbEb80/redis-data.tar
 Volume hw3check-19630-i1hbeb80-restore_redis-data Creating 
 Volume hw3check-19630-i1hbeb80-restore_redis-data Creating 
 Network hw3check-19630-i1hbeb80-restore_default Creating 
 Network hw3check-19630-i1hbeb80-restore_default Creating 
 Volume hw3check-19630-i1hbeb80-restore_redis-data Created 
 Volume hw3check-19630-i1hbeb80-restore_redis-data Created 
 Network hw3check-19630-i1hbeb80-restore_default Created 
 Network hw3check-19630-i1hbeb80-restore_default Created 
 Container hw3check-19630-i1hbeb80-restore-redis-run-f2b354221b05 Creating 
 Container hw3check-19630-i1hbeb80-restore-redis-run-f2b354221b05 Created 
 Image hw3check-19630-i1hbeb80-restore-app Building 
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

#8 [3/5] COPY app/requirements.txt ./requirements.txt
#8 CACHED

#9 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#9 CACHED

#10 [5/5] COPY app/app.py ./app.py
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:6b4b15e640dcb862e3e7c0c7c73f61b5db43775ef3691f80989dcf99f38060bf done
#11 exporting config sha256:240dc17c2a1c5464ac55bae5cd03b846de5436cc50eab845d193a0384b77a614 done
#11 exporting attestation manifest sha256:906ddfb090ab72a8c55715b7877e535413bbc2910cbeab15cd99e134108d22eb done
#11 exporting manifest list sha256:c39fbeffd70838ab8488ba681b71f734b0088a745b9ba1e9e86a5156e2485b74 done
#11 naming to docker.io/library/hw3check-19630-i1hbeb80-restore-app:latest done
#11 unpacking to docker.io/library/hw3check-19630-i1hbeb80-restore-app:latest done
#11 DONE 0.0s

#12 resolving provenance for metadata file
#12 DONE 0.0s
 Image hw3check-19630-i1hbeb80-restore-app Built 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Creating 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Created 
 Container hw3check-19630-i1hbeb80-restore-app-1 Creating 
 Container hw3check-19630-i1hbeb80-restore-app-1 Created 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Starting 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Started 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Waiting 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Healthy 
 Container hw3check-19630-i1hbeb80-restore-app-1 Starting 
 Container hw3check-19630-i1hbeb80-restore-app-1 Started 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Waiting 
 Container hw3check-19630-i1hbeb80-restore-app-1 Waiting 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Healthy 
 Container hw3check-19630-i1hbeb80-restore-app-1 Healthy 
Приложение доступно на http://127.0.0.1:55006
curl -X GET http://127.0.0.1:55006/ → {"greeting": "Hello, Docker!", "count": 4, "hostname": "b237c0dc8703", "storage": "redis"}
$ docker compose -p hw3check-19630-i1hbeb80-restore down -v
 Container hw3check-19630-i1hbeb80-restore-app-1 Stopping 
 Container hw3check-19630-i1hbeb80-restore-app-1 Stopped 
 Container hw3check-19630-i1hbeb80-restore-app-1 Removing 
 Container hw3check-19630-i1hbeb80-restore-app-1 Removed 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Stopping 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Stopped 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Removing 
 Container hw3check-19630-i1hbeb80-restore-redis-1 Removed 
 Volume hw3check-19630-i1hbeb80-restore_redis-data Removing 
 Network hw3check-19630-i1hbeb80-restore_default Removing 
 Volume hw3check-19630-i1hbeb80-restore_redis-data Removed 
 Network hw3check-19630-i1hbeb80-restore_default Removed 

OK. Все проверки Redis прошли. Архив сохранён в backups/hw3check-19630-i1HbEb80/redis-data.tar
~~~

## 8 и 10 баллов. Redis, второй запуск

~~~text

== Чистый тестовый проект ==
$ docker compose -p hw3check-19890-ui3fvtcz up -d --build --wait --wait-timeout 60
 Image hw3check-19890-ui3fvtcz-app Building 
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
#6 resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 0.0s done
#6 DONE 0.0s

#7 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#7 CACHED

#8 [3/5] COPY app/requirements.txt ./requirements.txt
#8 CACHED

#9 [2/5] WORKDIR /app
#9 CACHED

#10 [5/5] COPY app/app.py ./app.py
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:ab183f11c295612d7e63999d640d038c141369077aeb7d7d66d1e49ad5f017c2 done
#11 exporting config sha256:73f6708ca3260b691dec6259e574de7ce6b22b31408205c282fb1cfeef73e455 done
#11 exporting attestation manifest sha256:766d4ca5e7cba4af58da5092b00fe7e594c425c6a88f73d523044d185e915a3a done
#11 exporting manifest list sha256:d26cd5a6a18b89da5e52e025f1c3c21a4ad2b32506662f166d4d1eb02e596356 done
#11 naming to docker.io/library/hw3check-19890-ui3fvtcz-app:latest done
#11 unpacking to docker.io/library/hw3check-19890-ui3fvtcz-app:latest done
#11 DONE 0.0s

#12 resolving provenance for metadata file
#12 DONE 0.0s
 Image hw3check-19890-ui3fvtcz-app Built 
 Volume hw3check-19890-ui3fvtcz_redis-data Creating 
 Volume hw3check-19890-ui3fvtcz_redis-data Creating 
 Network hw3check-19890-ui3fvtcz_default Creating 
 Network hw3check-19890-ui3fvtcz_default Creating 
 Volume hw3check-19890-ui3fvtcz_redis-data Created 
 Volume hw3check-19890-ui3fvtcz_redis-data Created 
 Network hw3check-19890-ui3fvtcz_default Created 
 Network hw3check-19890-ui3fvtcz_default Created 
 Container hw3check-19890-ui3fvtcz-redis-1 Creating 
 Container hw3check-19890-ui3fvtcz-redis-1 Created 
 Container hw3check-19890-ui3fvtcz-app-1 Creating 
 Container hw3check-19890-ui3fvtcz-app-1 Created 
 Container hw3check-19890-ui3fvtcz-redis-1 Starting 
 Container hw3check-19890-ui3fvtcz-redis-1 Started 
 Container hw3check-19890-ui3fvtcz-redis-1 Waiting 
 Container hw3check-19890-ui3fvtcz-redis-1 Healthy 
 Container hw3check-19890-ui3fvtcz-app-1 Starting 
 Container hw3check-19890-ui3fvtcz-app-1 Started 
 Container hw3check-19890-ui3fvtcz-redis-1 Waiting 
 Container hw3check-19890-ui3fvtcz-app-1 Waiting 
 Container hw3check-19890-ui3fvtcz-redis-1 Healthy 
 Container hw3check-19890-ui3fvtcz-app-1 Healthy 
Приложение доступно на http://127.0.0.1:55007
curl -X GET http://127.0.0.1:55007/readyz → HTTP 200
curl -X GET http://127.0.0.1:55007/ → {"greeting": "Hello, Docker!", "count": 0, "hostname": "c582763b4972", "storage": "redis"}

== Ограничения приложения ==
UID=10001, read_only/RAM_bytes/NanoCPUs = true 268435456 1000000000

== Три инкремента ==
curl -X POST http://127.0.0.1:55007/increment → {"greeting": "Hello, Docker!", "count": 1, "hostname": "c582763b4972", "storage": "redis"}
curl -X POST http://127.0.0.1:55007/increment → {"greeting": "Hello, Docker!", "count": 2, "hostname": "c582763b4972", "storage": "redis"}
curl -X POST http://127.0.0.1:55007/increment → {"greeting": "Hello, Docker!", "count": 3, "hostname": "c582763b4972", "storage": "redis"}
curl -X GET http://127.0.0.1:55007/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "c582763b4972", "storage": "redis"}

== Пересоздание только app ==
$ docker compose up -d --no-deps --force-recreate --wait --wait-timeout 60 app
 Container hw3check-19890-ui3fvtcz-app-1 Recreate 
 Container hw3check-19890-ui3fvtcz-app-1 Recreated 
 Container hw3check-19890-ui3fvtcz-app-1 Starting 
 Container hw3check-19890-ui3fvtcz-app-1 Started 
 Container hw3check-19890-ui3fvtcz-app-1 Waiting 
 Container hw3check-19890-ui3fvtcz-app-1 Healthy 
Приложение доступно на http://127.0.0.1:55008
curl -X GET http://127.0.0.1:55008/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "1ac46ed11f96", "storage": "redis"}

== Сохранение данных после down и up ==
$ docker compose down
$ docker compose up -d --wait --wait-timeout 60
 Container hw3check-19890-ui3fvtcz-app-1 Stopping 
 Container hw3check-19890-ui3fvtcz-app-1 Stopped 
 Container hw3check-19890-ui3fvtcz-app-1 Removing 
 Container hw3check-19890-ui3fvtcz-app-1 Removed 
 Container hw3check-19890-ui3fvtcz-redis-1 Stopping 
 Container hw3check-19890-ui3fvtcz-redis-1 Stopped 
 Container hw3check-19890-ui3fvtcz-redis-1 Removing 
 Container hw3check-19890-ui3fvtcz-redis-1 Removed 
 Network hw3check-19890-ui3fvtcz_default Removing 
 Network hw3check-19890-ui3fvtcz_default Removed 
 Network hw3check-19890-ui3fvtcz_default Creating 
 Network hw3check-19890-ui3fvtcz_default Creating 
 Network hw3check-19890-ui3fvtcz_default Created 
 Network hw3check-19890-ui3fvtcz_default Created 
 Container hw3check-19890-ui3fvtcz-redis-1 Creating 
 Container hw3check-19890-ui3fvtcz-redis-1 Created 
 Container hw3check-19890-ui3fvtcz-app-1 Creating 
 Container hw3check-19890-ui3fvtcz-app-1 Created 
 Container hw3check-19890-ui3fvtcz-redis-1 Starting 
 Container hw3check-19890-ui3fvtcz-redis-1 Started 
 Container hw3check-19890-ui3fvtcz-redis-1 Waiting 
 Container hw3check-19890-ui3fvtcz-redis-1 Healthy 
 Container hw3check-19890-ui3fvtcz-app-1 Starting 
 Container hw3check-19890-ui3fvtcz-app-1 Started 
 Container hw3check-19890-ui3fvtcz-app-1 Waiting 
 Container hw3check-19890-ui3fvtcz-redis-1 Waiting 
 Container hw3check-19890-ui3fvtcz-redis-1 Healthy 
 Container hw3check-19890-ui3fvtcz-app-1 Healthy 
Приложение доступно на http://127.0.0.1:55009
curl -X GET http://127.0.0.1:55009/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "d67c79fafbcd", "storage": "redis"}

== Сбой Redis и восстановление без перезапуска app ==
$ docker compose stop redis
 Container hw3check-19890-ui3fvtcz-redis-1 Stopping 
 Container hw3check-19890-ui3fvtcz-redis-1 Stopped 
curl -X GET http://127.0.0.1:55009/healthz → HTTP 200
curl -X GET http://127.0.0.1:55009/readyz → HTTP 503
curl -X POST http://127.0.0.1:55009/increment → HTTP 503
$ docker compose start redis
 Container hw3check-19890-ui3fvtcz-redis-1 Starting 
 Container hw3check-19890-ui3fvtcz-redis-1 Started 
curl -X GET http://127.0.0.1:55009/readyz → HTTP 200
ID и время запуска app совпали с исходными
curl -X GET http://127.0.0.1:55009/ → {"greeting": "Hello, Docker!", "count": 3, "hostname": "d67c79fafbcd", "storage": "redis"}
curl -X POST http://127.0.0.1:55009/increment → {"greeting": "Hello, Docker!", "count": 4, "hostname": "d67c79fafbcd", "storage": "redis"}

== Резервная копия остановленного Redis ==
$ docker compose stop app redis
 Container hw3check-19890-ui3fvtcz-app-1 Stopping 
 Container hw3check-19890-ui3fvtcz-app-1 Stopped 
 Container hw3check-19890-ui3fvtcz-redis-1 Stopping 
 Container hw3check-19890-ui3fvtcz-redis-1 Stopped 
$ docker compose run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -cpf - . > backups/hw3check-19890-Ui3fVtCZ/redis-data.tar
 Container hw3check-19890-ui3fvtcz-redis-run-33dce3208107 Creating 
 Container hw3check-19890-ui3fvtcz-redis-run-33dce3208107 Created 

== Удаление исходного тестового проекта и его volumes ==
$ docker compose -p hw3check-19890-ui3fvtcz down -v
 Container hw3check-19890-ui3fvtcz-app-1 Stopping 
 Container hw3check-19890-ui3fvtcz-app-1 Stopped 
 Container hw3check-19890-ui3fvtcz-app-1 Removing 
 Container hw3check-19890-ui3fvtcz-app-1 Removed 
 Container hw3check-19890-ui3fvtcz-redis-1 Stopping 
 Container hw3check-19890-ui3fvtcz-redis-1 Stopped 
 Container hw3check-19890-ui3fvtcz-redis-1 Removing 
 Container hw3check-19890-ui3fvtcz-redis-1 Removed 
 Network hw3check-19890-ui3fvtcz_default Removing 
 Volume hw3check-19890-ui3fvtcz_redis-data Removing 
 Volume hw3check-19890-ui3fvtcz_redis-data Removed 
 Network hw3check-19890-ui3fvtcz_default Removed 

== Проверка архива в новом тестовом проекте ==
$ docker compose run --rm --no-deps -T --user 0:0 --entrypoint tar redis -C /data -xpf - < backups/hw3check-19890-Ui3fVtCZ/redis-data.tar
 Volume hw3check-19890-ui3fvtcz-restore_redis-data Creating 
 Volume hw3check-19890-ui3fvtcz-restore_redis-data Creating 
 Network hw3check-19890-ui3fvtcz-restore_default Creating 
 Network hw3check-19890-ui3fvtcz-restore_default Creating 
 Volume hw3check-19890-ui3fvtcz-restore_redis-data Created 
 Volume hw3check-19890-ui3fvtcz-restore_redis-data Created 
 Network hw3check-19890-ui3fvtcz-restore_default Created 
 Network hw3check-19890-ui3fvtcz-restore_default Created 
 Container hw3check-19890-ui3fvtcz-restore-redis-run-e9c3bb01ecf6 Creating 
 Container hw3check-19890-ui3fvtcz-restore-redis-run-e9c3bb01ecf6 Created 
 Image hw3check-19890-ui3fvtcz-restore-app Building 
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

#8 [3/5] COPY app/requirements.txt ./requirements.txt
#8 CACHED

#9 [4/5] RUN pip install --no-cache-dir -r requirements.txt     && mkdir -p /data     && chown 10001:10001 /data
#9 CACHED

#10 [5/5] COPY app/app.py ./app.py
#10 CACHED

#11 exporting to image
#11 exporting layers done
#11 exporting manifest sha256:3107f91dbe85daa8f2267972148cc8424611a9df4e8dbd4ce963937660c91bd3 done
#11 exporting config sha256:bfc85ddbd147a97157ae2fdbaa59e7a41aa254091d2329b85ff1ef49744668b8 done
#11 exporting attestation manifest sha256:8fa7acf7ae43689f9c49365ef31797dac28a178cc73bc447389c010696767463 done
#11 exporting manifest list sha256:17f36306813dc2d55fb0fe56c16338e7921a0ebf6e1bec02a643ff36ebcc3c1c done
#11 naming to docker.io/library/hw3check-19890-ui3fvtcz-restore-app:latest done
#11 unpacking to docker.io/library/hw3check-19890-ui3fvtcz-restore-app:latest done
#11 DONE 0.0s

#12 resolving provenance for metadata file
#12 DONE 0.0s
 Image hw3check-19890-ui3fvtcz-restore-app Built 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Creating 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Created 
 Container hw3check-19890-ui3fvtcz-restore-app-1 Creating 
 Container hw3check-19890-ui3fvtcz-restore-app-1 Created 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Starting 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Started 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Waiting 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Healthy 
 Container hw3check-19890-ui3fvtcz-restore-app-1 Starting 
 Container hw3check-19890-ui3fvtcz-restore-app-1 Started 
 Container hw3check-19890-ui3fvtcz-restore-app-1 Waiting 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Waiting 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Healthy 
 Container hw3check-19890-ui3fvtcz-restore-app-1 Healthy 
Приложение доступно на http://127.0.0.1:55010
curl -X GET http://127.0.0.1:55010/ → {"greeting": "Hello, Docker!", "count": 4, "hostname": "a9f478c06d95", "storage": "redis"}
$ docker compose -p hw3check-19890-ui3fvtcz-restore down -v
 Container hw3check-19890-ui3fvtcz-restore-app-1 Stopping 
 Container hw3check-19890-ui3fvtcz-restore-app-1 Stopped 
 Container hw3check-19890-ui3fvtcz-restore-app-1 Removing 
 Container hw3check-19890-ui3fvtcz-restore-app-1 Removed 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Stopping 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Stopped 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Removing 
 Container hw3check-19890-ui3fvtcz-restore-redis-1 Removed 
 Volume hw3check-19890-ui3fvtcz-restore_redis-data Removing 
 Network hw3check-19890-ui3fvtcz-restore_default Removing 
 Volume hw3check-19890-ui3fvtcz-restore_redis-data Removed 
 Network hw3check-19890-ui3fvtcz-restore_default Removed 

OK. Все проверки Redis прошли. Архив сохранён в backups/hw3check-19890-Ui3fVtCZ/redis-data.tar
~~~
