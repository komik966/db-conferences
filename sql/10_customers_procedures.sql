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