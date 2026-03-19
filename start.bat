@echo off
chcp 65001 >nul
REM FlashStream 启动脚本

echo ========================================
echo   FlashStream 高并发秒杀与实时库存系统
echo ========================================
echo.

REM 检查 Docker 是否安装
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker 未安装，请先安装 Docker
    pause
    exit /b 1
)

REM 检查 docker-compose 是否安装
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] docker-compose 未安装，请先安装
    pause
    exit /b 1
)

echo [1/4] 启动 Kafka 集群 (KRaft 模式)...
docker-compose up -d
echo.

echo [2/4] 等待 Kafka 服务就绪...
echo 首次启动需要等待集群初始化，约 30-60 秒...
timeout /t 60 /nobreak >nul
echo.

echo [3/4] 验证服务状态...
docker-compose ps
echo.

echo [4/4] 检查 Kafka 是否就绪...
for /L %%i in (1,1,30) do (
    docker exec kafka-1 /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9091 >nul 2>&1
    if !errorlevel!==0 (
        echo Kafka 已就绪！
        goto :kafka_ready
    )
    echo 等待 Kafka 就绪... (%%i/30)
    timeout /t 5 /nobreak >nul
)

:kafka_ready
echo.

echo ========================================
echo   服务启动完成！
echo ========================================
echo.
echo 访问地址:
echo   - Kafka: localhost:9091, 9092, 9093
echo   - Kafdrop UI: http://localhost:9001
echo   - Redis: localhost:6379
echo   - MySQL: localhost:3306
echo.
echo 启动应用服务:
echo   - order-service (8081)
echo   - inventory-service (8082)
echo   - notification-service (8083)
echo.
echo 测试接口:
echo   curl -X POST http://localhost:8081/api/orders -H "Content-Type: application/json" -d "{\"userId\":\"user_001\",\"productId\":\"product_456\",\"quantity\":1,\"price\":99}"
echo.
pause
