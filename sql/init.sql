-- FlashStream 数据库初始化脚本

-- 创建数据库
CREATE DATABASE IF NOT EXISTS flashstream 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE flashstream;

-- 订单表
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    product_id VARCHAR(64) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(32) NOT NULL,
    message_id VARCHAR(64),
    create_time DATETIME NOT NULL,
    update_time DATETIME NOT NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_product_id (product_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 库存表
CREATE TABLE IF NOT EXISTS inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(64) NOT NULL UNIQUE,
    product_name VARCHAR(255) NOT NULL,
    total_stock INT NOT NULL DEFAULT 0,
    available_stock INT NOT NULL DEFAULT 0,
    locked_stock INT NOT NULL DEFAULT 0,
    version INT NOT NULL DEFAULT 0,
    create_time DATETIME NOT NULL,
    update_time DATETIME NOT NULL,
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 通知记录表
CREATE TABLE IF NOT EXISTS notification_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_id VARCHAR(64) NOT NULL,
    order_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    phone_number VARCHAR(32),
    notification_type VARCHAR(32) NOT NULL,
    content TEXT,
    sent TINYINT NOT NULL DEFAULT 0,
    create_time DATETIME NOT NULL,
    sent_time DATETIME,
    INDEX idx_order_id (order_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入初始库存数据
INSERT INTO inventory (product_id, product_name, total_stock, available_stock, locked_stock, create_time, update_time) VALUES
('product_001', 'iPhone 15 Pro Max', 1000, 1000, 0, NOW(), NOW()),
('product_002', 'MacBook Pro M3', 500, 500, 0, NOW(), NOW()),
('product_003', 'AirPods Pro 2', 2000, 2000, 0, NOW(), NOW()),
('product_004', 'iPad Pro 12.9', 800, 800, 0, NOW(), NOW()),
('product_005', 'Apple Watch Ultra 2', 1500, 1500, 0, NOW(), NOW()),
('product_456', '秒杀商品', 100, 100, 0, NOW(), NOW());
