CREATE PROCEDURE create_conference
    @name             VARCHAR(64),
    @description      VARCHAR(255),
    @start_date       DATETIME2,
    @end_date         DATETIME2,
    @basic_price      SMALLMONEY,
    @student_discount FLOAT,
    @max_attendees    INT
AS
  INSERT INTO conferences VALUES (
    @name,
    @description,
    @start_date,
    @end_date,
    @basic_price,
    @student_discount,
    @max_attendees
  );
  DECLARE @conference_id INT;
  SET @conference_id = SCOPE_IDENTITY();
  INSERT INTO conference_days SELECT
                                @conference_id,
                                date
                              FROM dbo.date_range(@start_date, @end_date);
GO;

CREATE PROCEDURE create_conference_discount
    @conference_id INT,
    @due_date      DATETIME2,
    @discount      FLOAT
AS
  INSERT INTO conference_discounts VALUES (@conference_id, @due_date, @discount)
GO;