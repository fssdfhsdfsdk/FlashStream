#!/bin/bash
# ============================================
# FlashStream 消费者压测脚本
# 模拟库存服务/通知服务的消费能力
# ============================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  FlashStream 消费者压力测试${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

# 默认参数
TOPIC="${1:-order_events}"
MESSAGES="${2:-100000}"
BROKER="${3:-localhost:9091}"
GROUP="${4:-perf-test-consumer-group}"

echo "测试参数:"
echo "  - Topic: $TOPIC"
echo "  - 消息数量: $MESSAGES"
echo "  - Broker: $BROKER"
echo "  - 消费者组: $GROUP"
echo ""

# 检查 Kafka 容器是否运行
echo -e "${YELLOW}[1/2] 检查 Kafka 服务...${NC}"
if ! docker ps | grep -q kafka-1; then
    echo -e "${RED}错误: Kafka 容器未运行，请先执行 docker-compose up -d${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Kafka 服务运行中${NC}"
echo ""

# 重置消费者组 Offset（从最新消息开始）
echo -e "${YELLOW}[2/2] 开始消费测试...${NC}"
echo ""
echo "=========================================="
echo "  消费测试进行中，请稍候..."
echo "=========================================="
echo ""

docker exec kafka-1 kafka-consumer-perf-test \
    --bootstrap-server $BROKER \
    --topic $TOPIC \
    --messages $MESSAGES \
    --threads 3 \
    --consumer.config /opt/kafka/config/consumer.properties

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  消费测试完成！${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

# 查看消费者组状态
echo "查看消费者组状态:"
docker exec kafka-1 kafka-consumer-groups \
    --bootstrap-server $BROKER \
    --group $GROUP \
    --describe

echo ""
