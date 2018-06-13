CREATE VIEW conference_day_max_attendees AS
  SELECT
    cd.id conference_day_id,
    c.max_attendees
  FROM conference_days cd INNER JOIN conferences c on cd.conference_id = c.id;