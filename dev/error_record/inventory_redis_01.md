

```
2026-03-19T16:59:38.983Z ERROR 111889 --- [inventory-service] [           main] o.s.b.d.LoggingFailureAnalysisReporter   : 

***************************
APPLICATION FAILED TO START
***************************

Description:

Parameter 0 of constructor in com.flashstream.inventory.util.DistributedLock required a bean of type 'org.springframework.data.redis.core.RedisTemplate' that could not be found.


Action:

Consider defining a bean of type 'org.springframework.data.redis.core.RedisTemplate' in your configuration.
```

这是因为 Spring Boot 没能自动为你创建一个 `RedisTemplate` Bean。通常有两个原因：缺少依赖 或 没有配置 Redis 连接。
请按照以下步骤检查：

1\. 检查依赖 (pom.xml)


确保你的 `inventory-service` 中引入了 Redis 的 Starter 依赖：
```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

```

2\. 添加配置 (application.yml)


即便 Redis 已经在 Docker 里跑着了，你也要告诉 Spring 去哪找它。请检查配置：
```
spring:
  data:
    redis:
      host: localhost
      port: 6379
```

3\. 手动定义 Bean (如果用了自定义 Key/Value 类型)


如果你在 `DistributedLock` 中要求的是特定泛型的 `RedisTemplate<String, Object>`，Spring 默认提供的 `RedisTemplate<Object, Object>` 可能无法自动匹配。
你可以在配置类中手动定义一个：
```
@ConfigurationpublicclassRedisConfig {
    @BeanpublicRedisTemplate<String, Object> redisTemplate(RedisConnectionFactoryfactory) {
        RedisTemplate<String, Object> template = newRedisTemplate<>();
        template.setConnectionFactory(factory);
        // 设置序列化器（防止乱码）template.setKeySerializer(newStringRedisSerializer());
        template.setValueSerializer(newGenericJackson2JsonRedisSerializer());
        returntemplate;
    }
}

```

# 【进一步分析】

不是。`RedisConfig` 已经有 `@Configuration`。

**真正原因：组件扫描范围问题**

```
问题分析：
├── com.flashstream.inventory (inventory-service 主包)
│   └── DistributedLock 需要 RedisTemplate
└── com.flashstream.common (common 模块)
    └── RedisConfig (有 @Configuration)
    
Spring Boot 默认只扫描: com.flashstream.inventory.*
问题：common 包不在扫描范围内！
```

**解决方式：** 添加 `@ComponentScan`

```java
@SpringBootApplication
@ComponentScan(basePackages = {"com.flashstream.inventory", "com.flashstream.common"})
```

这样 Spring 就能扫描到 `common` 包下的 `RedisConfig`，注册 `RedisTemplate` bean。


