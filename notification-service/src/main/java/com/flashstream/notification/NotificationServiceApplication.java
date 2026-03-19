package com.flashstream.notification;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@EnableKafka
@ComponentScan(basePackages = {"com.flashstream.notification", "com.flashstream.common"})
public class NotificationServiceApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(NotificationServiceApplication.class, args);
    }
}
