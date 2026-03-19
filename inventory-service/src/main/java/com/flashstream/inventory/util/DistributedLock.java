package com.flashstream.inventory.util;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.UUID;

@Component
public class DistributedLock {
    
    private final RedisTemplate<String, Object> redisTemplate;
    private static final String LOCK_PREFIX = "lock:";
    private static final Duration LOCK_TIMEOUT = Duration.ofSeconds(10);
    
    public DistributedLock(RedisTemplate<String, Object> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }
    
    public String acquireLock(String key) {
        String lockValue = UUID.randomUUID().toString();
        Boolean acquired = redisTemplate.opsForValue().setIfAbsent(
                LOCK_PREFIX + key,
                lockValue,
                LOCK_TIMEOUT
        );
        
        if (Boolean.TRUE.equals(acquired)) {
            return lockValue;
        }
        return null;
    }
    
    public boolean releaseLock(String key, String lockValue) {
        String currentValue = (String) redisTemplate.opsForValue().get(LOCK_PREFIX + key);
        if (lockValue.equals(currentValue)) {
            redisTemplate.delete(LOCK_PREFIX + key);
            return true;
        }
        return false;
    }
}
