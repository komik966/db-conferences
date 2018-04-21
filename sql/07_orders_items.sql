CREATE TABLE orders_items (
  id            INT         IDENTITY CONSTRAINT pk_orders_items PRIMARY KEY,
  order_id      INT NOT NULL CONSTRAINT fk_orders_items_order FOREIGN KEY REFERENCES orders,
  discount_id   INT         CONSTRAINT default_orders_items_discount DEFAULT NULL CONSTRAINT fk_orders_items_discount FOREIGN KEY REFERENCES discounts,
  discount_code VARCHAR(64) CONSTRAINT default_orders_items_discount_code DEFAULT NULL
);

INSERT INTO orders_items (order_id) VALUES (1);
INSERT INTO orders_items (order_id, discount_id, discount_code) VALUES (1, 1, '123456');