package com.flashstream.common.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderEvent implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private String orderId;
    private String userId;
    private String productId;
    private Integer quantity;
    private BigDecimal price;
    private OrderStatus status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private String messageId;

    public enum OrderStatus {
        PENDING("待处理"),
        CONFIRMED("已确认"),
        PROCESSING("处理中"),
        COMPLETED("已完成"),
        FAILED("失败"),
        CANCELLED("已取消");

        private final String description;

        OrderStatus(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }
}
