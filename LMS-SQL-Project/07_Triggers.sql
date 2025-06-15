-- CREATING TRIGGERS

CREATE TRIGGER trg_PreventDeleteMemberWithBorrow
ON Members
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Borrowing_Records BR
        JOIN deleted d ON d.Member_ID = BR.Member_ID
        WHERE BR.Return_Date IS NULL
    )
    BEGIN
        RAISERROR('Cannot delete member with borrowed books.', 16, 1)
        ROLLBACK
    END
    ELSE
    BEGIN
        DELETE FROM Members WHERE Member_ID IN (SELECT Member_ID FROM deleted)
    END
END



CREATE TRIGGER trg_CheckBookCopies
ON Books
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted WHERE Available_Copies > Total_Copies
    )
    BEGIN
        RAISERROR('Available copies cannot exceed total copies.', 16, 1)
        ROLLBACK
    END
END



CREATE TRIGGER trg_DecreaseAvailableCopies 
ON Borrowing_Records
AFTER INSERT
AS 
BEGIN
	UPDATE Books
	SET Available_Copies = Available_Copies - 1
	WHERE Book_ID IN (SELECT Book_ID FROM inserted) AND
	Available_Copies >=0;

	IF EXISTS (SELECT 1 FROM Books WHERE Book_ID IN (SELECT Book_ID FROM inserted) AND Available_Copies <= 0)
    BEGIN
        PRINT 'NO COPIES AVAILABLE FOR SOME BOOKS!';
    END
END;



CREATE TRIGGER trg_IncreaseAvailableCopies
ON Borrowing_Records
AFTER UPDATE
AS
BEGIN
	UPDATE Books
	SET Available_Copies = Available_Copies + 1
	WHERE Book_ID IN (SELECT Book_ID FROM INSERTED);
END;



CREATE TRIGGER trg_UpdateFineOnReturnUpdate
ON Borrowing_Records
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Return_Date)
    BEGIN
        UPDATE BR
        SET Fine_Amount = 
            CASE
                WHEN I.Return_Date > I.Due_Date THEN DATEDIFF(DAY, I.Due_Date, I.Return_Date) * 50
                ELSE 0
            END
        FROM Borrowing_Records BR
        INNER JOIN inserted I ON BR.Borrow_ID = I.Borrow_ID;
    END
END;



CREATE TRIGGER trg_DeletedBorrowingRecordsLog
ON Borrowing_Records
AFTER DELETE
AS
BEGIN
    INSERT INTO BorrowingDeletionLog
    (Borrow_ID, Member_ID, Book_ID, Borrow_Date, Due_Date, Return_Date, Fine_Amount)
    SELECT 
        Borrow_ID,
        Member_ID,
        Book_ID,
        Borrow_Date,
        Due_Date,
        Return_Date,
        Fine_Amount
    FROM deleted;
END;



CREATE TRIGGER trg_LogUpdatedBorrowingRecords
ON Borrowing_Records
AFTER UPDATE
AS
BEGIN
    INSERT INTO BorrowingUpdateLog
    (Borrow_ID, Member_ID, Book_ID, 
     Old_Borrow_Date, New_Borrow_Date, 
     Old_Due_Date, New_Due_Date, 
     Old_Return_Date, New_Return_Date, 
     Old_Fine_Amount, New_Fine_Amount)
    SELECT
        I.Borrow_ID,
        I.Member_ID,
        I.Book_ID,
        D.Borrow_Date, I.Borrow_Date,
        D.Due_Date, I.Due_Date,
        D.Return_Date, I.Return_Date,
        D.Fine_Amount, I.Fine_Amount
    FROM inserted I
    INNER JOIN deleted D ON I.Borrow_ID = D.Borrow_ID;
END;



CREATE TRIGGER trg_PreventDuplicateEmail
ON Members
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Members M
        JOIN inserted i ON M.Email = i.Email
    )
    BEGIN
        RAISERROR('Email already exists. Cannot insert duplicate member.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Members (Name, Email, Phone, Membership_Start_Date, Membership_End_Date)
        SELECT Name, Email, Phone, Membership_Start_Date, Membership_End_Date
        FROM inserted;
    END
END;

