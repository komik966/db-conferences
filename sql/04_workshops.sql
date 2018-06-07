CREATE TABLE workshops (
  id            INT IDENTITY,
  name          VARCHAR(64) NOT NULL,
  max_attendees INT         NOT NULL,

  CONSTRAINT pk_workshops PRIMARY KEY (id),
  CONSTRAINT ck_workshops_max_attendees CHECK (max_attendees > 0),
);

CREATE TABLE workshop_days (
  id                INT IDENTITY,
  workshop_id       INT        NOT NULL,
  conference_day_id INT        NOT NULL,
  start_time        TIME(0)    NOT NULL,
  end_time          TIME(0)    NOT NULL,
  price             SMALLMONEY NOT NULL,
  max_attendees     INT        NOT NULL,

  CONSTRAINT pk_workshop_days PRIMARY KEY (id),
  CONSTRAINT fk_workshop_days_workshop FOREIGN KEY (workshop_id) REFERENCES workshops,
  CONSTRAINT fk_workshop_days_conference_day FOREIGN KEY (conference_day_id) REFERENCES conference_days,
  CONSTRAINT ck_workshop_days_end_time CHECK (end_time > start_time),
  CONSTRAINT ck_workshop_days_price CHECK (price >= 0),
  CONSTRAINT ck_workshop_days_max_attendees CHECK (max_attendees > 0),
);