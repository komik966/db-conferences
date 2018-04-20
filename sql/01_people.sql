CREATE TABLE people (
  id INT IDENTITY CONSTRAINT pk_people PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  second_name VARCHAR(255) NOT NULL,
);

INSERT INTO people (first_name, second_name) VALUES ('Lyla', 'Heaney');
INSERT INTO people (first_name, second_name) VALUES ('Willis', 'McClure');
