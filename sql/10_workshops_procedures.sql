CREATE PROCEDURE create_workshop
    @name          VARCHAR(64),
    @max_attendees INT
AS
  INSERT INTO workshops VALUES (@name, @max_attendees)
GO;

CREATE PROCEDURE create_workshop_day
    @workshop_id       INT,
    @conference_day_id INT,
    @start_time        TIME,
    @end_time          TIME,
    @price             SMALLMONEY,
    @max_attendees     INT
AS
  INSERT INTO workshop_days VALUES (@workshop_id, @conference_day_id, @start_time, @end_time, @price, @max_attendees)
GO;
