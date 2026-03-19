


```
➜  FlashStream git:(master) curl -X POST http://localhost:8081/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user_123",
    "productId": "product_456",
    "quantity": 1,
    "price": 99.00
  }'
{"code":200,"message":"success","data":{"orderId":"1773939422256_2285077e","messageId":"order_1773939422256_2285077e","status":"PENDING"},"timestamp":"2026-03-19T16:57:02.337178626"}#   
```


```
2026-03-19T16:57:02.271Z  INFO 106127 --- [order-service] [nio-8081-exec-1] o.a.k.clients.producer.KafkaProducer     : [Producer clientId=producer-1] Instantiated an idempotent producer.
2026-03-19T16:57:02.278Z  INFO 106127 --- [order-service] [nio-8081-exec-1] o.a.kafka.common.utils.AppInfoParser     : Kafka version: 3.6.0
2026-03-19T16:57:02.278Z  INFO 106127 --- [order-service] [nio-8081-exec-1] o.a.kafka.common.utils.AppInfoParser     : Kafka commitId: 60e845626d8a465a
2026-03-19T16:57:02.278Z  INFO 106127 --- [order-service] [nio-8081-exec-1] o.a.kafka.common.utils.AppInfoParser     : Kafka startTimeMs: 1773939422278
2026-03-19T16:57:02.291Z  INFO 106127 --- [order-service] [ad | producer-1] org.apache.kafka.clients.Metadata        : [Producer clientId=producer-1] Cluster ID: Some(5L6g3nShT-eMCtK--X86sw)
2026-03-19T16:57:02.498Z  INFO 106127 --- [order-service] [ad | producer-1] o.a.k.c.p.internals.TransactionManager   : [Producer clientId=producer-1] ProducerId set to 1000 with epoch 0
2026-03-19T16:57:28.590Z  INFO 106127 --- [order-service] [ad | producer-1] c.f.order.service.OrderProducerService   : 订单消息发送成功, messageId: order_1773939422256_2285077e, orderId: ord_1773939422256_2a33fb2b, partition: 5, offset: 0
```