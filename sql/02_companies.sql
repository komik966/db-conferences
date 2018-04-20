CREATE TABLE companies (
  id                INT IDENTITY CONSTRAINT pk_companies PRIMARY KEY,
  contact_person_id INT          NOT NULL CONSTRAINT fk_companies_contact_person FOREIGN KEY REFERENCES people,
  name              VARCHAR(255) NOT NULL
);

INSERT INTO companies (contact_person_id, name) VALUES (1, 'Harris Inc');
INSERT INTO companies (contact_person_id, name) VALUES (1, 'Lehner LLC');
INSERT INTO companies (contact_person_id, name) VALUES (2, 'Haley Group');