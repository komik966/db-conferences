CREATE TABLE conference_reservations (
  id               INT                IDENTITY CONSTRAINT pk_conference_reservations PRIMARY KEY,
  customer_id      INT       NOT NULL CONSTRAINT fk_conference_reservations_customer FOREIGN KEY REFERENCES customers,
  reservation_date DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
  payment_date     DATETIME2 DEFAULT NULL
);
CREATE TABLE conference_reservation_details (
  id                        INT IDENTITY CONSTRAINT pk_conference_reservation_details PRIMARY KEY,
  conference_day_id         INT NOT NULL CONSTRAINT fk_conference_reservation_details_conference_day FOREIGN KEY REFERENCES conference_days,
  conference_reservation_id INT NOT NULL CONSTRAINT fk_conference_reservation_details_conference_reservation FOREIGN KEY REFERENCES conference_reservations,
  -- TODO: suma attendees_amount nie może być większa od conferences.maximum_attendee_capacity
  attendees_amount          INT NOT NULL
);
CREATE TABLE conference_attendees (
  id                               INT IDENTITY CONSTRAINT pk_conference_attendees PRIMARY KEY,
  person_id                        INT NOT NULL CONSTRAINT fk_conference_attendees_person FOREIGN KEY REFERENCES people,
  conference_reservation_detail_id INT NOT NULL CONSTRAINT fk_conference_attendees_conference_reservation_detail FOREIGN KEY REFERENCES conference_reservation_details,
);