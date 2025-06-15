-- CREATING TABLES FOR DATABASE

-- Authors
CREATE TABLE Authors (
    Author_ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(100) NOT NULL,
    Country VARCHAR(50),
    Birth_Year INT CHECK (Birth_Year >= 1800)
);

-- Categories
CREATE TABLE Categories (
    Category_ID INT PRIMARY KEY IDENTITY,
    Category_Name VARCHAR(100) NOT NULL
);

-- Publishers
CREATE TABLE Publishers (
    Publisher_ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(100) NOT NULL,
    Country VARCHAR(50)
);

-- Books
CREATE TABLE Books (
    Book_ID INT PRIMARY KEY IDENTITY,
    Title VARCHAR(255) NOT NULL,
    Author_ID INT FOREIGN KEY REFERENCES Authors(Author_ID),
    Category_ID INT FOREIGN KEY REFERENCES Categories(Category_ID),
    Publisher_ID INT FOREIGN KEY REFERENCES Publishers(Publisher_ID),
    ISBN VARCHAR(20) UNIQUE,
    Published_Year INT CHECK (Published_Year >= 1800),
    Total_Copies INT CHECK (Total_Copies >= 0),
    Available_Copies INT CHECK (Available_Copies >= 0)
);

-- Members
CREATE TABLE Members (
    Member_ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20) UNIQUE NOT NULL,
    Membership_Start_Date DATE NOT NULL,
    Membership_End_Date DATE NOT NULL
);

-- Borrowing Records
CREATE TABLE Borrowing_Records (
    Borrow_ID INT PRIMARY KEY IDENTITY,
    Member_ID INT FOREIGN KEY REFERENCES Members(Member_ID),
    Book_ID INT FOREIGN KEY REFERENCES Books(Book_ID),
    Borrow_Date DATE NOT NULL,
    Due_Date DATE NOT NULL,
    Return_Date DATE NULL,
    Fine_Amount DECIMAL(5, 2) DEFAULT 0
);

-- Librarians
CREATE TABLE Librarians (
    Librarian_ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20) UNIQUE NOT NULL,
    Hire_Date DATE NOT NULL
);
