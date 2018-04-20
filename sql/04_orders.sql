CREATE TABLE orders (
  id               INT IDENTITY CONSTRAINT pk_orders PRIMARY KEY,
  customer_id      INT CONSTRAINT fk_orders_customer FOREIGN KEY REFERENCES customers NOT NULL,
  order_date       DATETIME2 CONSTRAINT default_orders_order_date DEFAULT CURRENT_TIMESTAMP NOT NULL,
  payment_due_date DATETIME2 CONSTRAINT default_orders_payment_due_date DEFAULT DATEADD(WEEK, 1, CURRENT_TIMESTAMP) NOT NULL
);

INSERT INTO orders (customer_id) VALUES (1);
INSERT INTO orders (customer_id) VALUES (2);