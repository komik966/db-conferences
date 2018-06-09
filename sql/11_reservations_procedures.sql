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
GO;
