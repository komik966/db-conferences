CREATE TABLE conferences (
  id   INT IDENTITY CONSTRAINT pk_conferences PRIMARY KEY,
  name VARCHAR(64) NOT NULL,
);

INSERT INTO conferences (name) VALUES ('Code Europe Wrocław 2018');
INSERT INTO conferences (name) VALUES ('NightHack');

CREATE TABLE conferences_days (
  id                        INT IDENTITY CONSTRAINT pk_conferences_days PRIMARY KEY,
  conference_id             INT       NOT NULL CONSTRAINT fk_conferences_days_conference FOREIGN KEY REFERENCES conferences,
  --   TODO: start_date, end_date - daty z przyszłości, end_date - data późniejsza od start_date
  --   daty w różnych wierszach tej samej konferencji nie mogą się pokrywać
  start_date                DATETIME2 NOT NULL,
  end_date                  DATETIME2 NOT NULL,
  maximum_attendee_capacity INT       NOT NULL
);

INSERT INTO conferences_days (conference_id, start_date, end_date, maximum_attendee_capacity)
VALUES (1, DATEADD(WEEK, 1, CURRENT_TIMESTAMP), DATEADD(HOUR, 4, CURRENT_TIMESTAMP), 100);
INSERT INTO conferences_days (conference_id, start_date, end_date, maximum_attendee_capacity)
VALUES
  (1, DATEADD(DAY, 1, DATEADD(WEEK, 1, CURRENT_TIMESTAMP)), DATEADD(DAY, 1, DATEADD(HOUR, 4, CURRENT_TIMESTAMP)), 100);
INSERT INTO conferences_days (conference_id, start_date, end_date, maximum_attendee_capacity)
VALUES
  (3, CURRENT_TIMESTAMP, DATEADD(HOUR, 4, CURRENT_TIMESTAMP), 20);


CREATE TABLE prices_specifications (
  id            INT IDENTITY CONSTRAINT pk_prices_specifications PRIMARY KEY,
  --   TODO: valid_from, valid_through - daty z przyszłości, valid_through - data późniejsza
  valid_from    DATETIME2  NOT NULL,
  valid_through DATETIME2  NOT NULL,
  price         SMALLMONEY NOT NULL
);

INSERT INTO prices_specifications (valid_from, valid_through, price)
VALUES (CURRENT_TIMESTAMP, DATEADD(WEEK, 1, CURRENT_TIMESTAMP), 150.00)

INSERT INTO prices_specifications (valid_from, valid_through, price)
VALUES (CURRENT_TIMESTAMP, DATEADD(WEEK, 1, CURRENT_TIMESTAMP), 70.00)
