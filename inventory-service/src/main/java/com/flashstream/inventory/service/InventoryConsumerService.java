package com.flashstream.inventory.service;

import com.flashstream.common.constant.KafkaConstants;
import com.flashstream.common.entity.OrderEvent;
import com.flashstream.common.util.IdempotencyChecker;
import com.flashstream.inventory.util.DistributedLock;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Service;

import java.util.Random;

@Service
public class InventoryConsumerService {
    
    private static final Logger logger = LoggerFactory.getLogger(InventoryConsumerService.class);
    
    private final DistributedLock distributedLock;
    private final IdempotencyChecker idempotencyChecker;
    private final Random random = new Random();
    
    public InventoryConsumerService(DistributedLock distributedLock, 
                                    IdempotencyChecker idempotencyChecker) {
        this.distributedLock = distributedLock;
        this.idempotencyChecker = idempotencyChecker;
    }
    
    @KafkaListener(
            topics = KafkaConstants.ORDER_EVENTS_TOPIC,
            groupId = KafkaConstants.INVENTORY_CONSUMER_GROUP,
            containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeOrderEvent(ConsumerRecord<String, OrderEvent> record, 
                                   Acknowledgment acknowledgment) {
        OrderEvent orderEvent = record.value();
        String messageId = orderEvent.getMessageId();
        
        logger.info("收到订单消息: orderId={}, userId={}, productId={}, messageId={}", 
                orderEvent.getOrderId(), orderEvent.getUserId(), 
                orderEvent.getProductId(), messageId);
        
        try {
            if (!idempotencyChecker.checkAndSave(messageId)) {
                logger.warn("消息已处理，跳过: messageId={}", messageId);
                acknowledgment.acknowledge();
                return;
            }
            
            String lockValue = distributedLock.acquireLock(orderEvent.getProductId());
            if (lockValue == null) {
                logger.warn("获取分布式锁失败，productId={}，稍后重试", orderEvent.getProductId());
                return;
            }
            
            try {
                boolean success = processInventory(orderEvent);
                
                if (success) {
                    logger.info("库存扣减成功: orderId={}, productId={}, quantity={}", 
                            orderEvent.getOrderId(), orderEvent.getProductId(), 
                            orderEvent.getQuantity());
                } else {
                    logger.error("库存扣减失败: orderId={}, productId={}", 
                            orderEvent.getOrderId(), orderEvent.getProductId());
                }
            } finally {
                distributedLock.releaseLock(orderEvent.getProductId(), lockValue);
            }
            
            acknowledgment.acknowledge();
            
        } catch (Exception e) {
            logger.error("处理订单消息异常: messageId={}, error={}", messageId, e.getMessage(), e);
        }
    }
    
    private boolean processInventory(OrderEvent orderEvent) {
        logger.info("开始扣减库存: productId={}, quantity={}", 
                orderEvent.getProductId(), orderEvent.getQuantity());
        
        try {
            Thread.sleep(random.nextInt(100) + 50);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return true;
    }
}
