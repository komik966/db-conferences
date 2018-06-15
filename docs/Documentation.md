# Spis treści
- [Procedury](#procedury)
    - [create_conference](#procedura-create-conference)
    - [create_conference_discount](#procedura-create-conference-discount)

# Procedury

## procedura create conference
### Kod
``` sql
CREATE PROCEDURE create_conference
    @name             VARCHAR(64),
    @description      VARCHAR(255),
    @start_date       DATETIME2,
    @end_date         DATETIME2,
    @basic_price      SMALLMONEY,
    @student_discount FLOAT,
    @max_attendees    INT
AS
  INSERT INTO conferences VALUES (
    @name,
    @description,
    @start_date,
    @end_date,
    @basic_price,
    @student_discount,
    @max_attendees
  );
  DECLARE @conference_id INT = SCOPE_IDENTITY();
  INSERT INTO conference_days SELECT
                                @conference_id,
                                date
                              FROM dbo.date_range(@start_date, @end_date);
GO
```
### Przykład
*Stwórz trzydniową konferencję z ceną bazową 100zł, bez zniżki studenckiej z liczbą miejsc 200*
```sql
dbo.create_conference 'Foo', 'Bar', '2019-06-16 10:00:00', '2019-06-18 12:00:00', 100, 0, 200
```    

## procedura create conference discount
### Kod
```sql
CREATE PROCEDURE create_conference_discount
    @conference_id INT,
    @due_date      DATETIME2,
    @discount      FLOAT
AS
  IF EXISTS(
      SELECT *
      FROM conference_discounts
      WHERE conference_id = @conference_id AND
            ((due_date < @due_date AND discount >= @discount) OR (due_date > @due_date AND discount <= @discount))
  )
    THROW 50001, 'Conference discount must be higher than earlier discounts.', 0
  IF (@due_date >
      (SELECT start_date
       FROM conferences
       WHERE id = @conference_id))
    THROW 50001, 'Discount due date must be earlier than conference start date.', 0

  INSERT INTO conference_discounts VALUES (@conference_id, @due_date, @discount)
GO
```
### Wyrzucane błędy
Procedura wyrzuci błąd:
- przy próbie zapisu zniżki z datą późniejszą niż data startu konferencji
- przy próbie zapisu zniżki z wartością większą niż wartość innej zniżki z datą późniejszą
- przy próbie zapisu zniżki z wartością mniejszą niż wartość innej zniżki z datą wcześniejszą
### Przykład
```sql
dbo.create_conference_discount 1, '2019-06-15 10:00:00', 0.2
```

