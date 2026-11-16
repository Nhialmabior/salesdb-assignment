-- =====================================================
-- Week 7 Assignment: Database Design and Normalization (week7_answer.sql)
-- =====================================================

-- A separate database is used so these tables do not clash with the
-- existing "orders" table in salesdb (table names are not case-sensitive on Windows).
CREATE DATABASE IF NOT EXISTS normalization_db;
USE normalization_db;

-- Drop tables so the script can be re-run safely (child tables first)
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS ProductDetail_1NF;


-- =====================================================
-- Question 1: Achieving First Normal Form (1NF)
-- =====================================================
-- Problem: the Products column holds several values in one cell
-- (e.g. 'Laptop, Mouse'), which breaks 1NF (atomic values required).
-- Solution: split the list so each row holds ONE product per order.
-- The composite primary key (OrderID, Product) identifies each row.

CREATE TABLE ProductDetail_1NF (
    OrderID      INT          NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Product      VARCHAR(100) NOT NULL,
    PRIMARY KEY (OrderID, Product)
);

INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product) VALUES
(101, 'John Doe',    'Laptop'),
(101, 'John Doe',    'Mouse'),
(102, 'Jane Smith',  'Tablet'),
(102, 'Jane Smith',  'Keyboard'),
(102, 'Jane Smith',  'Mouse'),
(103, 'Emily Clark', 'Phone');

-- Check: every row now has a single product value
SELECT * FROM ProductDetail_1NF;


-- =====================================================
-- Question 2: Achieving Second Normal Form (2NF)
-- =====================================================
-- Partial dependency: the composite key is (OrderID, Product), but
-- CustomerName depends only on OrderID (part of the key), not on
-- the whole key. This violates 2NF and repeats the customer name
-- on every product row of the same order.
-- Solution: move order-level data into Orders, and keep
-- product-level data (Product, Quantity) in OrderItems.

-- Orders: one row per order. CustomerName depends fully on OrderID.
CREATE TABLE Orders (
    OrderID      INT          NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    PRIMARY KEY (OrderID)
);

-- OrderItems: one row per product in an order.
-- Quantity depends on the full key (OrderID, Product).
-- OrderID is a foreign key to Orders.
CREATE TABLE OrderItems (
    OrderID  INT          NOT NULL,
    Product  VARCHAR(100) NOT NULL,
    Quantity INT          NOT NULL,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders (OrderID)
);

-- Insert into the parent table first
INSERT INTO Orders (OrderID, CustomerName) VALUES
(101, 'John Doe'),
(102, 'Jane Smith'),
(103, 'Emily Clark');

INSERT INTO OrderItems (OrderID, Product, Quantity) VALUES
(101, 'Laptop',   2),
(101, 'Mouse',    1),
(102, 'Tablet',   3),
(102, 'Keyboard', 1),
(102, 'Mouse',    2),
(103, 'Phone',    1);

-- Check: rebuild the original OrderDetails view with a join
SELECT o.OrderID, o.CustomerName, i.Product, i.Quantity
FROM Orders o
INNER JOIN OrderItems i ON o.OrderID = i.OrderID
ORDER BY o.OrderID, i.Product;
