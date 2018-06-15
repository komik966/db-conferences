CREATE TABLE conference_reservations (
  id               INT                   IDENTITY,
  customer_id      INT          NOT NULL,
  reservation_date DATETIME2(0) NOT NULL CONSTRAINT df_conference_reservations_reservation_date DEFAULT CURRENT_TIMESTAMP,
  payment_date     DATETIME2(0)          CONSTRAINT df_conference_reservations_payment_date DEFAULT NULL,

  CONSTRAINT pk_conference_reservations PRIMARY KEY (id),
  CONSTRAINT fk_conference_reservations_customer FOREIGN KEY (customer_id) REFERENCES customers,
);

CREATE TABLE conference_reservation_details (
  id                        INT IDENTITY,
  conference_day_id         INT NOT NULL,
  conference_reservation_id INT NOT NULL,
  attendees_amount          INT NOT NULL,

  CONSTRAINT pk_conference_reservation_details PRIMARY KEY (id),
  CONSTRAINT fk_conference_reservation_details_conference_day FOREIGN KEY (conference_day_id) REFERENCES conference_days,
  CONSTRAINT fk_conference_reservation_details_conference_reservation FOREIGN KEY (conference_reservation_id) REFERENCES conference_reservations,
  CONSTRAINT uq_conference_reservation_details_conference_day_reservation UNIQUE (conference_day_id, conference_reservation_id),
  CONSTRAINT ck_conference_reservation_details_attendees_amount CHECK (attendees_amount > 0),
);

CREATE TABLE student_cards (
  id                               INT IDENTITY,
  conference_reservation_detail_id INT         NOT NULL,
  number                           VARCHAR(32) NOT NULL,

  CONSTRAINT pk_student_card PRIMARY KEY (id),
  CONSTRAINT fk_student_card_conference_reservation_detail FOREIGN KEY (conference_reservation_detail_id) REFERENCES conference_reservation_details,
  CONSTRAINT uq_student_card_number UNIQUE (conference_reservation_detail_id, number),
);

CREATE TABLE conference_attendees (
  id                               INT IDENTITY,
  person_id                        INT NOT NULL,
  conference_reservation_detail_id INT NOT NULL,

  CONSTRAINT pk_conference_attendees PRIMARY KEY (id),
  CONSTRAINT fk_conference_attendees_person FOREIGN KEY (person_id) REFERENCES people,
  CONSTRAINT fk_conference_attendees_conference_reservation_detail FOREIGN KEY (conference_reservation_detail_id) REFERENCES conference_reservation_details,
  CONSTRAINT uq_conference_attendees_person_reservation_detail UNIQUE (person_id, conference_reservation_detail_id)
);

CREATE TABLE conference_attendees_students (
  conference_attendee_id INT NOT NULL,
  student_card_id        INT NOT NULL,

  CONSTRAINT pk_conference_attendees_student PRIMARY KEY (conference_attendee_id),
  CONSTRAINT uq_conference_attendees_students_conference_attendee UNIQUE (conference_attendee_id),
  CONSTRAINT uq_conference_attendees_students_student_card_id UNIQUE (student_card_id),
  CONSTRAINT fk_conference_attendees_student_conference_attendee FOREIGN KEY (conference_attendee_id) REFERENCES conference_attendees,
  CONSTRAINT fk_conference_attendees_student_student_card FOREIGN KEY (student_card_id) REFERENCES student_cards,
);