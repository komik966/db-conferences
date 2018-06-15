CREATE PROCEDURE throw_if_conference_attendees_amount_will_exceed
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
      DECLARE @msg NVARCHAR(2048) = FORMATMESSAGE('For this conference day leaved only %d places.',
                                                  @max_reservation_allowed);
      THROW 50001, @msg, 0
    END;
GO

CREATE PROCEDURE throw_if_workshop_attendees_amount_will_exceed
    @workshop_day_id           INT,
    @attendees_amount_to_check INT
AS
  DECLARE @max_attendees INT, @actual INT, @max_reservation_allowed INT

  SET @max_attendees = (SELECT COALESCE((SELECT max_attendees
                                         FROM workshop_days
                                         WHERE id = @workshop_day_id), 0));

  SET @actual = (SELECT COALESCE((SELECT SUM(attendees_amount)
                                  FROM workshop_reservations
                                  WHERE workshop_day_id = @workshop_day_id
                                  GROUP BY workshop_day_id), 0));

  SET @max_reservation_allowed = @max_attendees - @actual;

  IF (@attendees_amount_to_check > @max_reservation_allowed)
    BEGIN
      DECLARE @msg NVARCHAR(2048) = FORMATMESSAGE('For this workshop day leaved only %d places.',
                                                  @max_reservation_allowed);
      THROW 50001, @msg, 0
    END;
GO

CREATE PROCEDURE throw_if_reservation_is_paid @conference_reservation_id INT AS
  IF (SELECT payment_date
      FROM conference_reservations
      WHERE id = @conference_reservation_id) IS NOT NULL
    THROW 50001, 'Cannot modify reservation which is paid.', 0
GO
