CREATE TABLE reservations (
  id            INT IDENTITY CONSTRAINT pk_reservations PRIMARY KEY,
  order_item_id INT NOT NULL CONSTRAINT fk_reservations_order_item FOREIGN KEY REFERENCES orders_items CONSTRAINT unique_reservations_order_item UNIQUE,
  person_id     INT CONSTRAINT default_reservations_person DEFAULT NULL CONSTRAINT fk_reservations_person FOREIGN KEY REFERENCES people
);

CREATE TABLE reservations_conferences_days (
  conference_day_id INT CONSTRAINT fk_reservations_conferences_days_conference FOREIGN KEY REFERENCES conferences,
  reservation_id    INT CONSTRAINT fk_reservations_conferences_days_reservation FOREIGN KEY REFERENCES reservations,
  CONSTRAINT pk_reservations_conferences_days PRIMARY KEY (conference_day_id, reservation_id)
);

CREATE TABLE reservations_workshops_days (
  workshop_day_id INT CONSTRAINT fk_reservations_workshops_days_workshop_day FOREIGN KEY REFERENCES workshops_days,
  reservation_id  INT CONSTRAINT fk_reservations_workshops_days_reservation FOREIGN KEY REFERENCES reservations,
  --   reservation_conference_day_id INT CONSTRAINT fk_reservations_workshops_days_reservation_conference_day FOREIGN KEY REFERENCES reservations_conferences_days
);
