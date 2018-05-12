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