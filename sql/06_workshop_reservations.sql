CREATE TABLE workshop_reservations (
  id                               INT                IDENTITY CONSTRAINT pk_workshop_reservations PRIMARY KEY,
  conference_reservation_detail_id INT       NOT NULL CONSTRAINT fk_workshop_reservations_conference_reservation_detail FOREIGN KEY REFERENCES conference_reservation_details,
  workshop_day_id                  INT       NOT NULL CONSTRAINT fk_workshop_reservations_workshop_day FOREIGN KEY REFERENCES workshop_days,
  -- TODO: suma attendees_amount nie może być większa od workshop_days.maximum_attendee_capacity
  attendees_amount                 INT       NOT NULL,
  reservation_date                 DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
);
CREATE TABLE workshop_attendees (
  id                      INT       IDENTITY CONSTRAINT pk_workshop_attendees PRIMARY KEY,
  conference_attendee_id  INT NOT NULL CONSTRAINT fk_workshop_attendees_conference_attendee FOREIGN KEY REFERENCES conference_attendees,
  workshop_reservation_id INT NOT NULL CONSTRAINT fk_workshop_attendees_workshop_reservation FOREIGN KEY REFERENCES workshop_reservations,
  payment_date            DATETIME2 DEFAULT NULL
);