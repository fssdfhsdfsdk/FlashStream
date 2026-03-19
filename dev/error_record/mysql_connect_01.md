

# 【01】

```
2026-03-19T16:37:27.495Z  INFO 65331 --- [order-service] [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2026-03-19T16:37:28.664Z ERROR 65331 --- [order-service] [           main] com.zaxxer.hikari.pool.HikariPool        : HikariPool-1 - Exception during pool initialization.

java.sql.SQLNonTransientConnectionException: Public Key Retrieval is not allowed
        at com.mysql.cj.jdbc.exceptions.SQLError.createSQLException(SQLError.java:111) ~[mysql-connector-j-8.1.0.jar!/:8.1.0]
        at com.mysql.cj.jdbc.exceptions.SQLExceptionsMapping.translateException(SQLExceptionsMapping.java:122) ~[mysql-connector-j-8.1.0.jar!/:8.1.0]
        at com.mysql.cj.jdbc.ConnectionImpl.createNewIO(ConnectionImpl.java:819) 
```

这个错误是因为 MySQL 8.0 默认启用了更安全的 caching_sha2_password 身份验证插件。当你禁用了 SSL (useSSL=false) 且没有明确允许客户端获取 RSA 公钥时，JDBC 驱动出于安全考虑会拒绝连接。 [1, 2, 3, 4] 
以下是两种最常用的解决方法：
方案 1：在 JDBC URL 中添加允许参数（推荐用于开发环境）
直接修改你的数据库连接字符串（通常在 application.yml 或 application.properties 中），在 URL 末尾追加 allowPublicKeyRetrieval=true。 [5, 6] 

* 修改后的配置示例：

spring.datasource.url=jdbc:mysql://localhost:3306/your_database?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC

注意：如果 URL 中已经有其他参数，请用 & 符号连接。 [7, 8] 

方案 2：修改 MySQL 用户的认证方式（推荐用于生产环境）
如果你不想修改代码或连接串，可以登录 MySQL 命令行，将用户的加密方式改回旧版的 mysql_native_password： [2, 9] 

   1. 登录数据库： mysql -u root -p
   2. 执行修改语句：
   
   ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '你的密码';
   FLUSH PRIVILEGES;
   
   请将 'root'@'localhost' 替换为你实际使用的用户名和主机名。 [10, 11] 

为什么会发生这个报错？

* 安全机制： caching_sha2_password 要求在传输密码时必须加密。
* 缺少公钥： 如果没开启 SSL，驱动需要从服务器请求 RSA 公钥来加密密码，但为了防范中间人攻击，驱动默认是不允许自动获取公钥的，必须显式开启 allowPublicKeyRetrieval=true。 [4, 6, 12] 

你目前是在本地运行测试，还是在部署到生产服务器？

[1] [https://knowledge.broadcom.com](https://knowledge.broadcom.com/external/article/259949/broadcom-api-gateway-mysql-jdbc-connecti.html)
[2] [https://help.aliyun.com](https://help.aliyun.com/document_detail/305981.html)
[3] [https://www.cnblogs.com](https://www.cnblogs.com/ivictor/p/18872158)
[4] [https://www.javacodegeeks.com](https://www.javacodegeeks.com/resolving-the-mysql-public-key-retrieval-is-not-allowed-error-in-java.html)
[5] [https://stackoverflow.com](https://stackoverflow.com/questions/50379839/connection-java-mysql-public-key-retrieval-is-not-allowed#:~:text=To%20allow%20the%20client%20to%20automatically%20request,Eclipse%20and%20Clean%20on%20your%20Tomcat%20server)
[6] [https://www.cnblogs.com](https://www.cnblogs.com/Higurashi-kagome/p/18416661)
[7] [https://developer.aliyun.com](https://developer.aliyun.com/article/1421397)
[8] [https://developer.aliyun.com](https://developer.aliyun.com/article/1421397)
[9] [https://comate.baidu.com](https://comate.baidu.com/zh/page/r75on9fwsn2)
[10] [https://cloud.tencent.com](https://cloud.tencent.com/developer/article/2524151)
[11] [https://cloud.tencent.com](https://cloud.tencent.com/developer/article/2524151)
[12] [https://www.cnblogs.com](https://www.cnblogs.com/ivictor/p/18872158)
