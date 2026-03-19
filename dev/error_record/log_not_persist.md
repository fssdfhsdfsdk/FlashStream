
目前日志没有持久化，只输出到控制台。需要配置日志文件持久化。

```
  file:
    name: logs/order-service.log
    max-size: 10MB
    max-history: 30
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"

```


已配置日志持久化。**日志存储位置：**

```
FlashStream/
├── order-service/
│   └── logs/
│       └── order-service.log          # 订单服务日志
├── inventory-service/
│   └── logs/
│       └── inventory-service.log      # 库存服务日志
├── notification-service/
│   └── logs/
│       └── notification-service.log   # 通知服务日志
```

**日志配置说明：**

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `logging.file.name` | `logs/xxx.log` | 日志文件路径 |
| `logging.file.max-size` | 10MB | 单文件最大大小 |
| `logging.file.max-history` | 30 | 保留天数 |

**特点：**
- 自动滚动：`max-size` 达到后自动创建新文件
- 保留 30 天：`max-history: 30`
- 同时输出到控制台和文件