CREATE TABLE conferences (
  id               INT                   IDENTITY,
  name             VARCHAR(64)  NOT NULL,
  description      VARCHAR(255) NOT NULL,
  start_date       DATETIME2(0) NOT NULL,
  end_date         DATETIME2(0) NOT NULL,
  basic_price      SMALLMONEY   NOT NULL,
  student_discount FLOAT        NOT NULL CONSTRAINT df_conferences_student_discount DEFAULT 0,
  max_attendees    INT          NOT NULL,

  CONSTRAINT pk_conferences PRIMARY KEY (id),
  CONSTRAINT ck_conferences_start_date CHECK (start_date > CURRENT_TIMESTAMP),
  CONSTRAINT ck_conferences_end_date CHECK (end_date > start_date),
  CONSTRAINT ck_conferences_student_discount CHECK (student_discount >= 0 AND student_discount <= 1),
  CONSTRAINT ck_conferences_basic_price CHECK (basic_price > 0),
  CONSTRAINT ck_conferences_max_attendees CHECK (max_attendees > 0),
);

CREATE TABLE conference_discounts
(
  id            INT IDENTITY,
  conference_id INT          NOT NULL,
  due_date      DATETIME2(0) NOT NULL,
  discount      FLOAT        NOT NULL,

  CONSTRAINT pk_conference_discounts PRIMARY KEY (id),
  CONSTRAINT fk_conference_discounts_conference FOREIGN KEY (conference_id) REFERENCES conferences,
  CONSTRAINT ck_conference_discounts_discount CHECK (discount > 0 AND discount <= 1),
  CONSTRAINT ck_conference_discounts_due_date CHECK (due_date > CURRENT_TIMESTAMP),
  CONSTRAINT uq_conference_discounts_due_date UNIQUE (conference_id, due_date)
);

CREATE TABLE conference_days
(
  id            INT IDENTITY,
  conference_id INT  NOT NULL,
  date          DATE NOT NULL,

  CONSTRAINT pk_conference_days PRIMARY KEY (id),
  CONSTRAINT fk_conference_days_conference FOREIGN KEY (conference_id) REFERENCES conferences,
  CONSTRAINT uq_conference_days_date UNIQUE (conference_id, date)
);