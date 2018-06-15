# Spis treści
- [Tabele](#tabele)
    - [conferences](#tabela-conferences)
    - [conference_days](#tabela-conference-days)
- [Funkcje](#funkcje)
    - [date_range](#funkcja-date-range)
- [Procedury](#procedury)
    - [create_conference](#procedura-create-conference)
    - [create_conference_discount](#procedura-create-conference-discount)
    - [create_workshop](#procedura-create-workshop)
    - [create_workshop_day](#procedura-create-workshop-day)
    - [create_company_customer](#procedura-create-company-customer)
    - [create_individual_customer](#procedura-create-individual-customer)

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
### Przykład
```sql
dbo.create_individual_customer '1234', 'Jan', 'Kowalski';
```
