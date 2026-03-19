package com.flashstream.order.controller;

import com.flashstream.common.dto.ApiResponse;
import com.flashstream.common.dto.OrderRequest;
import com.flashstream.order.service.OrderProducerService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
public class OrderController {
    
    private static final Logger logger = LoggerFactory.getLogger(OrderController.class);
    
    private final OrderProducerService orderProducerService;
    
    public OrderController(OrderProducerService orderProducerService) {
        this.orderProducerService = orderProducerService;
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<Map<String, String>>> createOrder(
            @Valid @RequestBody OrderRequest request) {
        
        logger.info("收到下单请求: userId={}, productId={}, quantity={}", 
                request.getUserId(), request.getProductId(), request.getQuantity());
        
        String messageId = orderProducerService.sendOrderEvent(request);
        
        Map<String, String> result = new HashMap<>();
        result.put("orderId", messageId.split("_")[1] + "_" + messageId.split("_")[2]);
        result.put("messageId", messageId);
        result.put("status", "PENDING");
        
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
