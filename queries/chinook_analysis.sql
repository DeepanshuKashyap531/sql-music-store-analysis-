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






























#1 Which country has the most customers
select i.BillingCountry, count(distinct c.CustomerId) as total_customers from customer c join invoice i on c.CustomerId = i.CustomerId group by i.BillingCountry order by total_customers desc limit 10;

#2 Who are the top 5 customers by total purchase value?
select c.CustomerId , c.FirstName , sum(i.Total) as Total_spent from customer c join invoice i on c.CustomerId  = i.CustomerId group by c.FirstName , c.CustomerId order by Total_spent desc limit 5;
select CustomerId , FirstName, Total_spent ,rnks from ( select c.CustomerId,c.FirstName,sum(i.Total) as Total_spent, dense_rank() over (order by sum(i.Total) desc) as rnks from customer c join invoice i on c.CustomerId = i.CustomerId group by c.CustomerId,c.FirstName) t where rnks <= 5;

#3 Which artist generates the most revenue?
select ar.name as Artist , sum(il.UnitPrice * Quantity) as Total_Revenue from artist ar join album al on ar.ArtistId = al.ArtistId join track t on al.AlbumId = t.AlbumId join invoiceline il on t.TrackId = il.TrackId group by ar.name order by Total_Revenue desc limit 10;

#4 Which genre sells the most tracks?
select g.Name , sum(il.Quantity) as Total_Qty from genre g join track t on g.GenreId = t.GenreId join invoiceline il on t.TrackId = il.TrackId group by g.name order by Total_Qty desc limit 5;
#For tie result
select Namess , Total_Qty , ranks from ( select g.name as Namess , sum(il.Quantity) as Total_Qty , dense_rank() over (order by sum(il.Quantity) desc) as ranks from genre g join track t on g.GenreId = t.GenreId join invoiceline il on t.TrackId = il.TrackId group by g.name) s where ranks <=5;


#5 What are the top 10 best selling tracks for total revenue and total qty sold?
select t.TrackId , t.Name , sum(il.Quantity * il.UnitPrice) as Total_Revenue from track t join invoiceline il on t.TrackId = il.TrackId group by t.TrackId , t.Name order by Total_Revenue desc limit 10; 
select t.TrackId , t.Name , sum(il.Quantity) as Total_Qty from track t join invoiceline il on t.TrackId = il.TrackId group by t.TrackId , t.Name order by Total_Qty desc limit 10; 

#6 Which employee has handled the most customers?
select e.EmployeeId , e.FirstName ,e.LastName ,count(c.CustomerId) as Total_support from employee e join customer c on e.EmployeeId = c.SupportRepId group by e.EmployeeId , e.FirstName , e.LastName order by Total_support desc limit 1;

#7 Monthly revenue trend — which months perform best?
select month(InvoiceDate) as Month , MonthName(InvoiceDate) as Monthnames ,  sum(Total) as Total_Revenue from invoice group by  Month , Monthnames order by  Total_Revenue desc limit 200;

#8 Which city has the highest average invoice value?
select BillingCity , avg(Total) as Avg_Invoice_value from invoice group by BillingCity order by Avg_Invoice_value desc limit 1;

#9  Customer who has never made a purchase (if any)
select c.CustomerId , c.FirstName , sum(i.Total) as Total from customer c left join invoice i on c.CustomerId = i.CustomerId group by c.CustomerId , c.FirstName having Total is Null ;
select c.CustomerId , c.FirstName from customer c left join invoice i on c.CustomerId = i.CustomerId group by c.CustomerId , c.FirstName having count(i.invoiceId) is Null ;
select c.CustomerId , c.FirstName  from customer c left join invoice i on c.CustomerId = i.CustomerId where i.invoiceId is Null ;

#10 Top 3 selling albums per genre
select Genre , Albumid , Title , Total_Revenue from (select g.name as Genre, a.AlbumId as AlbumId, a.Title as Title , sum(il.Quantity * il.UnitPrice) as Total_Revenue , rank() over(partition by g.name order by sum(il.Quantity * il.UnitPrice) desc) as ranks from genre g join track t on g.genreId = t.GenreId join album a on t.AlbumId = a.AlbumId join invoiceline il on t.TrackId = il.TrackId group by g.name , a.AlbumId , a.Title) m where ranks <= 3