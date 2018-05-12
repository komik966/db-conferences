CREATE TABLE conferences (
  id                        INT   IDENTITY CONSTRAINT pk_conferences PRIMARY KEY,
  name                      VARCHAR(64)  NOT NULL,
  description               VARCHAR(255) NOT NULL,
  --   TODO: start_date, end_date - daty z przyszłości, end_date - data późniejsza od start_date
  start_date                DATETIME2    NOT NULL,
  end_date                  DATETIME2    NOT NULL,
  basic_price               SMALLMONEY   NOT NULL,
  student_discount          FLOAT DEFAULT NULL,
  maximum_attendee_capacity INT          NOT NULL
);

CREATE TABLE conference_discounts
(
  id            INT IDENTITY CONSTRAINT pk_conference_discounts PRIMARY KEY,
  conference_id INT       NOT NULL CONSTRAINT fk_conference_discounts_conference REFERENCES conferences,
  due_date      DATETIME2 NOT NULL,
  discount      FLOAT     NOT NULL
);

CREATE TABLE conference_days
(
  id            INT IDENTITY CONSTRAINT pk_conference_days PRIMARY KEY,
  conference_id INT  NOT NULL CONSTRAINT fk_conference_days_conference REFERENCES conferences,
  date          DATE NOT NULL
);