

# 【01】

```
➜  FlashStream git:(master) ✗ docker ps 
CONTAINER ID   IMAGE                             COMMAND                  CREATED         STATUS         PORTS                                                  NAMES
5b673e68ff54   obsidiandynamics/kafdrop:latest   "/kafdrop.sh"            7 seconds ago   Up 6 seconds   0.0.0.0:9001->9000/tcp, [::]:9001->9000/tcp            flashstream-kafdrop
1e701d7b8136   apache/kafka:3.7.0                "/__cacert_entrypoin…"   7 seconds ago   Up 6 seconds   0.0.0.0:9091->9091/tcp, :::9091->9091/tcp, 9092/tcp    kafka-1
57709d106ca7   redis:7-alpine                    "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp              flashstream-redis
b00186a628a4   apache/kafka:3.7.0                "/__cacert_entrypoin…"   7 seconds ago   Up 6 seconds   0.0.0.0:9092->9092/tcp, :::9092->9092/tcp              kafka-2
af223b2c90e3   apache/kafka:3.7.0                "/__cacert_entrypoin…"   7 seconds ago   Up 6 seconds   9092/tcp, 0.0.0.0:9093->9093/tcp, :::9093->9093/tcp    kafka-3
30c205ebd58b   mysql:8                           "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   flashstream-mysql
```