-- CREATING STORED PROCEDURES

CREATE PROCEDURE sp_TotalBorrowedBooks
AS
BEGIN
    SELECT COUNT(*) AS Borrowed_Books
    FROM Borrowing_Records
    WHERE Return_Date IS NULL
END

EXEC sp_TotalBorrowedBooks;



CREATE PROCEDURE sp_ShowAllBooks
AS
BEGIN
    SELECT *
    FROM Books
END

EXEC sp_ShowAllBooks;



CREATE PROCEDURE sp_ShowAllMembers
AS
BEGIN
    SELECT *
    FROM Members
END

EXEC sp_ShowAllMembers;



CREATE PROCEDURE sp_AddAuthor
    @Name VARCHAR(100),
    @Country VARCHAR(50),
    @BirthYear INT
AS
BEGIN
    INSERT INTO Authors
        (Name, Country, Birth_Year)
    VALUES
        (@Name, @Country, @BirthYear)
END



CREATE PROCEDURE sp_BorrowBook
    @MemberID INT,
    @BookID INT,
    @BorrowDate DATE,
    @DueDate DATE
AS
BEGIN
    INSERT INTO Borrowing_Records
        (Member_ID, Book_ID, Borrow_Date, Due_Date)
    VALUES
        (@MemberID, @BookID, @BorrowDate, @DueDate)
END

EXEC sp_BorrowBook 5,18,'2025-01-01','2025-05-01';



CREATE PROCEDURE sp_UpdateMemberEmail
    @MemberID INT,
    @NewEmail VARCHAR(100)
AS
BEGIN
    UPDATE Members 
	SET Email = @NewEmail
    WHERE Member_ID = @MemberID
END

EXEC Update_Member_Email 5,'ethan.hunt@gmail.com';



CREATE PROCEDURE sp_BookiInfoById
    @ID INT
AS
BEGIN
    SELECT B.Title, A.Name, C.Category_Name, B.Published_Year, P.Name
    FROM Authors A
        INNER JOIN Books B
        ON A.Author_ID = B.Author_ID
        INNER JOIN Categories C
        ON C.Category_ID = B.Category_ID
        INNER JOIN Publishers P
        ON P.Publisher_ID = B.Publisher_ID
    WHERE B.Book_ID = @ID;

END;

EXEC sp_BookiInfoById 2;



CREATE PROCEDURE sp_MemberById
    @ID INT
AS
BEGIN
    SELECT *
    FROM Members
    WHERE Member_ID = @ID
END;


EXEC sp_MemberById 5;



CREATE PROCEDURE sp_BooksBorrowedByMember
    @Id INT
AS
BEGIN

    SELECT B.Title, B.Author_ID, BR.Borrow_Date, BR.Due_Date
    FROM Borrowing_Records BR
        JOIN Books B ON BR.Book_ID = B.Book_ID
    WHERE BR.Member_ID = @Id;

END;

Exec sp_BooksBorrowedByMember 20;



CREATE PROCEDURE sp_BorrowedCountById
    @Id INT
AS
BEGIN
    SELECT M.Name, M.Member_ID, COUNT(*) AS 'BORROWED_COUNT'
    FROM Borrowing_Records BR
        INNER JOIN Members M
        ON BR.Member_ID = M.Member_ID
    WHERE M.Member_ID = @Id
    GROUP BY M.Member_ID,M.Name

END;

EXEC sp_BorrowedCountById 20;



CREATE PROCEDURE sp_BooksByCategory
    @CategoryName VARCHAR(100)
AS
BEGIN
    SELECT B.Title, A.Name AS Author, B.ISBN, B.Published_Year
    FROM Books B
        JOIN Categories C ON B.Category_ID = C.Category_ID
        JOIN Authors A ON B.Author_ID = A.Author_ID
    WHERE C.Category_Name = @CategoryName;
END;

EXEC sp_BooksByCategory 'FANTASY';



CREATE PROCEDURE sp_ReturnBookByBorrowId
    @Br_Id INT
AS
BEGIN
    UPDATE Borrowing_Records
	SET Return_Date = GETDATE()
	WHERE Borrow_ID = @Br_Id;

    PRINT 'Book Returned Successfully';

END;



CREATE PROCEDURE sp_AddMember
    @Name VARCHAR(100),
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    INSERT INTO Members
        (Name, Email, Phone, Membership_Start_Date, Membership_End_Date)
    VALUES
        (@Name, @Email, @Phone, @StartDate, @EndDate);
END;



CREATE PROCEDURE sp_CalculateFine
    @borrow_id INT
AS
BEGIN
    DECLARE @due_date DATE;
    DECLARE @return_date DATE;
    DECLARE @fine DECIMAL(10, 2);

    SELECT @due_date = Due_Date, @return_date = Return_Date
    FROM Borrowing_Records
    WHERE Borrow_ID = @borrow_id;

    IF @due_date IS NULL
    BEGIN
        PRINT 'No record found for the given Borrow_ID.';
        RETURN;
    END

    IF @return_date IS NOT NULL AND @return_date > @due_date
    BEGIN
        SET @fine = DATEDIFF(DAY, @due_date, @return_date) * 50;
        UPDATE Borrowing_Records
        SET Fine_Amount = @fine
        WHERE Borrow_ID = @borrow_id;

        PRINT 'Fine calculated and updated: ' + CAST(@fine AS VARCHAR(10)) + ' for Borrow_ID: ' + CAST(@borrow_id AS VARCHAR(10));
    END
    ELSE
    BEGIN
        UPDATE Borrowing_Records
        SET Fine_Amount = 0
        WHERE Borrow_ID = @borrow_id;

        PRINT 'No fine applied. Book returned on time or not returned for Borrow_ID: ' + CAST(@borrow_id AS VARCHAR(10));
    END
END;


EXEC sp_CalculateFine 12;


