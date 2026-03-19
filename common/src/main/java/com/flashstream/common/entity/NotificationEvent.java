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
public class NotificationEvent implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private String eventId;
    private String orderId;
    private String userId;
    private String phoneNumber;
    private NotificationType type;
    private String content;
    private Boolean sent;
    private LocalDateTime createTime;
    private LocalDateTime sentTime;

    public enum NotificationType {
        SMS("短信通知"),
        EMAIL("邮件通知"),
        PUSH("推送通知");

        private final String description;

        NotificationType(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }
}
