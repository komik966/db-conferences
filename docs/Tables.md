# Spis treści
- [Tabele](#tabele)
    - [people](#people)
    - [customers](#customers)
    - [customer_individual](#customer_individual)
    - [companies](#companies)

# Tabele

## people
```sql
CREATE TABLE people (
  id          INT IDENTITY,
  first_name  VARCHAR(255) NOT NULL,
  second_name VARCHAR(255) NOT NULL,

  CONSTRAINT pk_people PRIMARY KEY (id),
);
```

## customers
```sql
CREATE TABLE customers (
  id           INT IDENTITY,
  phone_number VARCHAR(32) NOT NULL,

  CONSTRAINT pk_customers PRIMARY KEY (id),
  CONSTRAINT uq_customers_phone_number UNIQUE (phone_number),
);
```

## customer_individual
```sql
CREATE TABLE customer_individual (
  customer_id INT,
  person_id   INT NOT NULL,

  CONSTRAINT pk_customer_individual PRIMARY KEY (customer_id),
  CONSTRAINT fk_customer_individual_customer FOREIGN KEY (customer_id) REFERENCES customers,
  CONSTRAINT uq_customer_individual_person UNIQUE (person_id),
  CONSTRAINT fk_customer_individual_person FOREIGN KEY (person_id) REFERENCES people,
);
```
## companies
```sql
CREATE TABLE companies (
  customer_id INT          NOT NULL,
  name        VARCHAR(255) NOT NULL,
  nip         VARCHAR(32)  NOT NULL,

  CONSTRAINT pk_companies PRIMARY KEY (customer_id),
  CONSTRAINT fk_companies_customer FOREIGN KEY (customer_id) REFERENCES customers,
  CONSTRAINT uq_companies_nip UNIQUE (nip),
);
```

