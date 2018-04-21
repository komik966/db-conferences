CREATE TABLE workshops (
  id                        INT IDENTITY CONSTRAINT pk_workshops PRIMARY KEY,
  conference_id             INT        NOT NULL CONSTRAINT fk_workshops_conference FOREIGN KEY REFERENCES conferences,
  maximum_attendee_capacity INT        NOT NULL,
  price                     SMALLMONEY NOT NULL
);

CREATE TABLE workshops_days (
  id          INT IDENTITY CONSTRAINT pk_workshops_days PRIMARY KEY,
  workshop_id INT       NOT NULL CONSTRAINT fk_workshops_days_workshop FOREIGN KEY REFERENCES workshops,
  --   TODO: start_date, end_date - daty z przyszłości, end_date - data późniejsza od start_date
  start_date  DATETIME2 NOT NULL,
  end_date    DATETIME2 NOT NULL,
);
