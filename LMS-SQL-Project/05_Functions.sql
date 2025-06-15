-- CREATING SCALAR FUNCTIONS

CREATE FUNCTION fn_CountBooksInCategory (@CatID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Total INT
    SELECT @Total = COUNT(*)
    FROM Books
    WHERE Category_ID = @CatID
    RETURN @Total
END



CREATE FUNCTION fn_TotalBooks()
RETURNS INT
AS
BEGIN
    DECLARE @Total INT
    SELECT @Total = COUNT(*)
    FROM Books
    RETURN @Total
END



CREATE FUNCTION fn_TotalMembers()
RETURNS INT
AS
BEGIN
    DECLARE @Count INT
    SELECT @Count = COUNT(*)
    FROM Members
    RETURN @Count
END



CREATE FUNCTION fn_TotalPublishers()
RETURNS INT
AS
BEGIN
    DECLARE @Total INT
    SELECT @Total = COUNT(*)
    FROM Publishers
    RETURN @Total
END



CREATE FUNCTION fn_AuthorNameByID (@AuthorID INT)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @Name VARCHAR(100)
    SELECT @Name = Name
    FROM Authors
    WHERE Author_ID = @AuthorID
    RETURN @Name
END



CREATE FUNCTION fn_BookTitleByID (@BookID INT)
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @Title VARCHAR(255)
    SELECT @Title = Title
    FROM Books
    WHERE Book_ID = @BookID
    RETURN @Title
END



CREATE FUNCTION fn_CountBooksByAuthor(@AuthorID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*)
    FROM Books
    WHERE Author_ID = @AuthorID;
    RETURN @Count;
END;



CREATE FUNCTION fn_MemberName(@MemberID INT)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @Name VARCHAR(100);
    SELECT @Name = Name
    FROM Members
    WHERE Member_ID = @MemberID;
    RETURN @Name;
END;



CREATE FUNCTION fn_IsBookAvailable(@BookID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Available BIT;
    IF EXISTS (SELECT 1
    FROM Books
    WHERE Book_ID = @BookID AND Available_Copies > 0)
        SET @Available = 1;
    ELSE
        SET @Available = 0;
    RETURN @Available;
END;



CREATE FUNCTION fn_GetMemberFines
(
    @MemberID INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Fine DECIMAL(10,2);

    SELECT @Fine = ISNULL(SUM(
        CASE
            WHEN Return_Date > Due_Date THEN DATEDIFF(DAY, Due_Date, Return_Date) * 50
            ELSE 0
        END
    ), 0)
    FROM Borrowing_Records
    WHERE Member_ID = @MemberID;

    RETURN @Fine;
END;



-- CREATING TABLE VALUED FUNCTIONS

CREATE FUNCTION fn_SearchBookByTitle(@title VARCHAR(100))
RETURNS @RESULT TABLE(
    [Book Title] VARCHAR(100)
)
AS
BEGIN
    INSERT INTO @RESULT
    SELECT Title
    FROM Books
    WHERE LOWER(Title) LIKE '%' + LOWER(@title) + '%'
    RETURN
END;



CREATE FUNCTION fn_GetTopBooks ()
RETURNS @RESULT TABLE(
    [Book Title] VARCHAR(100),
    [Borrowed Count] INT
)
AS
BEGIN
    INSERT INTO @RESULT
    SELECT TOP(3)
        B.Title, COUNT(BR.Book_ID) AS [MOST_BORROWED]
    FROM Borrowing_Records BR
        JOIN Books B
        ON B.Book_ID = BR.Book_ID
    GROUP BY B.Title
    ORDER BY COUNT(BR.Book_ID) DESC

    RETURN
END;



-- Test scalar functions
SELECT dbo.fn_CountBooksInCategory(5) AS BooksInCategory;

SELECT dbo.fn_TotalBooks() AS TotalBooksCount;

SELECT dbo.fn_TotalMembers() AS TotalMembersCount;

SELECT dbo.fn_TotalPublishers() AS TotalPublishersCount;

SELECT dbo.fn_AuthorNameByID(10) AS AuthorName;

SELECT dbo.fn_BookTitleByID(1) AS BookTitle;

SELECT dbo.fn_CountBooksByAuthor(1) AS AuthorBookCount;

SELECT dbo.fn_MemberName(1) AS MemberName;

SELECT dbo.fn_IsBookAvailable(1) AS IsAvailable;

SELECT dbo.fn_GetMemberFines(1) AS TotalFines;

-- Test table-valued functions
SELECT *
FROM dbo.fn_SearchBookByTitle('Harry');

SELECT *
FROM dbo.fn_GetTopBooks();
