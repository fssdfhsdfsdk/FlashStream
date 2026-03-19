package com.flashstream.common.util;

import java.util.UUID;

public class MessageIdGenerator {
    
    public static String generate() {
        return UUID.randomUUID().toString().replace("-", "");
    }
    
    public static String generate(String prefix) {
        return prefix + "_" + System.currentTimeMillis() + "_" + 
               UUID.randomUUID().toString().substring(0, 8);
    }
}
