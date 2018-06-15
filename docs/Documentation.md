# Spis treści
- [Tabele](#tabele)
    - [conferences](#tabela-conferences)
    - [conference_days](#tabela-conference-days)
- [Funkcje](#funkcje)
    - [date_range](#funkcja-date-range)
- [Widoki](#widoki)
    - [conference_day_max_attendees](#widok-conference-day-max-attendees)
- [Procedury](#procedury)
    - [create_conference](#procedura-create-conference)
    - [create_conference_discount](#procedura-create-conference-discount)
    - [create_workshop](#procedura-create-workshop)
    - [create_workshop_day](#procedura-create-workshop-day)
    - [create_company_customer](#procedura-create-company-customer)
    - [create_individual_customer](#procedura-create-individual-customer)
    - [throw_if_conference_attendees_amount_will_exceed](#procedura-throw-if-conference-attendees-amount-will-exceed)
    - [throw_if_workshop_attendees_amount_will_exceed](#procedura-throw-if-workshop-attendees-amount-will-exceed)
    - [throw_if_reservation_is_paid](#procedura-throw-if-reservation-is-paid)
    - [add_conference_day_reservation](#procedura-add-conference-day-reservation)
    - [add_workshop_day_reservation](#procedura-add-workshop-day-reservation)

# Tabele
## tabela conferences
### Kod
```sql
CREATE TABLE conferences (
  id               INT                   IDENTITY,
  name             VARCHAR(64)  NOT NULL,
  description      VARCHAR(255) NOT NULL,
  start_date       DATETIME2(0) NOT NULL,
  end_date         DATETIME2(0) NOT NULL,
  basic_price      SMALLMONEY   NOT NULL,
  student_discount FLOAT        NOT NULL CONSTRAINT df_conferences_student_discount DEFAULT 0,
  max_attendees    INT          NOT NULL,

  CONSTRAINT pk_conferences PRIMARY KEY (id),
  CONSTRAINT ck_conferences_start_date CHECK (start_date > CURRENT_TIMESTAMP),
  CONSTRAINT ck_conferences_end_date CHECK (end_date > start_date),
  CONSTRAINT ck_conferences_student_discount CHECK (student_discount >= 0 AND student_discount <= 1),
  CONSTRAINT ck_conferences_basic_price CHECK (basic_price > 0),
  CONSTRAINT ck_conferences_max_attendees CHECK (max_attendees > 0),
);
```

## tabela conference days
### Kod
```sql
CREATE TABLE conference_days
(
  id            INT IDENTITY,
  conference_id INT  NOT NULL,
  date          DATE NOT NULL,

  CONSTRAINT pk_conference_days PRIMARY KEY (id),
  CONSTRAINT fk_conference_days_conference FOREIGN KEY (conference_id) REFERENCES conferences,
  CONSTRAINT uq_conference_days_date UNIQUE (conference_id, date)
)
```

# Funkcje
## funkcja date range
### Kod
```sql
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
```
### Opis
Jest to funkcja pomocnicza służąca do wygenerowania zbioru dni pomiędzy dwoma datami.
Wykorzystywana w [procedurze create_conference](#procedura-create-conference) 

# Widoki
## widok conference day max attendees
### Kod
```sql
CREATE VIEW conference_day_max_attendees AS
  SELECT
    cd.id conference_day_id,
    c.max_attendees
  FROM conference_days cd INNER JOIN conferences c on cd.conference_id = c.id;
```
### Opis
Widok pomocniczy, pokazuje wartość max_attendees konferencji dla każdego dnia konferencji.
Używany w [procedurze throw_if_conference_attendees_amount_will_exceed](#procedura-throw-if-conference-attendees-amount-will-exceed)

# Procedury
## procedura create conference
### Kod
```sql
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
### Opis
Procedura poza dodaniem wpisu do [tabeli conferences](#tabela-conferences) generuje także dni
do [tabeli conference_days](#tabela-conference-days) korzystając z [funkcji date_range](#funkcja-date-range)
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
*Stwórz zniżkę 20% obowiązującą do 2019-06-15 10:00:00 dla konferencji o id = 1*
```sql
dbo.create_conference_discount 1, '2019-06-15 10:00:00', 0.2
```

## procedura create workshop
### Kod
```sql
CREATE PROCEDURE create_workshop
    @name          VARCHAR(64),
    @max_attendees INT
AS
  INSERT INTO workshops VALUES (@name, @max_attendees)
GO
```
### Opis
Dodaje warsztat do słownika warsztatów oferowanych przez firmę.
Do tworzenia konkretnego wydarzenia służy [procedura create_workshop_day](#procedura-create-workshop-day). 
### Przykład
```sql
dbo.create_workshop 'Foo', 100;
```

## procedura create workshop day
### Kod
```sql
CREATE PROCEDURE create_workshop_day
    @workshop_id       INT,
    @conference_day_id INT,
    @start_time        TIME,
    @end_time          TIME,
    @price             SMALLMONEY,
    @max_attendees     INT
AS
  IF (SELECT max_attendees
      FROM conference_day_max_attendees
      WHERE conference_day_id = @conference_day_id) < @max_attendees
    THROW 50001, 'Workshop day max_attendees cannot be higher than conference max_attendees.', 0

  INSERT INTO workshop_days VALUES (@workshop_id, @conference_day_id, @start_time, @end_time, @price, @max_attendees)
GO
```
### Wyrzucane błędy
Procedura wyrzuca błąd przy próbie utworzenia warsztatu z liczbą miejsc większą niż
liczba miejsc konferencji, do której warsztat jest przypisywany.

### Przykład
*Stwórz 30-minutowy, darmowy warsztat dla 50 osób*
```sql
dbo.create_workshop_day 1, 1, '11:00:00', '11:30:00', 0, 50;
```

## procedura create company customer
### Kod
```sql
CREATE PROCEDURE create_company_customer
    @phone_number VARCHAR(32),
    @company_name VARCHAR(255),
    @nip          VARCHAR(32)
AS
  BEGIN TRANSACTION

  BEGIN TRY

  INSERT INTO customers VALUES (@phone_number);
  DECLARE @customer_id INT = SCOPE_IDENTITY();
  INSERT INTO companies VALUES (@customer_id, @company_name, @nip);

  COMMIT;
  END TRY

  BEGIN CATCH
  ROLLBACK;
  THROW;
  END CATCH;
GO
```
### Opis
W procedurze znajduje się transakcja aby nie tworzyły się osierocone rekordy w przypadku
awarii systemu lub niespełnienia warunków integralnościowych (częstszy przypadek). 
### Przykład
```sql
dbo.create_company_customer '123', 'ACME', '123';
```

## procedura create individual customer
### Kod
```sql
CREATE PROCEDURE create_individual_customer
    @phone_number VARCHAR(32),
    @first_name   VARCHAR(255),
    @second_name  VARCHAR(255)
AS
  BEGIN TRANSACTION

  BEGIN TRY

  INSERT INTO customers VALUES (@phone_number);
  DECLARE @customer_id INT = SCOPE_IDENTITY();
  INSERT INTO people VALUES (@first_name, @second_name);
  DECLARE @person_id INT = SCOPE_IDENTITY();
  INSERT INTO customer_individual VALUES (@customer_id, @person_id);

  COMMIT;
  END TRY

  BEGIN CATCH
  ROLLBACK;
  THROW;
  END CATCH;
GO
```
### Opis
W procedurze znajduje się transakcja aby nie tworzyły się osierocone rekordy w przypadku
awarii systemu lub niespełnienia warunków integralnościowych (częstszy przypadek).
### Przykład
```sql
dbo.create_individual_customer '1234', 'Jan', 'Kowalski';
```

## procedura throw if conference attendees amount will exceed
### Kod
```sql
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
```
### Opis
Procedura pomocnicza. Wyrzuca błąd jeśl dodanie podanej liczby uczestników spowodowałoby
przekroczenie limitu uczestników dla dnia konferencji. Procedura korzysta z
[widoku conference_day_max_attendees](#widok-conference-day-max-attendees)

## procedura throw if workshop attendees amount will exceed
### Kod
```sql
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
```
### Opis
Procedura pomocnicza. Wyrzuca błąd jeśl dodanie podanej liczby uczestników spowodowałoby
przekroczenie limitu uczestników dla warsztatu.

## procedura throw if reservation is paid
### Kod
```sql
CREATE PROCEDURE throw_if_reservation_is_paid @conference_reservation_id INT AS
  IF (SELECT payment_date
      FROM conference_reservations
      WHERE id = @conference_reservation_id) IS NOT NULL
    THROW 50001, 'Cannot modify reservation which is paid.', 0
GO
```
### Opis
Procedura pomocnicza. Wyrzuca błąd gdy rezerwacja została opłacona.

## procedura add conference day reservation
### Kod
```sql
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
```
### Opis
Dodaje rezerwację na dzień konferencji. Procedura wprowadza typ tabelaryczny dla numerów
legitymacji. Dzięki temu do procedury możemy przekazać kolekcję numerów.
Gdy parametr `@conference_reservation_id` jest null zostanie utworzona rezerwacja,
w przeciwnym wypadku rezerwacja na dany dzień zostanie dodana do podanej rezerwacji.
Gdy parametr `@conference_reservation_id` jest null, należy obowiązkowo podać
`@customer_id`.
### Wyrzucane błędy
Procedura wyrzuci błąd:
- przy próbie zapisu do rezerwacji która została już opłacona
- przy próbie zapisu liczby uczestników przekraczającej limit
- gdy podana zostanie większa liczba numerów legitymacji niż liczba uczestników
### Przykład
```sql
BEGIN
  DECLARE @student_card_numbers StudentCardNumbers;
  INSERT INTO @student_card_numbers VALUES ('123'), ('1234');
  EXEC dbo.add_conference_day_reservation 16, 2, @student_card_numbers, null, 1;
END;
```

## procedura add workshop day reservation
### Kod
```sql
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
```
### Wyrzucane błędy
Procedura wyrzuci błąd:
- przy próbie zapisu do rezerwacji która została opłacona
- gdy podana liczba uczestników jest większa niż zarezerwowana na dzień konferencji
- gdy podana liczba uczestników jest większa niż liczba dostępnych miejsc
- gdy podany dzień warsztatu jest przypisany do innego dnia konferencji niż podana rezerwacja
### Przykład
```sql
dbo.add_workshop_day_reservation 1, 1, 10;
```

