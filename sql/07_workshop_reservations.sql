CREATE TABLE workshop_reservations (
  id                               INT                   IDENTITY,
  conference_reservation_detail_id INT          NOT NULL,
  -- TODO: workshop_day.(start/stop date) = conference_reservation_details.conference_day.date
  workshop_day_id                  INT          NOT NULL,
  -- TODO: suma attendees_amount nie może być większa od workshop_days.maximum_attendee_capacity
  attendees_amount                 INT          NOT NULL,
  reservation_date                 DATETIME2(0) NOT NULL CONSTRAINT df_workshop_reservations_reservation_date DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT pk_workshop_reservations PRIMARY KEY (id),
  CONSTRAINT fk_workshop_reservations_conference_reservation_detail FOREIGN KEY (conference_reservation_detail_id) REFERENCES conference_reservation_details,
  CONSTRAINT fk_workshop_reservations_workshop_day FOREIGN KEY (workshop_day_id) REFERENCES workshop_days,
);

CREATE TABLE workshop_attendees (
  id                      INT          IDENTITY,
  -- ?TODO? sprawdzenie czy conference_attendee.conference pokrywa się workshop.conference
  conference_attendee_id  INT NOT NULL,
  workshop_reservation_id INT NOT NULL,
  -- Potrzebne? - możliwość dorezerowania worshop do reservation conference?
  -- przenieść do workshop_reservations
  payment_date            DATETIME2(0) DEFAULT NULL,

  CONSTRAINT pk_workshop_attendees PRIMARY KEY (id),
  CONSTRAINT fk_workshop_attendees_conference_attendee FOREIGN KEY (conference_attendee_id) REFERENCES conference_attendees,
  CONSTRAINT fk_workshop_attendees_workshop_reservation FOREIGN KEY (workshop_reservation_id) REFERENCES workshop_reservations,
);