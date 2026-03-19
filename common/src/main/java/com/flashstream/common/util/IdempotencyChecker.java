package com.flashstream.common.util;

import com.flashstream.common.constant.KafkaConstants;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;

@Component
public class IdempotencyChecker {
    
    private final RedisTemplate<String, Object> redisTemplate;
    
    public IdempotencyChecker(RedisTemplate<String, Object> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }
    
    public boolean checkAndSave(String messageId) {
        String key = KafkaConstants.REDIS_MESSAGE_ID_PREFIX + messageId;
        Boolean result = redisTemplate.opsForValue().setIfAbsent(
                key, 
                "1", 
                Duration.ofSeconds(KafkaConstants.REDIS_MESSAGE_ID_EXPIRE_SECONDS)
        );
        return Boolean.TRUE.equals(result);
    }
    
    public boolean exists(String messageId) {
        String key = KafkaConstants.REDIS_MESSAGE_ID_PREFIX + messageId;
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }
    
    public void remove(String messageId) {
        String key = KafkaConstants.REDIS_MESSAGE_ID_PREFIX + messageId;
        redisTemplate.delete(key);
    }
}
