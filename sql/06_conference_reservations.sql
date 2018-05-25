CREATE TABLE conference_reservations (
  id               INT                   IDENTITY,
  customer_id      INT          NOT NULL,
  reservation_date DATETIME2(0) NOT NULL CONSTRAINT df_conference_reservations_reservation_date DEFAULT CURRENT_TIMESTAMP,
  payment_date     DATETIME2(0)          DEFAULT NULL,

  CONSTRAINT pk_conference_reservations PRIMARY KEY (id),
  CONSTRAINT fk_conference_reservations_customer FOREIGN KEY (customer_id) REFERENCES customers,
);

CREATE TABLE conference_reservation_details (
  id                        INT IDENTITY,
  conference_day_id         INT NOT NULL,
  conference_reservation_id INT NOT NULL,
  -- TODO: suma attendees_amount nie może być większa od conferences.maximum_attendee_capacity
  attendees_amount          INT NOT NULL,

  CONSTRAINT pk_conference_reservation_details PRIMARY KEY (id),
  CONSTRAINT fk_conference_reservation_details_conference_day FOREIGN KEY (conference_day_id) REFERENCES conference_days,
  CONSTRAINT fk_conference_reservation_details_conference_reservation FOREIGN KEY (conference_reservation_id) REFERENCES conference_reservations,
);

CREATE TABLE conference_attendees (
  id                               INT IDENTITY,
  person_id                        INT NOT NULL,
  conference_reservation_detail_id INT NOT NULL,

  CONSTRAINT pk_conference_attendees PRIMARY KEY (id),
  CONSTRAINT fk_conference_attendees_person FOREIGN KEY (person_id) REFERENCES people,
  CONSTRAINT fk_conference_attendees_conference_reservation_detail FOREIGN KEY (conference_reservation_detail_id) REFERENCES conference_reservation_details,
);