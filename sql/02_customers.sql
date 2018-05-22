CREATE TABLE customers (
  id           INT IDENTITY,
  phone_number VARCHAR(32) NOT NULL,

  CONSTRAINT pk_customers PRIMARY KEY (id),
  CONSTRAINT uq_customers_phone_number UNIQUE (phone_number),
);

CREATE TABLE customer_individual (
  customer_id INT,
  person_id   INT NOT NULL,

  CONSTRAINT pk_customer_individual PRIMARY KEY (customer_id),
  CONSTRAINT fk_customer_individual_customer FOREIGN KEY (customer_id) REFERENCES customers,
  CONSTRAINT uq_customer_individual_person UNIQUE (person_id),
  CONSTRAINT fk_customer_individual_person FOREIGN KEY (person_id) REFERENCES people,
);

CREATE TABLE companies (
  customer_id INT          NOT NULL,
  name        VARCHAR(255) NOT NULL,

  CONSTRAINT pk_companies PRIMARY KEY (customer_id),
  CONSTRAINT fk_companies_customer FOREIGN KEY (customer_id) REFERENCES customers,
);
