CREATE PROCEDURE add_conference_attendee
    @conference_reservation_detail_id INT,
    @first_name                       VARCHAR(255),
    @second_name                      VARCHAR(255)
AS
  IF (SELECT non_student_count
      FROM not_filled_conference_attendees_count
      WHERE conference_reservation_detail_id = @conference_reservation_detail_id) = 0
    THROW 50001, 'All non student attendees data was provided for this reservation.', 0;
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
GO

CREATE PROCEDURE add_conference_attendee_student
    @conference_reservation_detail_id INT,
    @first_name                       VARCHAR(255),
    @second_name                      VARCHAR(255),
    @student_card_id                  INT
AS
  IF (SELECT student_count
      FROM not_filled_conference_attendees_count
      WHERE conference_reservation_detail_id = @conference_reservation_detail_id) = 0
    THROW 50001, 'All student attendees data was provided for this reservation.', 0;
  IF (SELECT conference_reservation_detail_id
      FROM student_cards
      WHERE id = @student_card_id) != @conference_reservation_detail_id
    THROW 50001, 'Attendee conference reservation detail must be the same as in student card.', 0;

  BEGIN TRANSACTION

  BEGIN TRY
  INSERT INTO people VALUES (@first_name, @second_name);
  DECLARE @person_id INT = SCOPE_IDENTITY();
  INSERT INTO conference_attendees VALUES (@person_id, @conference_reservation_detail_id);
  DECLARE @conference_attendee_id INT = SCOPE_IDENTITY();
  INSERT INTO conference_attendees_students VALUES (@conference_attendee_id, @student_card_id);
  COMMIT;
  END TRY

  BEGIN CATCH
  ROLLBACK;
  THROW;
  END CATCH;
GO

CREATE PROCEDURE add_workshop_attendee
    @conference_attendee_id  INT,
    @workshop_reservation_id INT
AS

  INSERT INTO workshop_attendees VALUES (@conference_attendee_id, @workshop_reservation_id);
GO