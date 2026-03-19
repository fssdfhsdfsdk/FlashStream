

## 关键报错分析与解决方案

### 1. Docker Hub 网络超时

**错误信息：**
```
Error response from daemon: Get "https://registry-1.docker.io/v2/": EOF
```

**原因：**
- Docker Hub 在国内网络不稳定
- 镜像体积大（Confluent Kafka 镜像 >1GB）
- Zookeeper 依赖导致需拉取多个镜像

**解决方案：**
| 优化项 | 原来 | 现在 |
|--------|------|------|
| 镜像数量 | 11个 (含3个ZK + Manager + Eagle) | 6个 |
| Kafka 镜像 | confluentinc/cp-kafka (1GB+) | apache/kafka:3.7.0 (较小) |
| 控制器 | Zookeeper 集群 (3节点) | KRaft 模式 (内置) |

---

### 2. `version` 属性警告

**警告信息：**
```
WARN[0000] the attribute `version` is obsolete
```

**原因：**
- Docker Compose V2 默认忽略 `version` 字段

**解决方案：** 移除 `version: '3.8'`

---

### 3. KRaft vs Zookeeper

**原架构：**
```
Producer → Kafka → Zookeeper (外部依赖)
           ↓
        3 Broker + 3 ZK Node = 6 容器
```

**新架构：**
```
Producer → Kafka (KRaft 内置控制器)
           ↓
        3 Broker 自组成控制器集群
```

**优势：**
- 容器减少 50%
- 无需维护 Zookeeper
- Kafka 3.5+ 原生推荐模式

---

### 4. 脚本路径问题

**原路径：** `kafka-topics` (Confluent 版本)

**新路径：** `/opt/kafka/bin/kafka-topics.sh` (Apache Kafka 官方)

---

### 总结

| 问题 | 根因 | 解决方式 |
|------|------|----------|
| 镜像拉取失败 | Docker Hub 不稳定 + 镜像过大 | 换用 apache/kafka 官方镜像 |
| 容器数量多 | Zookeeper 依赖 | 使用 KRaft 模式 |
| 监控工具不可用 | 镜像拉取失败 | 保留 Kafdrop，移除 Kafka Eagle |

现在可以重新运行 `docker-compose up -d` 试试。