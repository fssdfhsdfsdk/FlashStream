package com.flashstream.common.constant;

public class KafkaConstants {
    
    public static final String ORDER_EVENTS_TOPIC = "order_events";
    public static final String INVENTORY_EVENTS_TOPIC = "inventory_events";
    public static final String NOTIFICATION_EVENTS_TOPIC = "notification_events";
    
    public static final String ORDER_CONSUMER_GROUP = "order-consumer-group";
    public static final String INVENTORY_CONSUMER_GROUP = "inventory-consumer-group";
    public static final String NOTIFICATION_CONSUMER_GROUP = "notification-consumer-group";
    
    public static final int PARTITION_COUNT = 6;
    public static final int REPLICATION_FACTOR = 3;
    
    public static final String BOOTSTRAP_SERVERS = "localhost:9091,localhost:9092,localhost:9093";
    
    public static final String REDIS_MESSAGE_ID_PREFIX = "msg:id:";
    public static final long REDIS_MESSAGE_ID_EXPIRE_SECONDS = 86400;
    
    private KafkaConstants() {
    }
}
