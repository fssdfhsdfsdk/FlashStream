#!/bin/bash
# ============================================
# FlashStream Rebalance 测试脚本
# 测试消费者组重平衡机制
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BROKER="localhost:9091"
GROUP="inventory-consumer-group"
KAFKA_BIN="/opt/kafka/bin"

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  FlashStream Rebalance 测试${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

echo "测试内容:"
echo "  1. 查看当前消费者组状态"
echo "  2. 启动新的消费者实例"
echo "  3. 观察 Rebalance 过程"
echo "  4. 停止消费者实例"
echo "  5. 再次观察 Rebalance"
echo ""

echo -e "${YELLOW}[1/5] 检查当前状态...${NC}"
echo ""
echo "当前消费者组状态:"
docker exec kafka-1 $KAFKA_BIN/kafka-consumer-groups.sh \
    --bootstrap-server $BROKER \
    --group $GROUP \
    --describe 2>/dev/null || echo "消费者组暂无数据"

echo ""
echo "当前 Topic 分区:"
docker exec kafka-1 $KAFKA_BIN/kafka-topics.sh \
    --describe --topic order_events \
    --bootstrap-server $BROKER 2>/dev/null || echo "Topic 暂无数据"
echo ""

echo -e "${YELLOW}[2/5] 发送测试消息...${NC}"
for i in {1..20}; do
    curl -s -X POST http://localhost:8081/api/orders \
        -H "Content-Type: application/json" \
        -d "{\"userId\":\"rebalance_user_$i\",\"productId\":\"product_456\",\"quantity\":1,\"price\":99}" >/dev/null 2>&1
done
echo "已发送 20 条测试消息"
echo ""

echo -e "${YELLOW}[3/5] Rebalance 说明${NC}"
echo ""
echo "当消费者组发生变化时，Kafka 会触发 Rebalance："
echo "  - 新消费者加入"
echo "  - 消费者离开"
echo "  - 消费者心跳超时"
echo ""
echo "Rebalance 过程："
echo "  1. 停止所有消费者的消费"
echo "  2. 执行分区分配策略"
echo "  3. 重新分配分区给消费者"
echo "  4. 恢复消费"
echo ""
echo -e "${BLUE}触发 Rebalance 的方式:${NC}"
echo "  # 方式1: 启动新的消费者实例"
echo "  docker-compose up -d inventory-service-2"
echo ""
echo "  # 方式2: 停止现有消费者"
echo "  docker-compose stop inventory-service"
echo ""

echo -e "${YELLOW}[4/5] 当前消费 LAG${NC}"
echo ""
docker exec kafka-1 $KAFKA_BIN/kafka-consumer-groups.sh \
    --bootstrap-server $BROKER \
    --group $GROUP \
    --describe 2>/dev/null || echo "暂无数据"

echo ""
echo -e "${YELLOW}[5/5] 分区分配策略说明${NC}"
echo ""
echo "推荐配置 (CooperativeStickyAssignor):"
echo ""
echo "  spring:"
echo "    kafka:"
echo "      consumer:"
echo "        properties:"
echo "          partition.assignment.strategy: org.apache.kafka.clients.consumer.CooperativeStickyAssignor"
echo ""

echo "观察 Rebalance 日志:"
echo "  docker logs -f inventory-service | grep -i rebalance"
echo ""

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  Rebalance 测试指导完成${NC}"
echo -e "${GREEN}==========================================${NC}"
