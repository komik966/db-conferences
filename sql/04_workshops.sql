CREATE TABLE workshops (
  id   INT IDENTITY CONSTRAINT pk_workshops PRIMARY KEY,
  name VARCHAR(64) NOT NULL
);

CREATE TABLE workshop_days (
  id                        INT IDENTITY CONSTRAINT pk_workshop_days PRIMARY KEY,
  workshop_id               INT        NOT NULL CONSTRAINT fk_workshop_days_workshop REFERENCES workshops,
  conference_day_id         INT        NOT NULL CONSTRAINT fk_workshop_days_conference_day REFERENCES conference_days,
  -- TODO: start_date, end_date - daty w tym samym dniu co conference_days.date
  start_date                DATETIME2  NOT NULL,
  end_date                  DATETIME2  NOT NULL,
  price                     SMALLMONEY NOT NULL,
  maximum_attendee_capacity INT        NOT NULL
);