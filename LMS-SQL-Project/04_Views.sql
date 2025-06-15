-- CREATING SIMPLE VIEWS - (WITHOUT JOINS) 

CREATE VIEW vw_MemberContact
AS
    SELECT
        Member_ID,
        Name AS [Member Name],
        Email,
        Phone
    FROM Members;

SELECT *
FROM vw_MemberContact;

CREATE VIEW vw_PublisherList
AS
    SELECT
        Publisher_ID,
        Name,
        Country
    FROM Publishers;

SELECT *
FROM vw_PublisherList;


CREATE VIEW vw_FinesOnly
AS
    SELECT
        Borrow_ID,
        Fine_Amount
    FROM Borrowing_Records
    WHERE Fine_Amount > 0;

SELECT *
FROM vw_FinesOnly;



-- CREATING COMPLEX VIEWS - (WITH JOINS)

CREATE VIEW vw_MemberBorrowCount
AS
    SELECT
        M.Member_ID,
        M.Name,
        COUNT(BR.Borrow_ID) AS Total_Borrows
    FROM Members M
        LEFT JOIN Borrowing_Records BR ON M.Member_ID = BR.Member_ID
    GROUP BY M.Member_ID, M.Name;

SELECT *
FROM vw_MemberBorrowCount;

CREATE VIEW vw_BookDetails
AS
    SELECT
        B.Book_ID,
        B.Title,
        A.Name AS Author,
        C.Category_Name,
        B.Published_Year
    FROM Books B
        JOIN Authors A ON B.Author_ID = A.Author_ID
        JOIN Categories C ON B.Category_ID = C.Category_ID;

SELECT *
FROM vw_BookDetails;


CREATE VIEW vw_OverdueBooks
AS
    SELECT BR.Borrow_ID, M.Name, B.Title, BR.Due_Date, BR.Return_Date, BR.Fine_Amount
    FROM Borrowing_Records BR
        JOIN Members M ON BR.Member_ID = M.Member_ID
        JOIN Books B ON BR.Book_ID = B.Book_ID
    WHERE BR.Return_Date IS NULL AND BR.Due_Date < GETDATE();

SELECT *
FROM vw_OverdueBooks;


CREATE VIEW vw_AvailableBooks
AS
    SELECT B.Book_ID, B.Title, A.Name AS AuthorName, C.Category_Name, P.Name AS PublisherName, B.Available_Copies
    FROM Books B
        INNER JOIN Authors A ON B.Author_ID = A.Author_ID
        INNER JOIN Categories C ON B.Category_ID = C.Category_ID
        INNER JOIN Publishers P ON B.Publisher_ID = P.Publisher_ID
    WHERE B.Available_Copies > 0;


SELECT *
FROM vw_AvailableBooks;

CREATE VIEW vw_BorrowingHistory
AS
    SELECT
        BR.Borrow_ID, M.Name AS MemberName,
        B.Title AS BookTitle,
        BR.Borrow_Date,
        BR.Due_Date,
        BR.Return_Date,
        BR.Fine_Amount
    FROM Borrowing_Records BR
        INNER JOIN Members M ON BR.Member_ID = M.Member_ID
        INNER JOIN Books B ON BR.Book_ID = B.Book_ID;


SELECT *
FROM vw_BorrowingHistory;



