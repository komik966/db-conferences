CREATE PROCEDURE create_workshop
    @name          VARCHAR(64),
    @max_attendees INT
AS
  INSERT INTO workshops VALUES (@name, @max_attendees)
GO;
