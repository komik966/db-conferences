CREATE TABLE workshops (
  id                        INT IDENTITY,
  name                      VARCHAR(64) NOT NULL,
  maximum_attendee_capacity INT         NOT NULL,

  CONSTRAINT pk_workshops PRIMARY KEY (id),
);

CREATE TABLE workshop_days (
  id                        INT IDENTITY,
  workshop_id               INT        NOT NULL,
  conference_day_id         INT        NOT NULL,
  start_time                TIME(0)    NOT NULL,
  end_time                  TIME(0)    NOT NULL,
  price                     SMALLMONEY NOT NULL,
  maximum_attendee_capacity INT        NOT NULL,

  CONSTRAINT pk_workshop_days PRIMARY KEY (id),
  CONSTRAINT fk_workshop_days_workshop FOREIGN KEY (workshop_id) REFERENCES workshops,
  CONSTRAINT fk_workshop_days_conference_day FOREIGN KEY (conference_day_id) REFERENCES conference_days,
  CONSTRAINT ck_workshop_days_end_time CHECK (end_time > start_time)
);