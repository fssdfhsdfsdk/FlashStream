package com.flashstream.order.config;

import com.flashstream.common.constant.KafkaConstants;
import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaTopicConfig {
    
    @Bean
    public NewTopic orderEventsTopic() {
        return TopicBuilder.name(KafkaConstants.ORDER_EVENTS_TOPIC)
                .partitions(KafkaConstants.PARTITION_COUNT)
                .replicas(KafkaConstants.REPLICATION_FACTOR)
                .build();
    }
}
