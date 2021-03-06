# System zarządzania konferencjami
Podstawy baz danych - projekt i implementacja systemu bazodanowego

Autorzy:
- Konrad Mikucki
- Dominik Żurek

# Spis treści
- [Tabele](#tabele)
    - [people](#tabela-people)
    - [customers](#tabela-customers)
    - [customer_individual](#tabela-customer-individual)
    - [companies](#tabela-companies)
    - [conferences](#tabela-conferences)
    - [conference_discounts](#tabela-conference-discounts)
    - [conference_days](#tabela-conference-days)
    - [workshops](#tabela-workshops)
    - [workshop_days](#tabela-workshop-days)
    - [conference_reservations](#tabela-conference-reservations)
    - [conference_reservation_details](#tabela-conference-reservation-details)
    - [student_cards](#tabela-student-cards)
    - [conference_attendees](#tabela-conference-attendees)
    - [conference_attendees_students](#tabela-conference-attendees-students)
    - [workshop_reservations](#tabela-workshop-reservations)
    - [workshop_attendees](#tabela-workshop-attendees)
- [Funkcje](#funkcje)
    - [date_range](#funkcja-date-range)
- [Widoki](#widoki)
    - [conference_day_max_attendees](#widok-conference-day-max-attendees)
    - [filled_conference_attendees_count](#widok-filled-conference-attendees-count)
    - [declared_conference_attendees_count](#widok-declared-conference-attendees-count)
    - [not_filled_conference_attendees_count](#widok-not-filled-conference-attendees-count)
    - [should_phone_for_conference_attendees_data](#widok-should-phone-for-conference-attendees-data)
    - [filled_workshop_attendees_count](#widok-filled-workshop-attendees-count)
    - [not_filled_workshop_attendees_count](#widok-not-filled-workshop-attendees-count)
    - [conference_reservations_too_late_for_payment](#widok-conference-reservations-too-late-for-payment)
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
    - [pay_for_reservation](#procedura-pay-for-reservation)
    - [delete_conference_reservations_too_late_for_payment](#procedura-delete-conference-reservations-too-late-for-payment)
    - [add_conference_attendee](#procedura-add-conference-attendee)
    - [add_conference_attendee_student](#procedura-add-conference-attendee-student)
    - [add_workshop_attendee](#procedura-add-workshop-attendee)

# Tabele
## tabela people
### Kod
```sql
CREATE TABLE people (
  id          INT IDENTITY,
  first_name  VARCHAR(255) NOT NULL,
  second_name VARCHAR(255) NOT NULL,

  CONSTRAINT pk_people PRIMARY KEY (id),
);
```

## tabela customers
### Kod
```sql
CREATE TABLE customers (
  id           INT IDENTITY,
  phone_number VARCHAR(32) NOT NULL,

  CONSTRAINT pk_customers PRIMARY KEY (id),
  CONSTRAINT uq_customers_phone_number UNIQUE (phone_number),
);
```

## tabela customer individual
### Kod
```sql
CREATE TABLE customer_individual (
  customer_id INT,
  person_id   INT NOT NULL,

  CONSTRAINT pk_customer_individual PRIMARY KEY (customer_id),
  CONSTRAINT fk_customer_individual_customer FOREIGN KEY (customer_id) REFERENCES customers,
  CONSTRAINT uq_customer_individual_person UNIQUE (person_id),
  CONSTRAINT fk_customer_individual_person FOREIGN KEY (person_id) REFERENCES people,
);
```

## tabela companies
### Kod
```sql
CREATE TABLE companies (
  customer_id INT          NOT NULL,
  name        VARCHAR(255) NOT NULL,
  nip         VARCHAR(32)  NOT NULL,

  CONSTRAINT pk_companies PRIMARY KEY (customer_id),
  CONSTRAINT fk_companies_customer FOREIGN KEY (customer_id) REFERENCES customers,
  CONSTRAINT uq_companies_nip UNIQUE (nip),
);
```
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

## tabela conference discounts
### Kod
```sql
CREATE TABLE conference_discounts
(
  id            INT IDENTITY,
  conference_id INT          NOT NULL,
  due_date      DATETIME2(0) NOT NULL,
  discount      FLOAT        NOT NULL,

  CONSTRAINT pk_conference_discounts PRIMARY KEY (id),
  CONSTRAINT fk_conference_discounts_conference FOREIGN KEY (conference_id) REFERENCES conferences,
  CONSTRAINT ck_conference_discounts_discount CHECK (discount > 0 AND discount <= 1),
  CONSTRAINT ck_conference_discounts_due_date CHECK (due_date > CURRENT_TIMESTAMP),
  CONSTRAINT uq_conference_discounts_due_date UNIQUE (conference_id, due_date)
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

## tabela workshops
### Kod
```sql
CREATE TABLE workshops (
  id            INT IDENTITY,
  name          VARCHAR(64) NOT NULL,
  max_attendees INT         NOT NULL,

  CONSTRAINT pk_workshops PRIMARY KEY (id),
  CONSTRAINT ck_workshops_max_attendees CHECK (max_attendees > 0),
);
```

## tabela workshop days
### Kod
```sql
CREATE TABLE workshop_days (
  id                INT IDENTITY,
  workshop_id       INT        NOT NULL,
  conference_day_id INT        NOT NULL,
  start_time        TIME(0)    NOT NULL,
  end_time          TIME(0)    NOT NULL,
  price             SMALLMONEY NOT NULL,
  max_attendees     INT        NOT NULL,

  CONSTRAINT pk_workshop_days PRIMARY KEY (id),
  CONSTRAINT fk_workshop_days_workshop FOREIGN KEY (workshop_id) REFERENCES workshops,
  CONSTRAINT fk_workshop_days_conference_day FOREIGN KEY (conference_day_id) REFERENCES conference_days,
  CONSTRAINT ck_workshop_days_end_time CHECK (end_time > start_time),
  CONSTRAINT ck_workshop_days_price CHECK (price >= 0),
  CONSTRAINT ck_workshop_days_max_attendees CHECK (max_attendees > 0),
);
```

## tabela conference reservations
### Kod
```sql
CREATE TABLE conference_reservations (
  id               INT                   IDENTITY,
  customer_id      INT          NOT NULL,
  reservation_date DATETIME2(0) NOT NULL CONSTRAINT df_conference_reservations_reservation_date DEFAULT CURRENT_TIMESTAMP,
  payment_date     DATETIME2(0)          CONSTRAINT df_conference_reservations_payment_date DEFAULT NULL,

  CONSTRAINT pk_conference_reservations PRIMARY KEY (id),
  CONSTRAINT fk_conference_reservations_customer FOREIGN KEY (customer_id) REFERENCES customers,
);
```

## tabela conference reservation details
### Kod
```sql
CREATE TABLE conference_reservation_details (
  id                        INT IDENTITY,
  conference_day_id         INT NOT NULL,
  conference_reservation_id INT NOT NULL,
  attendees_amount          INT NOT NULL,

  CONSTRAINT pk_conference_reservation_details PRIMARY KEY (id),
  CONSTRAINT fk_conference_reservation_details_conference_day FOREIGN KEY (conference_day_id) REFERENCES conference_days,
  CONSTRAINT fk_conference_reservation_details_conference_reservation FOREIGN KEY (conference_reservation_id) REFERENCES conference_reservations ON DELETE CASCADE,
  CONSTRAINT uq_conference_reservation_details_conference_day_reservation UNIQUE (conference_day_id, conference_reservation_id),
  CONSTRAINT ck_conference_reservation_details_attendees_amount CHECK (attendees_amount > 0),
);
```

## tabela student cards
### Kod
```sql
CREATE TABLE student_cards (
  id                               INT IDENTITY,
  conference_reservation_detail_id INT         NOT NULL,
  number                           VARCHAR(32) NOT NULL,

  CONSTRAINT pk_student_card PRIMARY KEY (id),
  CONSTRAINT fk_student_card_conference_reservation_detail FOREIGN KEY (conference_reservation_detail_id) REFERENCES conference_reservation_details ON DELETE CASCADE,
  CONSTRAINT uq_student_card_number UNIQUE (conference_reservation_detail_id, number),
);
```

## tabela conference attendees
### Kod
```sql
CREATE TABLE conference_attendees (
  id                               INT IDENTITY,
  person_id                        INT NOT NULL,
  conference_reservation_detail_id INT NOT NULL,

  CONSTRAINT pk_conference_attendees PRIMARY KEY (id),
  CONSTRAINT fk_conference_attendees_person FOREIGN KEY (person_id) REFERENCES people,
  CONSTRAINT fk_conference_attendees_conference_reservation_detail FOREIGN KEY (conference_reservation_detail_id) REFERENCES conference_reservation_details ON DELETE CASCADE,
  CONSTRAINT uq_conference_attendees_person_reservation_detail UNIQUE (person_id, conference_reservation_detail_id)
);
```

## tabela conference attendees students
### Kod
```sql
CREATE TABLE conference_attendees_students (
  conference_attendee_id INT NOT NULL,
  student_card_id        INT NOT NULL,

  CONSTRAINT pk_conference_attendees_student PRIMARY KEY (conference_attendee_id),
  CONSTRAINT uq_conference_attendees_students_conference_attendee UNIQUE (conference_attendee_id),
  CONSTRAINT uq_conference_attendees_students_student_card_id UNIQUE (student_card_id),
  CONSTRAINT fk_conference_attendees_student_conference_attendee FOREIGN KEY (conference_attendee_id) REFERENCES conference_attendees ON DELETE CASCADE,
  CONSTRAINT fk_conference_attendees_student_student_card FOREIGN KEY (student_card_id) REFERENCES student_cards,
);
```

## tabela workshop reservations
### Kod
```sql
CREATE TABLE workshop_reservations (
  id                               INT IDENTITY,
  conference_reservation_detail_id INT NOT NULL,
  workshop_day_id                  INT NOT NULL,
  attendees_amount                 INT NOT NULL,

  CONSTRAINT pk_workshop_reservations PRIMARY KEY (id),
  CONSTRAINT fk_workshop_reservations_conference_reservation_detail FOREIGN KEY (conference_reservation_detail_id) REFERENCES conference_reservation_details ON DELETE CASCADE,
  CONSTRAINT fk_workshop_reservations_workshop_day FOREIGN KEY (workshop_day_id) REFERENCES workshop_days,
  CONSTRAINT ck_workshop_reservations_attendees_amount CHECK (attendees_amount > 0),
  CONSTRAINT uq_workshop_reservations_conference_reservation_workshop_day UNIQUE (conference_reservation_detail_id, workshop_day_id),
);
```

## tabela workshop attendees
### Kod
```sql
CREATE TABLE workshop_attendees (
  id                      INT IDENTITY,
  conference_attendee_id  INT NOT NULL,
  workshop_reservation_id INT NOT NULL,

  CONSTRAINT pk_workshop_attendees PRIMARY KEY (id),
  CONSTRAINT fk_workshop_attendees_conference_attendee FOREIGN KEY (conference_attendee_id) REFERENCES conference_attendees ON DELETE CASCADE,
  CONSTRAINT fk_workshop_attendees_workshop_reservation FOREIGN KEY (workshop_reservation_id) REFERENCES workshop_reservations,
);
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

## widok filled conference attendees count
### Kod
```sql
CREATE VIEW filled_conference_attendees_count AS
  SELECT
    crd.id                     AS conference_reservation_detail_id,
    COUNT(ca.id)               AS student_and_non_student_count,
    COUNT(cas.student_card_id) AS student_count
  FROM conference_reservation_details crd
    LEFT JOIN conference_attendees ca ON crd.id = ca.conference_reservation_detail_id
    LEFT JOIN conference_attendees_students cas on ca.id = cas.conference_attendee_id
  GROUP BY crd.id;
```
### Opis
Widok przedstawia dla ilu uczestników (z podziałem na studentów i wszystkich) danej pozycji rezerwacji podano już dane.

## widok declared conference attendees count
```sql
CREATE VIEW declared_conference_attendees_count AS
  SELECT
    crd.id               AS conference_reservation_detail_id,
    crd.attendees_amount AS student_and_non_student_count,
    COUNT(sc.id)         AS student_count
  FROM conference_reservation_details crd LEFT JOIN student_cards sc on crd.id = sc.conference_reservation_detail_id
  GROUP BY crd.id, crd.attendees_amount;
```
### Opis
Widok przedstawia jaką liczbę uczestników (z podziałem na studentów i wszystkich) zdeklarowano dla danej pozycji rezerwacji.

## widok not filled conference attendees count
### Kod
```sql
CREATE VIEW not_filled_conference_attendees_count AS
  SELECT
    dcac.conference_reservation_detail_id,
    (dcac.student_and_non_student_count - fcac.student_and_non_student_count) AS student_and_non_student_count,
    (dcac.student_count -
     fcac.student_count)                                                      AS student_count,
    (dcac.student_and_non_student_count - fcac.student_and_non_student_count - dcac.student_count +
     fcac.student_count)                                                      AS non_student_count
  FROM declared_conference_attendees_count dcac
    INNER JOIN filled_conference_attendees_count fcac
      ON dcac.conference_reservation_detail_id = fcac.conference_reservation_detail_id;
```
### Opis
Widok przedstawia dla ilu uczestników danej pozycji rezerwacji należy jeszcze wprowadzić dane.

## widok should phone for conference attendees data
### Kod
```sql
CREATE VIEW should_phone_for_conference_attendees_data AS
  SELECT
    c.phone_number,
    c2.start_date AS conference_start_date,
    nfcac.conference_reservation_detail_id,
    nfcac.student_and_non_student_count,
    nfcac.student_count,
    nfcac.non_student_count
  FROM not_filled_conference_attendees_count nfcac
    INNER JOIN conference_reservation_details crd
      ON crd.id = nfcac.conference_reservation_detail_id
    INNER JOIN conference_reservations cr
      on crd.conference_reservation_id = cr.id
    INNER JOIN customers c on cr.customer_id = c.id
    INNER JOIN conference_days cd ON crd.conference_day_id = cd.id
    INNER JOIN conferences c2 on cd.conference_id = c2.id
  WHERE c2.start_date > CURRENT_TIMESTAMP AND
        c2.start_date < DATEADD(WEEK, 2, CURRENT_TIMESTAMP)
        AND student_and_non_student_count > 0;
```
### Opis
Widok przedstawia do kogo należy zadzwonić, w celu wprowadzenia danych uczestników.

## widok filled workshop attendees count
### Kod
```sql
CREATE VIEW filled_workshop_attendees_count AS
  SELECT
    wr.id                             AS workshop_reservation_id,
    COUNT(wa.workshop_reservation_id) AS attendees_count
  FROM workshop_reservations wr
    LEFT JOIN workshop_attendees wa on wr.id = wa.workshop_reservation_id
  GROUP BY wr.id;
```
### Opis
Widok pełni analogiczną funkcję do [widoku filled_conference_attendees_count](#widok-filled-conference-attendees-count)

## widok not filled workshop attendees count
### Kod
```sql
CREATE VIEW not_filled_workshop_attendees_count AS
  SELECT
    wr.id                                        AS workshop_reservation_id,
    (wr.attendees_amount - fwac.attendees_count) AS attendees_count
  FROM workshop_reservations wr INNER JOIN filled_workshop_attendees_count fwac ON wr.id = fwac.workshop_reservation_id
```
### Opis
Widok pełni analogiczną funkcje do [widoku not_filled_conference_attendees_count](#widok-not-filled-conference-attendees-count)

## widok conference reservations too late for payment
### Kod
```sql
CREATE VIEW conference_reservations_too_late_for_payment AS
  SELECT *
  FROM conference_reservations
  WHERE DATEADD(WEEK, 1, reservation_date) < CURRENT_TIMESTAMP AND payment_date IS NULL
```
### Opis
Widok przedstawia rezerwacje, które należy usunąć z powodu braku opłaty.

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
## procedura pay for reservation
### Kod
```sql
CREATE PROCEDURE pay_for_reservation
    @conference_reservation_id INT
AS
  UPDATE conference_reservations
  SET payment_date = CURRENT_TIMESTAMP
  WHERE id = @conference_reservation_id
GO
```
### Opis
Dodaje aktualną datę jako data płatności.

## procedura delete conference reservations too late for payment
### Kod
```sql
CREATE PROCEDURE delete_conference_reservations_too_late_for_payment AS
  DELETE FROM conference_reservations
  WHERE id IN (SELECT id
               FROM conference_reservations_too_late_for_payment);
GO
```
### Opis
Usuwa rezerwacje nieopłacone dłużej niż tydzień.

## procedura add conference attendee
### Kod
```sql
CREATE PROCEDURE add_conference_attendee
    @conference_reservation_detail_id INT,
    @first_name                       VARCHAR(255),
    @second_name                      VARCHAR(255)
AS
  IF (SELECT non_student_count
      FROM not_filled_conference_attendees_count
      WHERE conference_reservation_detail_id = @conference_reservation_detail_id) = 0
    THROW 50001, 'All non student attendees data was provided for this reservation.', 0;
  BEGIN TRANSACTION

  BEGIN TRY

  INSERT INTO people VALUES (@first_name, @second_name);
  DECLARE @person_id INT = SCOPE_IDENTITY();
  INSERT INTO conference_attendees VALUES (@person_id, @conference_reservation_detail_id);

  COMMIT;
  END TRY

  BEGIN CATCH
  ROLLBACK;
  THROW;
  END CATCH;
GO
```
### Wyrzucane błędy
Procedura wyrzuci błąd gdy suma podanych uczestników (nie studentów) będzie większa niż
liczba podana w rezerwacji.

## procedura add conference attendee student
### Kod
```sql
CREATE PROCEDURE add_conference_attendee_student
    @conference_reservation_detail_id INT,
    @first_name                       VARCHAR(255),
    @second_name                      VARCHAR(255),
    @student_card_id                  INT
AS
  IF (SELECT student_count
      FROM not_filled_conference_attendees_count
      WHERE conference_reservation_detail_id = @conference_reservation_detail_id) = 0
    THROW 50001, 'All student attendees data was provided for this reservation.', 0;
  IF (SELECT conference_reservation_detail_id
      FROM student_cards
      WHERE id = @student_card_id) != @conference_reservation_detail_id
    THROW 50001, 'Attendee conference reservation detail must be the same as in student card.', 0;

  BEGIN TRANSACTION

  BEGIN TRY
  INSERT INTO people VALUES (@first_name, @second_name);
  DECLARE @person_id INT = SCOPE_IDENTITY();
  INSERT INTO conference_attendees VALUES (@person_id, @conference_reservation_detail_id);
  DECLARE @conference_attendee_id INT = SCOPE_IDENTITY();
  INSERT INTO conference_attendees_students VALUES (@conference_attendee_id, @student_card_id);
  COMMIT;
  END TRY

  BEGIN CATCH
  ROLLBACK;
  THROW;
  END CATCH;
GO
```
### Wyrzucane błędy
Procedura wyrzuci błąd:
- gdy suma podanych uczestników (studentów) będzie większa niż liczba
legitymacji podanych w rezerwacji
- gdy zostanie wprowadzona legitymacja podana w innej rezerwacji

## procedura add workshop attendee
### Kod
```sql
CREATE PROCEDURE add_workshop_attendee
    @conference_attendee_id  INT,
    @workshop_reservation_id INT
AS
  IF (SELECT attendees_count
      FROM not_filled_workshop_attendees_count
      WHERE workshop_reservation_id = @workshop_reservation_id) = 0
    THROW 50001, 'All attendees data was provided for this workshop reservation.', 0;
  IF (SELECT conference_reservation_detail_id
      FROM workshop_reservations
      WHERE id = @workshop_reservation_id) != (SELECT conference_reservation_detail_id
                                               FROM conference_attendees
                                               WHERE id = @conference_attendee_id)
    THROW 50001, 'Workshop reservation must have the same conference reservation detail as conference attendee.', 0;

  INSERT INTO workshop_attendees VALUES (@conference_attendee_id, @workshop_reservation_id);
GO
```
### Wyrzucane błędy
Procedura wyrzuci błąd:
- przy próbie doania uczestnika, gdy wszyscy już zostali zdefiniowani
- gdy podany uczestnik konferencji dotyczy innej pozycji rezerwacji niż podana rezerwacja warsztatu

