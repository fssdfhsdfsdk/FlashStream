

# 【01】

```

Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
2026-03-19T16:22:10.673Z ERROR 38955 --- [order-service] [           main] o.s.b.d.LoggingFailureAnalysisReporter   : 

***************************
APPLICATION FAILED TO START
***************************

Description:

Failed to configure a DataSource: 'url' attribute is not specified and no embedded datasource could be configured.

Reason: Failed to determine a suitable driver class


Action:

Consider the following:
        If you want an embedded database (H2, HSQL or Derby), please put it on the classpath.
        If you have database settings to be loaded from a particular profile you may need to activate it (no profiles are currently active).
```


已修复。问题是 **common 模块依赖了 JPA**，但没有配置数据库。

**修改内容：**

1. **common/pom.xml** - 移除 JPA/MySQL，保留 Redis
2. **inventory-service** - 已有 Redis 依赖，无需修改

**重新构建：**

```bash
# 重新编译
mvn clean install -DskipTests

# 启动服务
java -jar order-service/target/order-service.jar
```

---

**报错原因总结：**

| 错误 | 根因 | 解决 |
|------|------|------|
| DataSource 配置失败 | common 模块引入了 `spring-boot-starter-data-jpa` | 移除 JPA 依赖 |
| No embedded datasource | JPA 尝试启动嵌入式数据库 | 改用纯 Kafka 教学模式 |