# 🎵 SQL Music Store Analysis
### Chinook Database — Business Intelligence Using SQL

**Author:** Deepanshu Kashyap  
**Tool:** MySQL Workbench  
**Dataset:** Chinook Database (Music Store)  
**Domain:** Music & Entertainment Analytics

---

## 📌 Project Overview

This project performs a comprehensive business analysis on the Chinook Music Store database using SQL. The Chinook database simulates a digital music store with data across 11 tables including customers, invoices, tracks, albums, artists, genres, and employees.

The goal is to extract actionable business insights across sales, customer behavior, artist performance, and employee efficiency — answering real business questions using SQL queries involving JOINs, aggregations, subqueries, CTEs, and window functions.

---

## 🗃️ Database Schema

The Chinook database contains the following key tables:

| Table | Description |
|-------|-------------|
| `Customer` | Customer details and location |
| `Invoice` | Purchase transactions |
| `InvoiceLine` | Line items per invoice |
| `Track` | Individual tracks/episodes |
| `Album` | Albums containing tracks |
| `Artist` | Artists linked to albums |
| `Genre` | Music genres |
| `Employee` | Store staff and support reps |
| `MediaType` | Format of tracks |
| `Playlist` | Curated playlists |
| `PlaylistTrack` | Tracks within playlists |

---

## ❓ Business Questions & Analysis

---

### Q1. Which country has the most customers?

**Business Goal:** Identify the top markets for customer acquisition and marketing focus.

```sql
SELECT 
    i.BillingCountry,
    COUNT(DISTINCT c.CustomerId) AS Total_Customers
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY i.BillingCountry
ORDER BY Total_Customers DESC
LIMIT 10;
```

**Result:**

| Country | Total Customers |
|---------|----------------|
| USA | 13 |
| Canada | 8 |
| Brazil | 5 |
| France | 5 |
| ... | ... |
| Australia | 1 |
| India | 2 |

**Insight:** USA leads with 13 customers, followed by Canada with 8 and Brazil and France with 5 each. These 4 countries represent the core customer base and should be prioritized for retention and upselling. Australia and India show low penetration with 1-2 customers each, representing potential growth markets worth exploring through targeted campaigns.

---

### Q2. Who are the top 5 customers by total purchase value?

**Business Goal:** Identify high value customers for loyalty programs and personalized offers.

```sql
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


-- Version 2: Top 5 using DENSE_RANK (handles ties) ✅ Recommended
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
```

> **Note:** Version 1 strictly returns 5 customers regardless of ties. Version 2 uses DENSE_RANK to fairly handle customers with equal spending — recommended for accurate analysis.

**Result:**

| Rank | Name | Total Spent |
|------|------|-------------|
| 1 | Helena | $49.62 |
| 2 | Richard | $47.62 |
| 3 | Luis | $46.62 |
| 4 | Hugh | $45.62 |
| 4 | Ladislav | $45.62 |
| 5 | Fynn | $43.62 |
| 5 | Julia | $43.62 |
| 5 | Frank | $43.62 |

**Insight:** The top customers show remarkably similar spending patterns, with only a $6 difference between rank 1 and rank 7. Helena leads with $49.62 in total purchases. The close spending gap suggests a loyal but evenly distributed customer base. Introducing loyalty rewards or personalized vouchers for these top customers could push their spending significantly higher given their already demonstrated willingness to purchase.

---

### Q3. Which artist generates the most revenue?

**Business Goal:** Identify top performing artists to prioritize for promotions and catalog expansion.

```sql
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
```

**Result:**

| Artist | Total Revenue |
|--------|--------------|
| Iron Maiden | $138.60 |
| U2 | $105.93 |
| Metallica | $90.09 |
| Led Zeppelin | $86.13 |
| Lost | $81.59 |
| The Office | $49.75 |
| Os Paralamas Do Sucesso | $44.55 |
| Deep Purple | $43.56 |
| Faith No More | $41.58 |
| Eric Clapton | $39.60 |

**Insight:** Iron Maiden leads all artists with $138.60 in revenue, followed by U2 at $105.93 and Metallica at $90.09. Notably, 7 out of the top 10 revenue generating artists are Rock or Metal acts, reinforcing Rock's dominance seen in genre analysis. Prioritizing promotional efforts and expanding catalog for these top artists, particularly Iron Maiden and U2, would likely yield the highest return on investment.

---

### Q4. Which genre sells the most tracks?

**Business Goal:** Understand genre demand to guide content acquisition and promotional strategy.

```sql
-- Version 1: Strict Top 5
SELECT 
    g.Name,
    SUM(il.Quantity) AS Total_Qty
FROM Genre g
JOIN Track t ON g.GenreId = t.GenreId
JOIN InvoiceLine il ON t.TrackId = il.TrackId
GROUP BY g.Name
ORDER BY Total_Qty DESC
LIMIT 5;


-- Version 2: Top 5 using DENSE_RANK (handles ties) ✅ Recommended
SELECT 
    Genre,
    Total_Qty,
    ranks
FROM (
    SELECT 
        g.Name AS Genre,
        SUM(il.Quantity) AS Total_Qty,
        DENSE_RANK() OVER (ORDER BY SUM(il.Quantity) DESC) AS ranks
    FROM Genre g
    JOIN Track t ON g.GenreId = t.GenreId
    JOIN InvoiceLine il ON t.TrackId = il.TrackId
    GROUP BY g.Name
) s
WHERE ranks <= 5;
```

**Result:**

| Genre | Total Qty Sold |
|-------|---------------|
| Rock | 835 |
| Latin | 386 |
| Metal | 264 |
| Alternative & Punk | 244 |
| Jazz | 80 |

**Insight:** Rock dominates massively with 835 tracks sold — more than double the second place Latin at 386. This confirms Rock as the primary revenue driving genre. However, Latin, Metal and Alternative & Punk show solid numbers and likely have strong regional demand. A region-specific genre promotion strategy would be more effective than a global one — for example, promoting Latin music in Brazil and South American markets where cultural affinity is stronger.

---

### Q5. What are the top 10 best selling tracks by revenue and quantity?

**Business Goal:** Identify individual track performance to guide playlist curation and pricing strategy.

```sql
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
```

**Result Summary:**

| Metric | Top Performers | Pattern |
|--------|---------------|---------|
| By Revenue | TV Show Episodes (The Office, Lost) | All priced at $1.99, sold twice = $3.98 |
| By Quantity | Rock & Metal Tracks (Metallica, AC/DC) | All sold 2 units each |

**Insight:** Top tracks by revenue and quantity tell two different stories. By revenue, TV show episodes dominate due to higher unit pricing, while by quantity sold, Rock and Metal tracks dominate. This suggests Rock fans are more engaged listeners driving volume, while video content commands higher price points. A dual strategy of expanding video content for revenue and Rock catalog for volume would be most effective.

---

### Q6. Which employee has handled the most customers?

**Business Goal:** Assess support team workload distribution and identify staffing needs.

```sql
SELECT 
    e.EmployeeId,
    e.FirstName,
    e.LastName,
    COUNT(c.CustomerId) AS Total_Customers_Handled
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
GROUP BY e.EmployeeId, e.FirstName, e.LastName
ORDER BY Total_Customers_Handled DESC;
```

**Result:**

| Employee ID | Name | Customers Handled |
|-------------|------|------------------|
| 3 | Jane Peacock | 21 |
| 4 | Margaret Park | 20 |
| 5 | Steve Johnson | 18 |

**Insight:** All three support employees show a remarkably balanced workload — Jane Peacock leads with 21 customers, followed by Margaret Park with 20 and Steve Johnson with 18. The narrow gap suggests effective and fair work distribution across the support team. However, as the business scales and customer base grows, hiring additional support staff should be considered to maintain this balance and service quality.

---

### Q7. Monthly and yearly revenue trend — which months perform best?

**Business Goal:** Identify seasonal revenue patterns to plan promotions and campaigns.

```sql
SELECT 
    YEAR(InvoiceDate) AS Year,
    MONTH(InvoiceDate) AS Month_Number,
    MONTHNAME(InvoiceDate) AS Month_Name,
    SUM(Total) AS Total_Revenue
FROM Invoice
GROUP BY Year, Month_Number, Month_Name
ORDER BY Total_Revenue DESC;
```

**Result (Top & Bottom Months across 2021–2025):**

| Rank | Month | Total Revenue |
|------|-------|--------------|
| 1 | January | $201.12 |
| 2 | June | $201.10 |
| 3 | April | $198.14 |
| ... | ... | ... |
| 10 | October | $193.10 |
| 11 | November | $186.24 |
| 12 | December | $189.10 |

**Insight:** Revenue is distributed relatively evenly across all months with only a $15 gap between the highest (January - $201.12) and lowest (November - $186.24) performing months. January and June lead in revenue, likely driven by post-holiday spending and summer leisure activity respectively. The surprisingly low December performance suggests the store is not capitalizing on holiday season demand — a targeted Christmas and holiday promotion campaign could significantly boost year-end revenue.

---

### Q8. Which city has the highest average invoice value?

**Business Goal:** Identify high spending cities for targeted premium content and upselling.

```sql
SELECT 
    BillingCity,
    ROUND(AVG(Total), 2) AS Avg_Invoice_Value
FROM Invoice
GROUP BY BillingCity
ORDER BY Avg_Invoice_Value DESC
LIMIT 10;
```

**Result:**

| City | Avg Invoice Value |
|------|------------------|
| Fort Worth | $6.80 |
| Santiago | $6.66 |
| Budapest | $6.52 |
| Dublin | $6.52 |
| Prague | $6.45 |
| Chicago | $6.23 |
| Salt Lake City | $6.23 |
| Frankfurt | $6.23 |
| Bangalore | $6.11 |
| Madison | $6.09 |

**Insight:** Fort Worth leads with the highest average invoice value at $6.80, followed by Santiago at $6.66 and Budapest and Dublin tied at $6.52. Interestingly, despite USA having the most customers overall from Q1, only two American cities appear in the top 10 by average invoice value. This suggests that while the USA drives customer volume, customers in cities like Santiago and Budapest spend more per transaction. Targeting high average value cities with premium content and upselling strategies could significantly boost overall revenue.

---

### Q9. Customers who have never made a purchase (if any)

**Business Goal:** Identify inactive customers for re-engagement campaigns.

```sql
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


-- Version 3: Using LEFT JOIN + WHERE ✅ Most Efficient
SELECT 
    c.CustomerId,
    c.FirstName
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE i.InvoiceId IS NULL;
```

> **Note:** Three approaches were used to verify the result. Version 3 (WHERE clause) is the most efficient method for finding unmatched records. All three confirmed the same finding.

**Result:** No customers found — empty result set.

**Insight:** Analysis reveals that all customers in the database have made at least one purchase, indicating a 100% customer conversion rate. This is a positive finding suggesting strong onboarding practices. All three query approaches confirmed this result, validating the finding. It would be worth monitoring new customer purchasing behavior over time to ensure conversion rates are maintained as the business scales.

---

### Q10. Top 3 selling albums per genre

**Business Goal:** Understand which albums drive revenue within each genre to guide catalog and licensing decisions.

```sql
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
```

**Key Findings:**

| Genre | Top Album | Revenue |
|-------|-----------|---------|
| Sci Fi & Fantasy | Battlestar Galactica (Classic), Season 1 | $35.82 |
| Drama | Heroes, Season 1 | $21.89 |
| Alternative | Revelations | $4.95 |
| Latin | Minha Historia | $26.73 |
| Rock | Greatest Kiss | $19.80 |
| Classical | Multiple albums tied | $1.98 |

**Insight:** Sci Fi & Fantasy leads all genres with Battlestar Galactica Season 1 generating $35.82 — the highest single album revenue across the entire catalog. Latin and Rock show consistently strong performance across all top 3 album slots, reinforcing their dominance seen in earlier analysis. Classical genre shows the weakest album revenues at $1.98 per album, suggesting either low demand or significant underpricing. TV and Sci Fi content consistently outperforms music albums in revenue, strongly indicating that expanding video and series content should be a top business priority.

---

## 🔑 Key SQL Concepts Used

| Concept | Used In |
|---------|---------|
| JOINS (2-4 tables) | Q1, Q2, Q3, Q4, Q5, Q6, Q9, Q10 |
| Aggregations (SUM, COUNT, AVG) | Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8 |
| GROUP BY + HAVING | Q2, Q6, Q9 |
| Subqueries | Q2, Q4, Q10 |
| Window Functions (RANK, DENSE_RANK) | Q2, Q4, Q10 |
| LEFT JOIN for unmatched records | Q9 |
| ROUND for monetary formatting | Q8 |
| YEAR(), MONTH(), MONTHNAME() | Q7 |

---

## 💡 Overall Business Recommendations

1. **Focus marketing on USA, Canada, Brazil and France** — these 4 countries represent the core customer base.
2. **Launch a loyalty program** for top spending customers — the narrow spending gap means small incentives could significantly increase revenue.
3. **Prioritize Rock and Metal catalog expansion** — dominant across genre sales, artist revenue, and track quantity metrics.
4. **Invest in video and TV content** — Sci Fi, Drama and TV shows consistently outperform music in revenue per album.
5. **Run a December holiday campaign** — surprisingly low December revenue represents a significant missed opportunity.
6. **Target high average value cities** like Santiago, Budapest and Dublin with premium content offers.
7. **Monitor support team capacity** — current workload is balanced but will need scaling as customer base grows.

---

## 📁 Project Structure

```
sql-music-store-analysis/
│
├── README.md
├── queries/
│   └── chinook_analysis.sql
└── outputs/
    ├── q1_customers_by_country.png
    ├── q2_top_customers.png
    ├── q3_top_artists.png
    ├── q4_top_genres.png
    ├── q5_top_tracks_revenue.png
    ├── q5_top_tracks_qty.png
    ├── q6_employee_performance.png
    ├── q7_monthly_revenue.png
    ├── q8_city_avg_invoice.png
    ├── q9_inactive_customers.png
    └── q10_top_albums_per_genre.png
```

---

## 👤 Author

**Deepanshu Kashyap**  
📧 deepanshukashyap531@gmail.com  
📍 Pune, Maharashtra  
🔗 [GitHub](https://github.com/DeepanshuKashyap531)
