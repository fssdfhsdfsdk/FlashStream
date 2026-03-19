#!/bin/bash
# ============================================
# FlashStream 幂等性验证脚本
# 验证消息重复消费时库存只扣减一次
# ============================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  FlashStream 幂等性验证测试${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""

# 测试参数
USER_ID="test_user_$(date +%s)"
PRODUCT_ID="product_456"
QUANTITY=1
PRICE=99.00
RETRY_COUNT=5

echo "测试参数:"
echo "  - 用户ID: $USER_ID"
echo "  - 商品ID: $PRODUCT_ID"
echo "  - 重试次数: $RETRY_COUNT"
echo ""

# 检查服务是否运行
echo -e "${YELLOW}[1/4] 检查服务状态...${NC}"
if ! curl -s http://localhost:8081/api/orders >/dev/null 2>&1; then
    echo -e "${RED}错误: Order Service 未运行 (端口 8081)${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Order Service 运行中${NC}"

if ! docker ps | grep -q inventory-service; then
    echo -e "${YELLOW}! 警告: Inventory Service 未运行${NC}"
fi
echo ""

# 发送多次相同订单（模拟网络抖动重试）
echo -e "${YELLOW}[2/4] 发送重复订单请求 ($RETRY_COUNT 次)...${NC}"
MESSAGE_IDS=()

for i in $(seq 1 $RETRY_COUNT); do
    echo -n "  第 $i 次请求... "
    RESPONSE=$(curl -s -X POST http://localhost:8081/api/orders \
        -H "Content-Type: application/json" \
        -d "{\"userId\":\"$USER_ID\",\"productId\":\"$PRODUCT_ID\",\"quantity\":$QUANTITY,\"price\":$PRICE}")
    
    if echo "$RESPONSE" | grep -q '"code":200'; then
        MSG_ID=$(echo "$RESPONSE" | grep -o '"messageId":"[^"]*"' | cut -d'"' -f4)
        MESSAGE_IDS+=("$MSG_ID")
        echo -e "${GREEN}成功 (messageId: $MSG_ID)${NC}"
    else
        echo -e "${RED}失败${NC}"
    fi
    
    sleep 0.2
done
echo ""

# 等待消息处理
echo -e "${YELLOW}[3/4] 等待消息处理 (5秒)...${NC}"
sleep 5
echo ""

# 检查 Redis 幂等记录
echo -e "${YELLOW}[4/4] 验证幂等性结果...${NC}"
echo ""

echo "┌────────────────────────────────────────────┐"
echo "│           幂等性验证结果                    │"
echo "├────────────────────────────────────────────┤"

# 检查 Redis 中的消息ID记录
echo -e "${BLUE}Redis 中的消息记录:${NC}"
MATCH_COUNT=0
for msg_id in "${MESSAGE_IDS[@]}"; do
    EXISTS=$(docker exec flashstream-redis redis-cli EXISTS "msg:id:$msg_id" 2>/dev/null)
    if [ "$EXISTS" = "1" ]; then
        MATCH_COUNT=$((MATCH_COUNT + 1))
        echo "  ✓ messageId: $msg_id - 已记录"
    else
        echo "  ✗ messageId: $msg_id - 未记录"
    fi
done

echo ""
echo "发送次数: $RETRY_COUNT"
echo "唯一消息ID数: $MATCH_COUNT"

if [ $MATCH_COUNT -eq 1 ]; then
    echo ""
    echo -e "${GREEN}✓ 幂等性验证通过！${NC}"
    echo "  只有第一条消息被处理，后续重复消息被正确拦截"
else
    echo ""
    echo -e "${RED}✗ 幂等性验证失败！${NC}"
    echo "  库存可能被多次扣减，请检查代码"
fi

echo "└────────────────────────────────────────────┘"
echo ""

# 查看库存服务日志
echo "查看库存服务处理日志:"
docker logs $(docker ps -qf "name=inventory") 2>/dev/null | grep -i "$USER_ID" | tail -10

echo ""
