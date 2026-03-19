package com.flashstream.inventory;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@EnableKafka
@ComponentScan(basePackages = {"com.flashstream.inventory", "com.flashstream.common"})
public class InventoryServiceApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(InventoryServiceApplication.class, args);
    }
}
