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
  attendees_amount          INT NOT NULL,

  CONSTRAINT pk_conference_reservation_details PRIMARY KEY (id),
  CONSTRAINT fk_conference_reservation_details_conference_day FOREIGN KEY (conference_day_id) REFERENCES conference_days,
  CONSTRAINT fk_conference_reservation_details_conference_reservation FOREIGN KEY (conference_reservation_id) REFERENCES conference_reservations,
  CONSTRAINT uq_conference_reservation_details_conference_day_reservation UNIQUE (conference_day_id, conference_reservation_id),
);

CREATE TABLE conference_attendees (
  id                               INT IDENTITY,
  person_id                        INT NOT NULL,
  conference_reservation_detail_id INT NOT NULL,

  CONSTRAINT pk_conference_attendees PRIMARY KEY (id),
  CONSTRAINT fk_conference_attendees_person FOREIGN KEY (person_id) REFERENCES people,
  CONSTRAINT fk_conference_attendees_conference_reservation_detail FOREIGN KEY (conference_reservation_detail_id) REFERENCES conference_reservation_details,
);

CREATE TRIGGER conference_reservation_details_attendees_amount
  ON conference_reservation_details
  AFTER INSERT, UPDATE AS
  IF ((SELECT c.maximum_attendee_capacity
       FROM inserted
         INNER JOIN conference_days cd
           ON inserted.conference_day_id = cd.id
         INNER JOIN conferences c ON cd.conference_id = c.id) < (SELECT SUM(crd.attendees_amount)
                                                                 FROM inserted
                                                                   INNER JOIN conference_reservation_details crd
                                                                     ON crd.conference_day_id =
                                                                        inserted.conference_day_id
                                                                 GROUP BY crd.conference_day_id))
    BEGIN
      RAISERROR ('Attendees amount for this conference was exceeded.', 16, 1);
      ROLLBACK TRANSACTION;
      RETURN
    END;