CREATE FUNCTION dbo.date_range(@start_date DATE, @end_date DATE)
  RETURNS TABLE AS RETURN
  (
  WITH date_range
  AS (SELECT @start_date AS date
      UNION ALL
      SELECT DATEADD(DAY, 1, date)
      FROM date_range
      WHERE DATEADD(DAY, 1, date) <= @end_date)
  SELECT date
  FROM date_range
  );