@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================
REM FlashStream 测试工具集
REM ============================================

:menu
cls
echo ========================================
echo   FlashStream 测试工具集
echo ========================================
echo.
echo   [1] 启动所有服务
echo   [2] 停止所有服务
echo.
echo   --- 压测工具 ---
echo   [3] 生产者压测
echo   [4] 消费者压测
echo.
echo   --- 监控工具 ---
echo   [5] 查看指标 (交互式)
echo   [6] 打开 Kafdrop UI
echo   [7] 打开 Kafka Eagle UI
echo.
echo   --- 业务验证 ---
echo   [8] 幂等性验证测试
echo   [9] Rebalance 测试
echo.
echo   [0] 退出
echo.
set /p choice=请输入选项:

if "%choice%"=="1" goto start_services
if "%choice%"=="2" goto stop_services
if "%choice%"=="3" goto producer_test
if "%choice%"=="4" goto consumer_test
if "%choice%"=="5" goto view_metrics
if "%choice%"=="6" goto open_kafdrop
if "%choice%"=="7" goto open_eagle
if "%choice%"=="8" goto idempotency_test
if "%choice%"=="9" goto rebalance_test
if "%choice%"=="0" goto end
goto menu

:start_services
echo 启动服务...
docker-compose up -d
echo 服务已启动
echo.
echo 可用服务:
echo   - Kafdrop: http://localhost:9001
echo   - Kafka Eagle: http://localhost:8048
echo   - Redis: localhost:6379
echo   - MySQL: localhost:3306
pause
goto menu

:stop_services
echo 停止服务...
docker-compose down
echo 服务已停止
pause
goto menu

:producer_test
echo.
echo 生产者压测
echo 默认参数: Topic=order_events, 消息数=100000
echo.
set /p topic=请输入Topic (直接回车使用默认值):
set /p records=请输入消息数 (直接回车使用默认值100000):
if "!topic!"=="" set topic=order_events
if "!records!"=="" set records=100000

docker exec kafka-1 kafka-producer-perf-test --topic !topic! --num-records !records! --record-size 1024 --throughput -1 --producer-props bootstrap.servers=localhost:9091 acks=all
pause
goto menu

:consumer_test
echo.
echo 消费者压测
echo.
set /p topic=请输入Topic (直接回车使用默认值):
set /p messages=请输入消息数 (直接回车使用默认值100000):
if "!topic!"=="" set topic=order_events
if "!messages!"=="" set messages=100000

docker exec kafka-1 kafka-consumer-perf-test --bootstrap-server localhost:9091 --topic !topic! --messages !messages! --threads 3
pause
goto menu

:view_metrics
echo.
echo ================================
echo 查看 Kafka 指标
echo ================================
echo.
echo [1] 查看 Topic 列表
echo [2] 查看 Topic 详情
echo [3] 查看消费者组
echo [4] 查看 LAG
echo [5] 查看所有消费者组详情
echo.
set /p m_choice=请输入选项:

if "!m_choice!"=="1" docker exec kafka-1 kafka-topics --list --bootstrap-server localhost:9091
if "!m_choice!"=="2" (
    set /p t_name=请输入Topic名称:
    docker exec kafka-1 kafka-topics --describe --topic !t_name! --bootstrap-server localhost:9091
)
if "!m_choice!"=="3" docker exec kafka-1 kafka-consumer-groups --bootstrap-server localhost:9091 --list
if "!m_choice!"=="4" docker exec kafka-1 kafka-consumer-groups --bootstrap-server localhost:9091 --group inventory-consumer-group --describe
if "!m_choice!"=="5" docker exec kafka-1 kafka-consumer-groups --bootstrap-server localhost:9091 --describe --all-groups
pause
goto menu

:open_kafdrop
start http://localhost:9001
goto menu

:open_eagle
start http://localhost:8048
goto menu

:idempotency_test
echo.
echo 幂等性验证测试
echo.
echo 发送测试订单...
for /L %%i in (1,1,5) do (
    curl -s -X POST http://localhost:8081/api/orders -H "Content-Type: application/json" -d "{\"userId\":\"test_user_%%i\",\"productId\":\"product_456\",\"quantity\":1,\"price\":99}" >nul
    echo 发送第 %%i 条...
)
echo.
echo 等待处理...
timeout /t 5 /nobreak >nul
echo.
echo 检查Redis记录...
docker exec flashstream-redis redis-cli KEYS "msg:id:*"
echo.
echo 幂等性验证完成
pause
goto menu

:rebalance_test
echo.
echo Rebalance 测试
echo.
echo 当前消费者组状态:
docker exec kafka-1 kafka-consumer-groups --bootstrap-server localhost:9091 --group inventory-consumer-group --describe
echo.
echo 要触发Rebalance，请执行:
echo   docker-compose up -d inventory-service-2
echo   或
echo   docker-compose stop inventory-service
echo.
pause
goto menu

:end
echo 再见!
