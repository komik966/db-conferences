CREATE TABLE payments (
  order_id     INT CONSTRAINT fk_payments_order FOREIGN KEY REFERENCES orders CONSTRAINT pk_payments PRIMARY KEY,
  payment_date DATETIME2 NOT NULL CONSTRAINT default_payments_payment_date DEFAULT CURRENT_TIMESTAMP,
);

INSERT INTO payments (order_id) VALUES (1);
INSERT INTO payments (order_id) VALUES (2);
