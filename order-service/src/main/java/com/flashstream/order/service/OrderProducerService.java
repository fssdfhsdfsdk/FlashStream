package com.flashstream.order.service;

import com.flashstream.common.constant.KafkaConstants;
import com.flashstream.common.dto.OrderRequest;
import com.flashstream.common.entity.OrderEvent;
import com.flashstream.common.util.MessageIdGenerator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
public class OrderProducerService {
    
    private static final Logger logger = LoggerFactory.getLogger(OrderProducerService.class);
    
    private final KafkaTemplate<String, Object> kafkaTemplate;
    
    public OrderProducerService(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }
    
    public String sendOrderEvent(OrderRequest request) {
        String messageId = MessageIdGenerator.generate("order");
        String orderId = MessageIdGenerator.generate("ord");
        
        OrderEvent orderEvent = OrderEvent.builder()
                .orderId(orderId)
                .userId(request.getUserId())
                .productId(request.getProductId())
                .quantity(request.getQuantity())
                .price(request.getPrice())
                .status(OrderEvent.OrderStatus.PENDING)
                .messageId(messageId)
                .build();
        
        String partitionKey = request.getUserId();
        
        CompletableFuture<SendResult<String, Object>> future = kafkaTemplate.send(
                KafkaConstants.ORDER_EVENTS_TOPIC,
                partitionKey,
                orderEvent
        );
        
        future.whenComplete((result, ex) -> {
            if (ex != null) {
                logger.error("发送订单消息失败, messageId: {}, orderId: {}, error: {}", 
                        messageId, orderId, ex.getMessage());
            } else {
                logger.info("订单消息发送成功, messageId: {}, orderId: {}, partition: {}, offset: {}", 
                        messageId, orderId, 
                        result.getRecordMetadata().partition(),
                        result.getRecordMetadata().offset());
            }
        });
        
        return messageId;
    }
}
