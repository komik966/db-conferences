CREATE TYPE StudentCardNumbers AS TABLE(number VARCHAR(32)) GO

CREATE PROCEDURE add_conference_day_reservation
    @conference_day_id         INT,
    @attendees_amount          INT,
    @student_card_numbers      StudentCardNumbers READONLY,
    @conference_reservation_id INT = null,
    @customer_id               INT = null
AS
  IF @conference_reservation_id IS NOT NULL
    EXEC dbo.throw_if_reservation_is_paid  @conference_reservation_id
  EXEC dbo.throw_if_conference_attendees_amount_will_exceed @conference_day_id, @attendees_amount
  IF (SELECT COUNT(*)
      FROM @student_card_numbers) > @attendees_amount
    THROW 50001, 'Cannot add more student cards than declared attendees amount.', 0

  BEGIN TRANSACTION
  BEGIN TRY

  IF @conference_reservation_id IS NULL
    BEGIN
      INSERT INTO conference_reservations (customer_id) VALUES (@customer_id)
      SET @conference_reservation_id = SCOPE_IDENTITY();
    END
  INSERT INTO conference_reservation_details VALUES (@conference_day_id, @conference_reservation_id, @attendees_amount)
  DECLARE @conference_reservation_detail_id INT = SCOPE_IDENTITY();
  INSERT INTO student_cards SELECT
                              @conference_reservation_detail_id,
                              number
                            FROM @student_card_numbers

  COMMIT;
  END TRY

  BEGIN CATCH
  ROLLBACK;
  THROW;
  END CATCH;
GO

CREATE PROCEDURE add_workshop_day_reservation
    @conference_reservation_detail_id INT,
    @workshop_day_id                  INT,
    @attendees_amount                 INT
AS
  DECLARE @conference_reservation_id INT = (SELECT cr.id
                                            FROM
                                              conference_reservations cr INNER JOIN conference_reservation_details crd
                                                ON cr.id = crd.conference_reservation_id AND
                                                   crd.id = @conference_reservation_detail_id);
  EXEC dbo.throw_if_reservation_is_paid @conference_reservation_id
  IF @attendees_amount > (SELECT attendees_amount
                          FROM conference_reservation_details
                          WHERE id = @conference_reservation_detail_id)
    THROW 50001, 'Workshop day attendees amount must be lower or equal than conference day attendees amount.', 0;
  EXEC dbo.throw_if_workshop_attendees_amount_will_exceed @workshop_day_id, @attendees_amount
  IF (SELECT conference_day_id
      FROM conference_reservation_details
      WHERE id = @conference_reservation_detail_id) != (SELECT conference_day_id
                                                        FROM workshop_days
                                                        WHERE id = @workshop_day_id)
    THROW 50001, 'Workshop day must have the same conference day as reservation detail.', 0;


  INSERT INTO workshop_reservations VALUES (@conference_reservation_detail_id, @workshop_day_id, @attendees_amount)
GO

CREATE PROCEDURE pay_for_reservation
    @conference_reservation_id INT
AS
  UPDATE conference_reservations
  SET payment_date = CURRENT_TIMESTAMP
  WHERE id = @conference_reservation_id
GO

CREATE PROCEDURE delete_conference_reservations_too_late_for_payment AS
  DELETE FROM conference_reservations
  WHERE id IN (SELECT id
               FROM conference_reservations_too_late_for_payment);
GO
