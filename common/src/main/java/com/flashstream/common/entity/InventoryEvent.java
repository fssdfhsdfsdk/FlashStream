package com.flashstream.common.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InventoryEvent implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private String eventId;
    private String orderId;
    private String productId;
    private Integer quantity;
    private InventoryOperation operation;
    private Boolean success;
    private String errorMessage;
    private LocalDateTime createTime;

    public enum InventoryOperation {
        LOCK("锁定库存"),
        DEDUCT("扣减库存"),
        ROLLBACK("回滚库存");

        private final String description;

        InventoryOperation(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }
}
