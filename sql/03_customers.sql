CREATE TABLE customers (
  id           INT IDENTITY CONSTRAINT pk_customers PRIMARY KEY,
  phone_number VARCHAR(32) CONSTRAINT unique_customers_phone_number UNIQUE NOT NULL
);

CREATE TABLE customers_individual (
  customer_id INT CONSTRAINT fk_customers_individual_customer FOREIGN KEY REFERENCES customers,
  person_id   INT CONSTRAINT fk_customers_individual_person FOREIGN KEY REFERENCES people,
  CONSTRAINT pk_customers_individual PRIMARY KEY (customer_id, person_id)
);

CREATE TABLE customers_business (
  customer_id INT CONSTRAINT fk_customers_business_customer FOREIGN KEY REFERENCES customers,
  company_id  INT CONSTRAINT fk_customers_business_company FOREIGN KEY REFERENCES companies,
  CONSTRAINT pk_customers_business PRIMARY KEY (customer_id, company_id)
);

INSERT INTO customers (phone_number) VALUES ('0048 056 120 630');
INSERT INTO customers (phone_number) VALUES ('0048 147 948 157');
INSERT INTO customers_business (customer_id, company_id) VALUES (1, 1);
INSERT INTO customers_individual (customer_id, person_id) VALUES (2, 1);