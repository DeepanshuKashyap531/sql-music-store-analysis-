use chinook;

-- Q1. Which country has the most customers?

SELECT 
    i.BillingCountry,
    COUNT(DISTINCT c.CustomerId) AS Total_Customers
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY i.BillingCountry
ORDER BY Total_Customers DESC
LIMIT 10;

-- Q2. Who are the top 5 customers by total purchase value?

-- Version 1: Strict Top 5 (no tie handling)
SELECT 
    c.CustomerId,
    c.FirstName,
    SUM(i.Total) AS Total_Spent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName
ORDER BY Total_Spent DESC
LIMIT 5;


-- Version 2: Top 5 using DENSE_RANK (handles ties)
SELECT 
    CustomerId,
    FirstName,
    Total_Spent,
    rnks
FROM (
    SELECT 
        c.CustomerId,
        c.FirstName,
        SUM(i.Total) AS Total_Spent,
        DENSE_RANK() OVER (ORDER BY SUM(i.Total) DESC) AS rnks
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId, c.FirstName
) t
WHERE rnks <= 5;

-- Q3. Which artist generates the most revenue?

SELECT 
    ar.Name AS Artist,
    SUM(il.UnitPrice * il.Quantity) AS Total_Revenue
FROM Artist ar
JOIN Album al ON ar.ArtistId = al.ArtistId
JOIN Track t ON al.AlbumId = t.AlbumId
JOIN InvoiceLine il ON t.TrackId = il.TrackId
GROUP BY ar.Name
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Q4. Which genre sells the most tracks?

-- Version 1: Strict Top 5 (no tie handling)
SELECT 
    g.Name,
    SUM(il.Quantity) AS Total_Qty
FROM Genre g
JOIN Track t ON g.GenreId = t.GenreId
JOIN InvoiceLine il ON t.TrackId = il.TrackId
GROUP BY g.Name
ORDER BY Total_Qty DESC
LIMIT 5;


-- Version 2: Top 5 using DENSE_RANK (handles ties)
SELECT 
    Namess,
    Total_Qty,
    ranks
FROM (
    SELECT 
        g.Name AS Namess,
        SUM(il.Quantity) AS Total_Qty,
        DENSE_RANK() OVER (ORDER BY SUM(il.Quantity) DESC) AS ranks
    FROM Genre g
    JOIN Track t ON g.GenreId = t.GenreId
    JOIN InvoiceLine il ON t.TrackId = il.TrackId
    GROUP BY g.Name
) s
WHERE ranks <= 5;


-- Q5. What are the top 10 best selling tracks by total revenue and total quantity sold?

-- Version 1: Top 10 Tracks by Total Revenue
SELECT 
    t.TrackId,
    t.Name AS Track_Name,
    SUM(il.Quantity * il.UnitPrice) AS Total_Revenue
FROM Track t
JOIN InvoiceLine il ON t.TrackId = il.TrackId
GROUP BY t.TrackId, t.Name
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Version 2: Top 10 Tracks by Total Quantity Sold
SELECT 
    t.TrackId,
    t.Name AS Track_Name,
    SUM(il.Quantity) AS Total_Qty
FROM Track t
JOIN InvoiceLine il ON t.TrackId = il.TrackId
GROUP BY t.TrackId, t.Name
ORDER BY Total_Qty DESC
LIMIT 10;



-- Q6. Which employee has handled the most customers?

SELECT 
    e.EmployeeId,
    e.FirstName,
    e.LastName,
    COUNT(c.CustomerId) AS Total_Customers_Handled
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
GROUP BY e.EmployeeId, e.FirstName, e.LastName
ORDER BY Total_Customers_Handled DESC
LIMIT 1;



-- Q7. Monthly revenue trend — which months perform best?

SELECT 
    MONTH(InvoiceDate) AS Month_Number,
    MONTHNAME(InvoiceDate) AS Month_Name,
    SUM(Total) AS Total_Revenue
FROM Invoice
GROUP BY Month_Number, Month_Name
ORDER BY Total_Revenue DESC
LIMIT 12;



-- Q8. Which city has the highest average invoice value?

SELECT 
    BillingCity,
    ROUND(AVG(Total), 2) AS Avg_Invoice_Value
FROM Invoice
GROUP BY BillingCity
ORDER BY Avg_Invoice_Value DESC
LIMIT 1;



-- Q9. Customers who have never made a purchase (if any)

-- Version 1: Using LEFT JOIN + HAVING with SUM
SELECT 
    c.CustomerId,
    c.FirstName,
    SUM(i.Total) AS Total
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName
HAVING Total IS NULL;


-- Version 2: Using LEFT JOIN + HAVING with COUNT
SELECT 
    c.CustomerId,
    c.FirstName
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName
HAVING COUNT(i.InvoiceId) = 0;


-- Version 3: Using LEFT JOIN + WHERE (most efficient)
SELECT 
    c.CustomerId,
    c.FirstName
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE i.InvoiceId IS NULL;



-- Q10. Top 3 selling albums per genre

SELECT 
    Genre,
    AlbumId,
    Title,
    Total_Revenue
FROM (
    SELECT 
        g.Name AS Genre,
        a.AlbumId AS AlbumId,
        a.Title AS Title,
        SUM(il.Quantity * il.UnitPrice) AS Total_Revenue,
        RANK() OVER (
            PARTITION BY g.Name 
            ORDER BY SUM(il.Quantity * il.UnitPrice) DESC
        ) AS ranks
    FROM Genre g
    JOIN Track t ON g.GenreId = t.GenreId
    JOIN Album a ON t.AlbumId = a.AlbumId
    JOIN InvoiceLine il ON t.TrackId = il.TrackId
    GROUP BY g.Name, a.AlbumId, a.Title
) m
WHERE ranks <= 3;
