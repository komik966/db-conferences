CREATE TABLE companies (
  id                UNIQUEIDENTIFIER DEFAULT NEWID() CONSTRAINT pk_companies PRIMARY KEY,
  contact_person_id UNIQUEIDENTIFIER CONSTRAINT fk_companies_contact_person FOREIGN KEY REFERENCES people,
  name VARCHAR(255)
);