docker logs flashstream-kafdrop

```
2026-03-19 17:27:22.246  WARN 1 [afdrop-producer] o.a.k.c.NetworkClient                    : [Producer clientId=kafdrop-producer] Connection to node 3 (localhost/127.0.0.1:9093) could not be established. Node may not be available.
2026-03-19 17:27:22.712  WARN 1 [| kafdrop-admin] o.a.k.c.NetworkClient                    : [AdminClient clientId=kafdrop-admin] Connection to node 1 (localhost/127.0.0.1:9091) could not be established. Node may not be available.
2026-03-19 17:27:22.813  WARN 1 [| kafdrop-admin] o.a.k.c.NetworkClient                    : [AdminClient clientId=kafdrop-admin] Connection to node 2 (localhost/127.0.0.1:9092) could not be established. Node may not be available.
2026-03-19 17:27:23.097  WARN 1 [afdrop-producer] o.a.k.c.NetworkClient                    : [Producer clientId=kafdrop-producer] Connection to node 2 (localhost/127.0.0.1:9092) could not be established. Node may not be available.
2026-03-19 17:27:23.140  WARN 1 [afdrop-producer] o.a.k.c.NetworkClient                    : [Producer clientId=kafdrop-producer] Connection to node 3 (localhost/127.0.0.1:9093) could not be established. Node may not be available.
```

找到原因了！这是 Docker 容器网络隔离 导致的典型"自闭"现象。

核心问题：

Kafdrop 运行在容器内，它尝试连接 `localhost:9091`。但对容器来说，`localhost` 指的是 Kafdrop 容器自己，而不是你的宿主机，所以它根本找不到 Kafka。

解决方法：


你需要修改 `docker-compose.yml` 中 Kafdrop 的环境变量，让它通过 Docker 内部网络名称（即 Service 名）来访问 Kafka：
```
kafdrop:
    image: obsidiandynamics/kafdrop:latest
    container_name: flashstream-kafdrop
    depends_on:
      - kafka-1
      - kafka-2
      - kafka-3
    ports:
      - "9001:9000"environment:
      # 关键修改：使用容器名和内部监听端口（9091）# 注意：不要用 localhost，要用 kafka-1, kafka-2, kafka-3KAFKA_BROKER_CONNECT: kafka-1:9091,kafka-2:9091,kafka-3:9091JVM_OPTS: "-Xms16m -Xmx64m"networks:
      - kafka-network

```

为什么宿主机能连但 Kafdrop 不行？

-   你的 Java 应用：运行在宿主机，通过 `localhost:9091` 访问映射出来的端口，没问题。
-   Kafdrop：运行在 Docker 网络内，它应该通过容器间的"内线"地址（`kafka-1:9091`）直接通话。

操作步骤：

1.  修改 `docker-compose.yml`。
2.  执行 `docker-compose up -d kafdrop` 重启该容器。
3.  刷新浏览器访问 `http://localhost:9001`。

修改后 Kafdrop 能看到 `order_events` 这个主题了吗？


# 【深入分析】


已修复。关键改动：

**问题原因：**
```
Kafdrop (容器内)  ──✗──>  localhost:9091  (指向容器自己)

需要使用容器间网络地址
```

**解决方案：配置双 listener**

| Listener | 地址 | 用途 |
|----------|------|------|
| EXTERNAL | localhost:9091 | 宿主机访问 (Spring Boot) |
| INTERNAL | kafka-1:29091 | 容器间访问 (Kafdrop) |

**Kafdrop 配置改为：**
```yaml
KAFKA_BROKER_CONNECT: kafka-1:29091,kafka-2:29091,kafka-3:29091
```

重新启动：
```bash
docker-compose down
docker-compose up -d
```