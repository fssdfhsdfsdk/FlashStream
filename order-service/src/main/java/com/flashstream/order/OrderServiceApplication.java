package com.flashstream.order;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@EnableKafka
@ComponentScan(basePackages = {"com.flashstream.order", "com.flashstream.common"})
public class OrderServiceApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}
