描述：关闭所有服务； 启动 库存服务，历史堆积的消息被消费；

```
r-group: partitions assigned: [order_events-2, order_events-3]
2026-03-19T17:12:58.586Z  INFO 134463 --- [inventory-service] [ntainer#0-2-C-1] o.a.k.c.c.internals.SubscriptionState    : [Consumer clientId=consumer-inventory-consumer-group-3, groupId=inventory-consumer-group] Resetting offset for partition order_events-5 to position FetchPosition{offset=0, offsetEpoch=Optional.empty, currentLeader=LeaderAndEpoch{leader=Optional[localhost:9091 (id: 1 rack: null)], epoch=0}}.
2026-03-19T17:12:58.586Z  INFO 134463 --- [inventory-service] [ntainer#0-2-C-1] o.s.k.l.KafkaMessageListenerContainer    : inventory-consumer-group: partitions assigned: [order_events-4, order_events-5]
2026-03-19T17:12:58.586Z  INFO 134463 --- [inventory-service] [ntainer#0-0-C-1] o.a.k.c.c.internals.SubscriptionState    : [Consumer clientId=consumer-inventory-consumer-group-1, groupId=inventory-consumer-group] Resetting offset for partition order_events-1 to position FetchPosition{offset=0, offsetEpoch=Optional.empty, currentLeader=LeaderAndEpoch{leader=Optional[localhost:9091 (id: 1 rack: null)], epoch=0}}.
2026-03-19T17:12:58.586Z  INFO 134463 --- [inventory-service] [ntainer#0-0-C-1] o.s.k.l.KafkaMessageListenerContainer    : inventory-consumer-group: partitions assigned: [order_events-0, order_events-1]
2026-03-19T17:12:58.637Z  INFO 134463 --- [inventory-service] [ntainer#0-2-C-1] c.f.i.service.InventoryConsumerService   : 收到订单消息: orderId=ord_1773939422256_2a33fb2b, userId=user_123, productId=product_456, messageId=order_1773939422256_2285077e
2026-03-19T17:12:58.853Z  INFO 134463 --- [inventory-service] [ntainer#0-2-C-1] c.f.i.service.InventoryConsumerService   : 开始扣减库存: productId=product_456, quantity=1
2026-03-19T17:12:59.000Z  INFO 134463 --- [inventory-service] [ntainer#0-2-C-1] c.f.i.service.InventoryConsumerService   : 库存扣减成功: orderId=ord_1773939422256_2a33fb2b, productId=product_456, quantity=1
```