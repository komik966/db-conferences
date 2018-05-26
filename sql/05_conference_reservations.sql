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

CREATE TABLE conference_attendees (
  id                               INT IDENTITY,
  person_id                        INT NOT NULL,
  conference_reservation_detail_id INT NOT NULL,

  CONSTRAINT pk_conference_attendees PRIMARY KEY (id),
  CONSTRAINT fk_conference_attendees_person FOREIGN KEY (person_id) REFERENCES people,
  CONSTRAINT fk_conference_attendees_conference_reservation_detail FOREIGN KEY (conference_reservation_detail_id) REFERENCES conference_reservation_details,
);