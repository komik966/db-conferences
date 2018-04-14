CREATE TABLE people (
  id UNIQUEIDENTIFIER DEFAULT NEWID() CONSTRAINT pk_people PRIMARY KEY,
  first_name VARCHAR(255),
  second_name VARCHAR(255),
  phone_number VARCHAR(32) CONSTRAINT unique_people_phone_number UNIQUE
);

INSERT INTO people (id, first_name, second_name, phone_number) VALUES ('C04FD5BD-8A4D-4A64-8F77-1C7D8EE8357A', 'Adam', 'Mickiewicz', '123456789');
INSERT INTO people (id, first_name, second_name, phone_number) VALUES ('E910E56B-E5C4-4677-8F99-23E7D0C7583F', 'Bolesław', 'Prus', '123456788');
