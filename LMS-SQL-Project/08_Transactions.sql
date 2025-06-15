-- CREATING TRANSACTION 

BEGIN TRANSACTION;

BEGIN TRY
    INSERT INTO Borrowing_Records (Member_ID, Book_ID, Borrow_Date, Due_Date)
    VALUES (1, 2, GETDATE(), DATEADD(DAY, 14, GETDATE()));

    UPDATE Books
    SET Available_Copies = Available_Copies - 1
    WHERE Book_ID = 2 AND Available_Copies > 0;

    COMMIT TRANSACTION;
    PRINT 'Book borrowed successfully!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error during borrowing. Rolled back.';
END CATCH;




BEGIN TRANSACTION;

INSERT INTO Borrowing_Records (Member_ID, Book_ID, Borrow_Date, Due_Date)
VALUES (1, 3, GETDATE(), DATEADD(DAY, 14, GETDATE()));

UPDATE Books
SET Available_Copies = Available_Copies - 1
WHERE Book_ID = 3;

IF @@ERROR <> 0
    ROLLBACK;
ELSE
    COMMIT;



BEGIN TRANSACTION;

UPDATE Borrowing_Records
SET Return_Date = GETDATE()
WHERE Borrow_ID = 5;

DECLARE @Due DATE, @Fine DECIMAL(5,2)
SELECT @Due = Due_Date FROM Borrowing_Records WHERE Borrow_ID = 5

IF @Due < GETDATE()
BEGIN
    SET @Fine = DATEDIFF(DAY, @Due, GETDATE()) * 10
    UPDATE Borrowing_Records
    SET Fine_Amount = @Fine
    WHERE Borrow_ID = 5
END

UPDATE Books
SET Available_Copies = Available_Copies + 1
WHERE Book_ID = (SELECT Book_ID FROM Borrowing_Records WHERE Borrow_ID = 5)

IF @@ERROR <> 0
    ROLLBACK;
ELSE
    COMMIT;

