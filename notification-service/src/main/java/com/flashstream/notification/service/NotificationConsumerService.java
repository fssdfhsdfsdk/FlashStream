package com.flashstream.notification.service;

import com.flashstream.common.constant.KafkaConstants;
import com.flashstream.common.entity.OrderEvent;
import com.flashstream.common.util.IdempotencyChecker;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Service;

import java.util.Random;

@Service
public class NotificationConsumerService {
    
    private static final Logger logger = LoggerFactory.getLogger(NotificationConsumerService.class);
    
    private final IdempotencyChecker idempotencyChecker;
    private final Random random = new Random();
    
    public NotificationConsumerService(IdempotencyChecker idempotencyChecker) {
        this.idempotencyChecker = idempotencyChecker;
    }
    
    @KafkaListener(
            topics = KafkaConstants.ORDER_EVENTS_TOPIC,
            groupId = KafkaConstants.NOTIFICATION_CONSUMER_GROUP,
            containerFactory = "kafkaListenerContainerFactory"
    )
    public void consumeOrderEvent(ConsumerRecord<String, OrderEvent> record, 
                                   Acknowledgment acknowledgment) {
        OrderEvent orderEvent = record.value();
        String messageId = orderEvent.getMessageId();
        
        logger.info("收到订单通知消息: orderId={}, userId={}, productId={}, messageId={}", 
                orderEvent.getOrderId(), orderEvent.getUserId(), 
                orderEvent.getProductId(), messageId);
        
        try {
            String notificationId = "notify_" + messageId;
            if (!idempotencyChecker.checkAndSave(notificationId)) {
                logger.warn("通知消息已发送，跳过: orderId={}", orderEvent.getOrderId());
                acknowledgment.acknowledge();
                return;
            }
            
            boolean success = sendNotification(orderEvent);
            
            if (success) {
                logger.info("短信通知发送成功: orderId={}, userId={}", 
                        orderEvent.getOrderId(), orderEvent.getUserId());
            } else {
                logger.error("短信通知发送失败: orderId={}", orderEvent.getOrderId());
            }
            
            acknowledgment.acknowledge();
            
        } catch (Exception e) {
            logger.error("处理通知消息异常: messageId={}, error={}", messageId, e.getMessage(), e);
        }
    }
    
    private boolean sendNotification(OrderEvent orderEvent) {
        logger.info("发送短信通知: userId={}, orderId={}, productId={}", 
                orderEvent.getUserId(), orderEvent.getOrderId(), orderEvent.getProductId());
        
        try {
            Thread.sleep(random.nextInt(50) + 20);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return true;
    }
}
