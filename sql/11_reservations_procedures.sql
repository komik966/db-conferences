CREATE PROCEDURE check_conference_day_attendees_amount
    @conference_day_id         INT,
    @attendees_amount_to_check INT
AS
  DECLARE @max_attendees INT, @actual INT, @max_reservation_allowed INT

  SET @max_attendees = (SELECT COALESCE((SELECT max_attendees
                                         FROM conference_day_max_attendees
                                         WHERE conference_day_id = @conference_day_id), 0));

  SET @actual = (SELECT COALESCE((SELECT SUM(attendees_amount)
                                  FROM conference_reservation_details
                                  WHERE conference_day_id = @conference_day_id
                                  GROUP BY conference_day_id), 0));

  SET @max_reservation_allowed = @max_attendees - @actual;

  IF (@attendees_amount_to_check > @max_reservation_allowed)
    BEGIN
      DECLARE @msg NVARCHAR(2048) = FORMATMESSAGE('For this conference leaved only %d places.',
                                                  @max_reservation_allowed);
      THROW 50001, @msg, 0
    END;
GO ;

CREATE PROCEDURE create_reservation
    @customer_id       INT,
    @conference_day_id INT,
    @attendees_amount  INT
AS
  BEGIN TRANSACTION

  BEGIN TRY

  EXEC dbo.check_conference_day_attendees_amount @conference_day_id, @attendees_amount;
  INSERT INTO conference_reservations (customer_id) VALUES (@customer_id);
  DECLARE @conference_reservation_id INT = SCOPE_IDENTITY();
  INSERT INTO conference_reservation_details VALUES (@conference_day_id, @conference_reservation_id, @attendees_amount)

  COMMIT;
  END TRY

  BEGIN CATCH
  ROLLBACK;
  THROW;
  END CATCH;
GO ;

CREATE PROCEDURE add_conference_day_reservation
    @conference_reservation_id INT,
    @conference_day_id         INT,
    @attendees_amount          INT
AS
  INSERT INTO conference_reservation_details VALUES (@conference_day_id, @conference_reservation_id, @attendees_amount)
GO ;

CREATE PROCEDURE add_student_card
    @conference_reservation_detail_id INT,
    @number                           VARCHAR(32)
AS
  INSERT INTO student_cards VALUES (@conference_reservation_detail_id, @number);
GO ;

CREATE PROCEDURE add_conference_attendee
    @conference_reservation_detail_id INT,
    @first_name                       VARCHAR(255),
    @second_name                      VARCHAR(255)
AS
  BEGIN TRANSACTION

  BEGIN TRY

  INSERT INTO people VALUES (@first_name, @second_name);
  DECLARE @person_id INT = SCOPE_IDENTITY();
  INSERT INTO conference_attendees VALUES (@person_id, @conference_reservation_detail_id);

  COMMIT;
  END TRY

  BEGIN CATCH
  ROLLBACK;
  THROW;
  END CATCH;
GO ;

CREATE PROCEDURE add_conference_attendee_student
    @conference_reservation_detail_id INT,
    @first_name                       VARCHAR(255),
    @second_name                      VARCHAR(255),
    @student_card_id                  INT
AS
  BEGIN TRANSACTION

  BEGIN TRY
  DECLARE @conference_attendee_id INT = SCOPE_IDENTITY();
  EXEC dbo.add_conference_attendee @conference_reservation_detail_id, @first_name, @second_name
  INSERT INTO conference_attendees_students VALUES (@conference_attendee_id, @student_card_id);
  COMMIT;
  END TRY

  BEGIN CATCH
  ROLLBACK;
  THROW;
  END CATCH;
GO ;

CREATE PROCEDURE add_workshop_day_reservation
    @conference_reservation_detail_id INT,
    @workshop_day_id                  INT,
    @attendees_amount                 INT
AS
  INSERT INTO workshop_reservations VALUES (@conference_reservation_detail_id, @workshop_day_id, @attendees_amount)
GO ;

CREATE PROCEDURE add_workshop_attendee
    @conference_attendee_id  INT,
    @workshop_reservation_id INT
AS
  INSERT INTO workshop_attendees VALUES (@conference_attendee_id, @workshop_reservation_id);
GO;