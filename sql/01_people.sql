CREATE TABLE people (
  id          INT IDENTITY CONSTRAINT pk_people PRIMARY KEY,
  first_name  VARCHAR(255) NOT NULL,
  second_name VARCHAR(255) NOT NULL,
);

CREATE TABLE student_card (
  id        INT IDENTITY CONSTRAINT pk_student_card PRIMARY KEY,
  number    VARCHAR(32) NOT NULL,
  person_id INT         NOT NULL CONSTRAINT unique_student_card_person UNIQUE CONSTRAINT fk_student_card_person FOREIGN KEY REFERENCES people
);
