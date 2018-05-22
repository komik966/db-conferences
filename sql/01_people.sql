CREATE TABLE people (
  id          INT IDENTITY,
  first_name  VARCHAR(255) NOT NULL,
  second_name VARCHAR(255) NOT NULL,

  CONSTRAINT pk_people PRIMARY KEY (id),
);

CREATE TABLE student_card (
  person_id INT         NOT NULL,
  number    VARCHAR(32) NOT NULL,

  CONSTRAINT pk_student_card PRIMARY KEY (person_id),
  CONSTRAINT fk_student_card_person FOREIGN KEY (person_id) REFERENCES people,
);
