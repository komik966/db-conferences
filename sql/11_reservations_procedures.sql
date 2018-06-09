CREATE PROCEDURE create_reservation
    @customer_id       INT,
    @conference_day_id INT,
    @attendees_amount  INT
AS
  BEGIN TRANSACTION

  BEGIN TRY

  INSERT INTO conference_reservations (customer_id) VALUES (@customer_id);
  DECLARE @conference_reservation_id INT;
  SET @conference_reservation_id = SCOPE_IDENTITY();
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
  DECLARE @person_id INT;
  SET @person_id = SCOPE_IDENTITY();
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
  DECLARE @conference_attendee_id INT;
  SET @conference_attendee_id = SCOPE_IDENTITY();
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
GO;

CREATE PROCEDURE add_workshop_attendee
    @conference_attendee_id  INT,
    @workshop_reservation_id INT
AS
  INSERT INTO workshop_attendees VALUES (@conference_attendee_id, @workshop_reservation_id);
GO;