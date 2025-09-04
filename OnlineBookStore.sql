-- Create Database
CREATE DATABASE OnlineBooks;

\c OnlineBooks;

-- Create Tables
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);
DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);
DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;


-- Import Data into Books Table
COPY Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock) 
FROM 'D:\pbi program files\bapa\books\Books.csv' 
CSV HEADER;

-- Import Data into Customers Table
COPY Customers(Customer_ID, Name, Email, Phone, City, Country) 
FROM 'D:\pbi program files\bapa\books\Customers.csv' 
CSV HEADER;

-- Import Data into Orders Table
COPY Orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount) 
FROM 'D:\pbi program files\bapa\books\Orders.csv' 
CSV HEADER;

-- ======================
-- 📌 BASIC LOOKUPS
-- ======================

-- 1) Retrieve all books in the Fiction genre
SELECT * FROM Books 
WHERE Genre = 'Fiction';

-- 2) Find books published after 1950
SELECT * FROM Books 
WHERE Published_Year > 1950;

-- 3) List all customers from Canada
SELECT * FROM Customers 
WHERE Country = 'Canada';

-- 4) Show orders placed in November 2023
SELECT * FROM Orders 
WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5) Retrieve the total stock of books available
SELECT SUM(Stock) AS Total_Stock
FROM Books;

-- 6) Find the most expensive book
SELECT * FROM Books 
ORDER BY Price DESC 
LIMIT 1;

-- 7) Find the book with the lowest stock
SELECT * FROM Books 
ORDER BY Stock ASC 
LIMIT 1;

-- 8) List all genres available
SELECT DISTINCT Genre 
FROM Books;


-- ======================
-- 📌 SALES & ORDERS
-- ======================

-- 9) Orders where quantity > 1
SELECT * FROM Orders 
WHERE Quantity > 1;

-- 10) Orders where total amount > $20
SELECT * FROM Orders 
WHERE Total_Amount > 20;

-- 11) Total revenue from all orders
SELECT SUM(Total_Amount) AS Revenue 
FROM Orders;

-- 12) Total revenue + total number of orders
SELECT 
    SUM(Total_Amount) AS Total_Revenue,
    COUNT(Order_ID) AS Total_Orders
FROM Orders;


-- ======================
-- 📌 BOOK PERFORMANCE
-- ======================

-- 13) Total books sold per genre
SELECT b.Genre, SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Genre;

-- 14) Average price of Fantasy books
SELECT AVG(Price) AS Avg_Price
FROM Books
WHERE Genre = 'Fantasy';

-- 15) Top 3 most expensive Fantasy books
SELECT * FROM Books
WHERE Genre = 'Fantasy'
ORDER BY Price DESC 
LIMIT 3;

-- 16) Most frequently ordered book
SELECT o.Book_ID, b.Title, COUNT(o.Order_ID) AS Order_Count
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY o.Book_ID, b.Title
ORDER BY Order_Count DESC 
LIMIT 1;

-- 17) Most profitable book (by revenue)
SELECT b.Book_ID, b.Title, SUM(o.Total_Amount) AS Revenue
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Book_ID, b.Title
ORDER BY Revenue DESC 
LIMIT 1;

-- 18) Books never ordered (zero-sales report)
SELECT b.Book_ID, b.Title, b.Genre, b.Stock
FROM Books b
LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
WHERE o.Book_ID IS NULL;

-- 19) Total quantity sold per author
SELECT b.Author, SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Author
ORDER BY Total_Books_Sold DESC;

-- 20) Top 5 authors by revenue
SELECT b.Author, SUM(o.Total_Amount) AS Revenue
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Author
ORDER BY Revenue DESC 
LIMIT 5;

-- 21) Revenue contribution by genre
SELECT b.Genre, SUM(o.Total_Amount) AS Revenue
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Genre
ORDER BY Revenue DESC;

-- 22) Revenue by price range
SELECT CASE
         WHEN Price < 20 THEN 'Low'
         WHEN Price BETWEEN 20 AND 50 THEN 'Medium'
         ELSE 'High'
       END AS Price_Range,
       SUM(o.Total_Amount) AS Revenue
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY Price_Range
ORDER BY Revenue DESC;

-- 23) Low-stock alert (< 5 remaining after sales)
WITH Stock_Calc AS (
    SELECT b.Book_ID, b.Title, b.Stock, COALESCE(SUM(o.Quantity), 0) AS Total_Sold
    FROM Books b
    LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
    GROUP BY b.Book_ID, b.Title, b.Stock
)
SELECT Book_ID, Title, Stock, Total_Sold, Stock - Total_Sold AS Remaining_Stock
FROM Stock_Calc
WHERE Stock - Total_Sold < 5
ORDER BY Remaining_Stock ASC;


-- ======================
-- 📌 CUSTOMER INSIGHTS
-- ======================

-- 24) Customers who placed at least 2 orders
SELECT o.Customer_ID, c.Name, COUNT(o.Order_ID) AS Order_Count
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY o.Customer_ID, c.Name
HAVING COUNT(o.Order_ID) >= 2;

-- 25) Customer who spent the most
SELECT c.Customer_ID, c.Name, SUM(o.Total_Amount) AS Total_Spent
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY Total_Spent DESC 
LIMIT 1;

-- 26) Customers ranked by spending (window function)
SELECT 
    c.Customer_ID, 
    c.Name, 
    SUM(o.Total_Amount) AS Total_Spent,
    RANK() OVER (ORDER BY SUM(o.Total_Amount) DESC) AS Spending_Rank
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Name;

-- 27) Customers who spent more than average
SELECT Name, Customer_ID, Total_Spent
FROM (
    SELECT c.Customer_ID, c.Name, SUM(o.Total_Amount) AS Total_Spent
    FROM Orders o
    JOIN Customers c ON o.Customer_ID = c.Customer_ID
    GROUP BY c.Customer_ID, c.Name
) AS Cust_Spend
WHERE Total_Spent > (SELECT AVG(Total_Spent)
                     FROM (SELECT SUM(Total_Amount) AS Total_Spent
                           FROM Orders
                           GROUP BY Customer_ID) AS AvgTable)
ORDER BY Total_Spent DESC;

-- 28) Customer segmentation by spending
SELECT c.Customer_ID, c.Name,
       SUM(o.Quantity * b.Price) AS Total_Spent,
       CASE 
           WHEN SUM(o.Quantity * b.Price) > 500 THEN 'High Value'
           WHEN SUM(o.Quantity * b.Price) BETWEEN 200 AND 500 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS Customer_Segment
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY c.Customer_ID, c.Name;

-- 29) First-time vs Returning customers
WITH Cust_Spend AS (
  SELECT c.Customer_ID,
         COUNT(o.Order_ID) AS Order_Count,
         SUM(o.Total_Amount) AS Total_Spent
  FROM Customers c
  JOIN Orders o ON o.Customer_ID = c.Customer_ID
  GROUP BY c.Customer_ID
)
SELECT CASE WHEN Order_Count = 1 THEN 'One-time' ELSE 'Repeat' END AS Customer_Type,
       COUNT(*) AS Num_Customers,
       SUM(Total_Spent) AS Total_Revenue,
       ROUND(100.0 * SUM(Total_Spent) / (SELECT SUM(Total_Amount) FROM Orders), 2) AS Revenue_Share_Pct
FROM Cust_Spend
GROUP BY Customer_Type
ORDER BY Revenue_Share_Pct DESC;

-- 30) Customer Lifetime Value (CLV)
SELECT c.Customer_ID, c.Name,
       SUM(o.Total_Amount) AS Lifetime_Spend,
       COUNT(DISTINCT o.Order_ID) AS Total_Orders,
       AVG(o.Total_Amount) AS Avg_Order_Value
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY Lifetime_Spend DESC;


-- ======================
-- 📌 REVENUE TRENDS & GEOGRAPHY
-- ======================

-- 31) Revenue trends by month
SELECT DATE_TRUNC('month', Order_Date) AS Month,
       SUM(Total_Amount) AS Monthly_Revenue
FROM Orders
GROUP BY Month
ORDER BY Month;

-- 32) Revenue by country
SELECT c.Country, SUM(o.Total_Amount) AS Revenue
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Country
ORDER BY Revenue DESC;

-- 33) Customer distribution by country
SELECT Country, COUNT(Customer_ID) AS Customer_Count
FROM Customers
GROUP BY Country
ORDER BY Customer_Count DESC;

-- 34) Customer distribution by city
SELECT c.City, COUNT(DISTINCT c.Customer_ID) AS Num_Customers
FROM Customers c
GROUP BY c.City
ORDER BY Num_Customers DESC;




