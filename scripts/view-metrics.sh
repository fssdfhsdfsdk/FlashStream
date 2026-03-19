#!/bin/bash
# ============================================
# FlashStream 指标查看脚本
# 查看 Kafka 集群的关键指标
# ============================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BROKER="localhost:9091"

show_menu() {
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}  FlashStream Kafka 指标查看${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo ""
    echo -e "${BLUE}请选择操作:${NC}"
    echo "  1. 查看所有 Topic 列表"
    echo "  2. 查看 Topic 详情"
    echo "  3. 查看消费者组状态 (包含 LAG)"
    echo "  4. 查看指定消费者组详情"
    echo "  5. 查看 Broker 状态"
    echo "  6. 实时监控消息积压 (Watch LAG)"
    echo "  7. 查看服务端口映射"
    echo "  0. 退出"
    echo ""
    echo -n "请输入选项: "
}

# 检查 Docker 是否运行
check_docker() {
    if ! docker ps | grep -q kafka-1; then
        echo -e "${RED}错误: Kafka 容器未运行${NC}"
        exit 1
    fi
}

# 查看 Topic 列表
show_topics() {
    echo -e "${YELLOW}[查看 Topic 列表]${NC}"
    docker exec kafka-1 kafka-topics --list --bootstrap-server $BROKER
}

# 查看 Topic 详情
show_topic_detail() {
    echo -n "请输入 Topic 名称: "
    read topic
    if [ -z "$topic" ]; then
        topic="order_events"
    fi
    echo -e "${YELLOW}[查看 Topic: $topic]${NC}"
    docker exec kafka-1 kafka-topics --describe --topic $topic --bootstrap-server $BROKER
}

# 查看所有消费者组
show_consumer_groups() {
    echo -e "${YELLOW}[查看消费者组]${NC}"
    docker exec kafka-1 kafka-consumer-groups \
        --bootstrap-server $BROKER \
        --list
}

# 查看指定消费者组详情
show_consumer_group_detail() {
    echo -n "请输入消费者组名称 (直接回车查看所有): "
    read group
    
    if [ -z "$group" ]; then
        echo -e "${YELLOW}[查看所有消费者组详情]${NC}"
        docker exec kafka-1 kafka-consumer-groups \
            --bootstrap-server $BROKER \
            --describe \
            --all-groups
    else
        echo -e "${YELLOW}[查看消费者组: $group]${NC}"
        docker exec kafka-1 kafka-consumer-groups \
            --bootstrap-server $BROKER \
            --group $group \
            --describe
    fi
}

# 查看 Broker 状态
show_broker_status() {
    echo -e "${YELLOW}[查看 Broker 状态]${NC}"
    docker exec kafka-1 kafka-broker-api-versions \
        --bootstrap-server $BROKER
}

# 实时监控 LAG
watch_lag() {
    echo -n "请输入消费者组名称: "
    read group
    if [ -z "$group" ]; then
        group="inventory-consumer-group"
    fi
    
    echo -e "${YELLOW}[实时监控 LAG (每5秒刷新), 按 Ctrl+C 退出]${NC}"
    watch -n 5 "docker exec kafka-1 kafka-consumer-groups --bootstrap-server $BROKER --group $group --describe"
}

# 查看服务端口
show_ports() {
    echo -e "${YELLOW}[服务端口映射]${NC}"
    echo ""
    echo "┌─────────────────────┬──────────┬──────────────────────────────┐"
    echo "│ 服务                │ 端口     │ 说明                        │"
    echo "├─────────────────────┼──────────┼──────────────────────────────┤"
    echo "│ Kafka Broker 1     │ 9091     │ 主端口                      │"
    echo "│ Kafka Broker 2     │ 9092     │ 主端口                      │"
    echo "│ Kafka Broker 3     │ 9093     │ 主端口                      │"
    echo "│ Kafdrop UI         │ 9001     │ Web 可视化                   │"
    echo "│ Kafka Eagle        │ 8048     │ 专业监控                    │"
    echo "│ Redis              │ 6379     │ 缓存/幂等                   │"
    echo "│ MySQL              │ 3306     │ 数据库                      │"
    echo "│ Order Service      │ 8081     │ 订单服务                    │"
    echo "│ Inventory Service  │ 8082     │ 库存服务                    │"
    echo "│ Notification       │ 8083     │ 通知服务                    │"
    echo "└─────────────────────┴──────────┴──────────────────────────────┘"
}

# 主循环
while true; do
    show_menu
    read choice
    echo ""
    
    check_docker
    
    case $choice in
        1) show_topics ;;
        2) show_topic_detail ;;
        3) show_consumer_groups ;;
        4) show_consumer_group_detail ;;
        5) show_broker_status ;;
        6) watch_lag ;;
        7) show_ports ;;
        0) 
            echo -e "${GREEN}再见!${NC}"
            exit 0
            ;;
        *) 
            echo -e "${RED}无效选项，请重新选择${NC}"
            ;;
    esac
    echo ""
done
