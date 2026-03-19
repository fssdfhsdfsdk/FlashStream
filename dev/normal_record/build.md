

```
➜ mvn clean package -DskipTests


[INFO] --- spring-boot:3.2.0:repackage (repackage) @ notification-service ---
[INFO] Replacing main artifact /workspace/FlashStream/notification-service/target/notification-service-1.0.0.jar with repackaged archive, adding nested dependencies in BOOT-INF/.
[INFO] The original artifact has been renamed to /workspace/FlashStream/notification-service/target/notification-service-1.0.0.jar.original
[INFO] 
[INFO] -----------------< com.flashstream:flashstream-parent >-----------------
[INFO] Building FlashStream Parent 1.0.0                                  [5/5]
[INFO]   from pom.xml
[INFO] --------------------------------[ pom ]---------------------------------
[INFO] 
[INFO] --- clean:3.3.2:clean (default-clean) @ flashstream-parent ---
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for FlashStream Parent 1.0.0:
[INFO] 
[INFO] FlashStream Common ................................. SUCCESS [ 12.249 s]
[INFO] FlashStream Order Service .......................... SUCCESS [  1.922 s]
[INFO] FlashStream Inventory Service ...................... SUCCESS [  0.316 s]
[INFO] FlashStream Notification Service ................... SUCCESS [  0.259 s]
[INFO] FlashStream Parent ................................. SUCCESS [  0.003 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  16.655 s
[INFO] Finished at: 2026-03-19T16:20:17Z
[INFO] ------------------------------------------------------------------------
➜  FlashStream git:(master) ✗ 
```