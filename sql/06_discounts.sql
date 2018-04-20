CREATE TABLE discounts (
  id            INT IDENTITY CONSTRAINT pk_discounts PRIMARY KEY,
  percent_value INT NOT NULL,
  name          VARCHAR(64),
  CONSTRAINT unique_discounts_percent_value_name UNIQUE (percent_value, name)
);

INSERT INTO discounts (percent_value, name) VALUES (50, 'Zniżka studencka');
INSERT INTO discounts (percent_value, name) VALUES (20, 'Zniżka studencka');
