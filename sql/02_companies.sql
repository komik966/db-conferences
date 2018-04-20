CREATE TABLE companies (
  id                INT IDENTITY CONSTRAINT pk_companies PRIMARY KEY,
  contact_person_id INT CONSTRAINT fk_companies_contact_person FOREIGN KEY REFERENCES people NOT NULL,
  name VARCHAR(255) NOT NULL
);

INSERT INTO companies (contact_person_id, name) VALUES (1, 'Dziady');
INSERT INTO companies (contact_person_id, name) VALUES (1, 'Pan Tadeusz');
INSERT INTO companies (contact_person_id, name) VALUES (2, 'Lalka');