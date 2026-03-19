

# 【错误01】

```
   : Kafka startTimeMs: 1773938691020
2026-03-19T16:44:51.030Z  INFO 73156 --- [order-service] [ad | producer-1] org.apache.kafka.clients.NetworkClient   : [Producer clientId=producer-1] Node -3 disconnected.
2026-03-19T16:44:51.031Z  INFO 73156 --- [order-service] [ad | producer-1] org.apache.kafka.clients.NetworkClient   : [Producer clientId=producer-1] Cancelled in-flight API_VERSIONS request with correlation id 0 due to node -3 being disconnected (elapsed time since creation: 0ms, elapsed time since send: 0ms, request timeout: 30000ms)
2026-03-19T16:44:51.031Z  WARN 73156 --- [order-service] [ad | producer-1] org.apache.kafka.clients.NetworkClient   : [Producer clientId=producer-1] Bootstrap broker localhost:9093 (id: -3 rack: null) disconnected
2026-03-19T16:44:51.138Z ERROR 73156 --- [order-service] [nio-8081-exec-1] o.s.k.support.LoggingProducerListener    : Exception thrown when sending a message with key='user_123' and payload='OrderEvent(orderId=ord_1773938690911_8910f747, userId=user_123, productId=product_456, quantity=1, p...' to topic order_events:

org.apache.kafka.common.errors.UnsupportedVersionException: The broker does not support METADATA

2026-03-19T16:44:51.138Z  INFO 73156 --- [order-service] [nio-8081-exec-1] o.a.k.c.p.internals.TransactionManager   : [Producer clientId=producer-1] Transiting to fatal error state due to org.apache.kafka.common.errors.UnsupportedVersionException: The broker does not support METADATA
2026-03-19T16:44:51.143Z ERROR 73156 --- [order-service] [nio-8081-exec-1] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.springframework.kafka.KafkaException: Send failed] with root cause

org.apache.kafka.common.errors.UnsupportedVersionException: The broker does not support METADATA
```


出现 `UnsupportedVersionException: The broker does not support METADATA` 通常不是因为 Kafka 不支持元数据，而是由于 客户端（Java 服务）与 Broker（Kafka 服务端）之间的版本极度不匹配，或者 端口连接到了错误的协议上。
以下是排查建议：

1\. 确认端口是否正确

日志显示你连接的是 `localhost:9093`。

-   通常 Kafka 的默认端口是 `9092`。
-   如果你在本地运行了 SSL/TLS 或者使用了 Docker 映射端口，请确认 `9093` 是否真的是 Plaintext 协议端口。如果 `9093` 实际上是一个 SSL 端口而你用了普通配置，或者它是别的服务，就会报这个错。

2\. 检查版本兼容性


如果你的 Kafka 服务端版本非常老（比如 0.10 之前），而客户端（Spring Boot 3.x）太新，就会出现这种不支持基础 API 的报错。

-   解决方法： 确认你的 Kafka 服务端版本。如果是本地测试，建议下载并运行较新的 Kafka 版本（2.8+ 或 3.x）。

3\. 查看 Kafka 服务端日志


客户端报错 `Node -3 disconnected` 说明连接被服务端主动切断或无法建立。

-   检查 Kafka 进程是否真的在运行。
-   检查 Kafka 的 `server.properties` 中的 `listeners` 配置。如果是在 Docker 中运行，确保 `ADVERTISED_LISTENERS` 配置正确。

4\. 尝试清理 Kafka 元数据


如果是本地开发环境，有时 Zookeeper/KRaft 状态异常也会导致此类诡异报错：

-   停止 Kafka 和 Zookeeper。
-   删除 `/tmp/kafka-logs` 和 `/tmp/zookeeper`（或你配置的 log 目录）。
-   重新启动。

你的 Kafka 是通过 Docker 运行的，还是本地二进制解压运行的？


# 【原因01】


你的 `docker-compose.yml` 配置中存在监听端口冲突和角色定义混乱的问题，这是导致 Kafka 报错 `UnsupportedVersionException` 的根本原因。

核心问题排查：


1.  端口冲突：在所有三个 Broker 中，你都把 `CONTROLLER` 监听器设在了 `9092`。但对于 `kafka-2`，你又把外部访问端口映射到了宿主机的 `9092`。这会导致端口竞争，Metadata 请求可能被发到了错误的控制器端口。
2.  监听地址重叠：你在每个容器内部都用了 `0.0.0.0:9091` 作为 `PLAINTEXT` 端口。虽然容器间是隔离的，但在配置 `KAFKA_CONTROLLER_QUORUM_VOTERS` 时容易引发混乱。
3.  Kafdrop 连接错误：Kafdrop 在容器网络内，应该通过 `9091` 连接，但由于监听器配置问题，它可能也无法正确获取集群状态。

建议的修复方案：

为了让宿主机上的 Java 应用和容器内的 Kafdrop 都能正常工作，请将 Controller 端口 和 Broker 端口 彻底分开。
修改 `docker-compose.yml` 中的 Kafka 部分如下：
```
kafka-1:
    image: apache/kafka:3.7.0container_name: kafka-1
    ports:
      - "9091:9091"environment:
      KAFKA_NODE_ID: 1KAFKA_PROCESS_ROLES: broker,controller
      # 外部连 9091，内部 Controller 连 19091KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9091,CONTROLLER://0.0.0.0:19091KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9091KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka-1:19091,2@kafka-2:19091,3@kafka-3:19091KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
      # 必须设置 CLUSTER_ID (或运行格式化命令)，3.x KRaft 模式建议手动指定KAFKA_CLUSTER_ID: "MkU3OEVBNTcwNTJENDM2Qk"KAFKA_LOG_DIRS: /opt/kafka/logs
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"networks:
      - kafka-network

  kafka-2:
    image: apache/kafka:3.7.0container_name: kafka-2
    ports:
      - "9092:9092"environment:
      KAFKA_NODE_ID: 2KAFKA_PROCESS_ROLES: broker,controller
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:19091KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka-1:19091,2@kafka-2:19091,3@kafka-3:19091KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
      KAFKA_CLUSTER_ID: "MkU3OEVBNTcwNTJENDM2Qk"KAFKA_LOG_DIRS: /opt/kafka/logs
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"networks:
      - kafka-network

  kafka-3:
    image: apache/kafka:3.7.0container_name: kafka-3
    ports:
      - "9093:9093"environment:
      KAFKA_NODE_ID: 3KAFKA_PROCESS_ROLES: broker,controller
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9093,CONTROLLER://0.0.0.0:19091KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9093KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka-1:19091,2@kafka-2:19091,3@kafka-3:19091KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
      KAFKA_CLUSTER_ID: "MkU3OEVBNTcwNTJENDM2Qk"KAFKA_LOG_DIRS: /opt/kafka/logs
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"networks:
      - kafka-network

```

操作步骤：


1.  彻底清理旧数据（非常重要，否则旧的集群元数据会导致新配置无效）：
    ```
    docker-compose down -v

    ```

2.  启动新配置：
    ```
    docker-compose up -d

    ```

3.  修改 Order Service 配置：
    确保 `spring.kafka.bootstrap-servers` 指向所有三个端口：
    ```
    spring:
      kafka:
        bootstrap-servers: localhost:9091,localhost:9092,localhost:9093
    ```

