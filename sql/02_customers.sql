CREATE TABLE customers (
  id           INT IDENTITY CONSTRAINT pk_customers PRIMARY KEY,
  phone_number VARCHAR(32) NOT NULL CONSTRAINT unique_customers_phone_number UNIQUE
);

CREATE TABLE customer_individual (
  customer_id INT CONSTRAINT pk_customer_individual PRIMARY KEY CONSTRAINT fk_customer_individual_customer FOREIGN KEY REFERENCES customers,
  person_id   INT NOT NULL CONSTRAINT unique_customer_individual_person UNIQUE CONSTRAINT fk_customer_individual_person FOREIGN KEY REFERENCES people,
  student_card_number VARCHAR(32) DEFAULT NULL -- przenieść do osobnej tabeli
);

CREATE TABLE companies (
  customer_id INT          NOT NULL CONSTRAINT fk_companies_customer FOREIGN KEY REFERENCES customers,
  name        VARCHAR(255) NOT NULL
);

INSERT INTO customers (phone_number) VALUES ('0048 056 120 630');
INSERT INTO customers (phone_number) VALUES ('0048 147 948 157');
INSERT INTO customer_individual (customer_id, person_id) VALUES (1, 1);

INSERT INTO companies (customer_id, name) VALUES (2, 'Harris Inc');
