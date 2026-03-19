# FlashStream：高并发秒杀与实时库存系统

![Java](https://img.shields.io/badge/Java-17+-green.svg)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.x-green.svg)
![Kafka](https://img.shields.io/badge/Apache%20Kafka-3.7-blue.svg)

## 项目简介

FlashStream 是一个专注于 **Kafka 实战教学** 的电商秒杀系统。通过三个阶段的递进式实践，帮助开发者深入理解 Kafka 在高并发场景下的流量削峰、异步处理和数据一致性方面的强大能力。

## 业务场景

在促销秒杀活动中，瞬间流量可达平时的 100-1000 倍。如果所有请求直接访问数据库，系统会瞬间崩溃。Kafka 在此场景下发挥核心作用：

```
用户下单请求 → [削峰填谷] → Kafka Topic → 异步消费 → 库存服务/通知服务/积分服务
```

## 系统架构

```
┌─────────────┐     ┌──────────────────────────────────────────────┐
│   前端应用   │────▶│              Order Service (Producer)       │
└─────────────┘     │  • 接收HTTP请求                                │
                    │  • 消息序列化                                  │
                    │  • 分区策略(同用户同分区)                      │
                    └──────────────────┬───────────────────────────┘
                                       │ 写入 Kafka
                                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        Kafka Cluster (3 Brokers)                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │
│  │ Broker 1    │  │ Broker 2    │  │ Broker 3    │                  │
│  │ ISR         │  │ ISR         │  │ ISR         │                  │
│  └─────────────┘  └─────────────┘  └─────────────┘                  │
└────────────────────────────┬────────────────────────────────────────┘
                             │ 消费
        ┌────────────────────┼────────────────────┐
        ▼                    ▼                    ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│Inventory      │    │Notification   │    │Points         │
│Service        │    │Service        │    │Service        │
│• 库存扣减     │    │• 短信通知     │    │• 积分添加     │
│• 分布式锁     │    │               │    │               │
└───────────────┘    └───────────────┘    └───────────────┘
        │                    │                    │
        ▼                    ▼                    ▼
    ┌──────────┐        ┌──────────┐        ┌──────────┐
    │  MySQL   │        │   SMS    │        │  MySQL   │
    └──────────┘        └──────────┘        └──────────┘
```

## 技术栈

| 层次 | 技术选型 |
|------|----------|
| 语言 | Java 17+ |
| 框架 | Spring Boot 3.2.x |
| 消息中间件 | Apache Kafka 3.7 |
| 缓存 | Redis (分布式锁、幂等校验) |
| 数据库 | MySQL 8.0 |
| 容器 | Docker Compose |

## 快速开始

### 1. 启动基础设施

```bash
# 启动 Kafka 集群
docker-compose up -d

# 验证 Kafka 是否就绪
docker-compose logs -f kafka-1
```

### 2. 构建项目

```bash
# 构建所有模块
mvn clean package -DskipTests
```

### 3. 启动服务（按顺序）

```bash
# 启动订单服务 (端口 8081)
java -jar order-service/target/order-service.jar

# 启动库存服务 (端口 8082)
java -jar inventory-service/target/inventory-service.jar

# 启动通知服务 (端口 8083)
java -jar notification-service/target/notification-service.jar
```

### 4. 测试秒杀接口

```bash
# 模拟秒杀下单
curl -X POST http://localhost:8081/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user_123",
    "productId": "product_456",
    "quantity": 1,
    "price": 99.00
  }'
```

## 实战任务路径

### 阶段一：基础连通
- [ ] 使用 KafkaAdminClient 创建 Topic
- [ ] 实现基础 Producer 发送消息
- [ ] 实现基础 Consumer 消费消息

### 阶段二：可靠性与幂等性
- [ ] 配置 Producer acks=all 和 retries
- [ ] 实现 Consumer 幂等性消费（Redis 防重）
- [ ] 处理消息丢失和重复问题

### 阶段三：高级特性
- [ ] 动态增加分区，观察 Rebalance
- [ ] 配置批量消费参数
- [ ] 实现分区重分配策略

## 项目结构

```
FlashStream/
├── docker-compose.yml          # Kafka 集群配置
├── order-service/              # 订单服务 (Producer)
├── inventory-service/         # 库存服务 (Consumer)
├── notification-service/       # 通知服务 (Consumer)
├── common/                    # 公共模块
├── sql/                       # 数据库脚本
└── docs/                      # 教学文档
```

## 学习收获

通过本项目，你将掌握：

1. **Kafka 核心概念**: Topic、Partition、Replica、ISR、Consumer Group
2. **生产者机制**: 消息序列化、分区策略、acks 机制、重试策略
3. **消费者机制**: 消费组、位移管理、Rebalance、拦截器
4. **可靠性保证**: 幂等性、事务、消息不丢不重
5. **性能优化**: 批量发送、压缩、消费者优化

## 注意事项

⚠️ 本项目为教学项目，生产环境使用需根据实际情况调整配置。

---

**开始你的 Kafka 实战之旅吧！**
