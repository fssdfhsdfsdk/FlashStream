#!/bin/bash
# ============================================
# FlashStream 生产者压测脚本
# 模拟秒杀期间的高并发下单流量
# ============================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  FlashStream 生产者压力测试${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

# 默认参数
TOPIC="${1:-order_events}"
NUM_RECORDS="${2:-100000}"
RECORD_SIZE="${3:-1024}"
THROUGHPUT="${4:--1}"
BROKER="${5:-localhost:9091}"

echo "测试参数:"
echo "  - Topic: $TOPIC"
echo "  - 消息数量: $NUM_RECORDS"
echo "  - 消息大小: $RECORD_SIZE bytes"
echo "  - 吞吐量: $([ "$THROUGHPUT" = "-1" ] && echo '无限制' || echo "$THROUGHPUT")"
echo "  - Broker: $BROKER"
echo ""

# 检查 Kafka 容器是否运行
echo -e "${YELLOW}[1/3] 检查 Kafka 服务...${NC}"
if ! docker ps | grep -q kafka-1; then
    echo -e "${RED}错误: Kafka 容器未运行，请先执行 docker-compose up -d${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Kafka 服务运行中${NC}"
echo ""

# 创建测试 Topic（如果不存在）
echo -e "${YELLOW[2/3] 创建测试 Topic...${NC}"
docker exec kafka-1 kafka-topics --create \
    --if-not-exists \
    --topic $TOPIC \
    --partitions 6 \
    --replication-factor 3 \
    --bootstrap-server localhost:9091 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Topic '$TOPIC' 已准备就绪${NC}"
else
    echo -e "${YELLOW}! Topic 可能已存在，继续...${NC}"
fi
echo ""

# 执行压测
echo -e "${YELLOW}[3/3] 开始压测...${NC}"
echo ""
echo "=========================================="
echo "  压测进行中，请稍候..."
echo "=========================================="
echo ""

docker exec kafka-1 kafka-producer-perf-test \
    --topic $TOPIC \
    --num-records $NUM_RECORDS \
    --record-size $RECORD_SIZE \
    --throughput $THROUGHPUT \
    --producer-props \
    bootstrap.servers=$BROKER \
    acks=all \
    retries=3 \
    buffer.memory=33554432 \
    compression.type=snappy

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  压测完成！${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo "查看结果:"
echo "  - Kafdrop UI: http://localhost:9001"
echo "  - Kafka Eagle: http://localhost:8048"
echo ""
