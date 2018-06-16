CREATE TABLE workshop_reservations (
  id                               INT IDENTITY,
  conference_reservation_detail_id INT NOT NULL,
  workshop_day_id                  INT NOT NULL,
  attendees_amount                 INT NOT NULL,

  CONSTRAINT pk_workshop_reservations PRIMARY KEY (id),
  CONSTRAINT fk_workshop_reservations_conference_reservation_detail FOREIGN KEY (conference_reservation_detail_id) REFERENCES conference_reservation_details ON DELETE CASCADE,
  CONSTRAINT fk_workshop_reservations_workshop_day FOREIGN KEY (workshop_day_id) REFERENCES workshop_days,
  CONSTRAINT ck_workshop_reservations_attendees_amount CHECK (attendees_amount > 0),
  CONSTRAINT uq_workshop_reservations_conference_reservation_workshop_day UNIQUE (conference_reservation_detail_id, workshop_day_id),
);

CREATE TABLE workshop_attendees (
  id                      INT IDENTITY,
  conference_attendee_id  INT NOT NULL,
  workshop_reservation_id INT NOT NULL,

  CONSTRAINT pk_workshop_attendees PRIMARY KEY (id),
  CONSTRAINT fk_workshop_attendees_conference_attendee FOREIGN KEY (conference_attendee_id) REFERENCES conference_attendees ON DELETE CASCADE,
  CONSTRAINT fk_workshop_attendees_workshop_reservation FOREIGN KEY (workshop_reservation_id) REFERENCES workshop_reservations ON DELETE CASCADE,
);