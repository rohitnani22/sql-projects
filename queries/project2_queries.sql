--High price but low popularity categories
select 
  Category,
  round(avg(price),2)as average_price,
  round(avg("Popularity Index"),2) as avg_popularity
from orders
group by Category
order by average_price desc,avg_popularity ASC

-- High price but low popularity categories with average price above 500 and average popularity index below 50
--(THRESOLDS CAN BE ADJUSTED BASED ON THE DATA DISTRIBUTION)
SELECT 
  Category,
  ROUND(AVG(price),2) AS average_price,
  ROUND(AVG("Popularity Index"),2) AS avg_popularity
FROM orders
GROUP BY Category
HAVING AVG(price) > 500 
   AND AVG("Popularity Index") < 50
ORDER BY average_price DESC;


--High discount but low popularity products (row-level)
SELECT 
    "Product Name",
    Discount,
    "Popularity Index"
FROM orders
ORDER BY Discount DESC, "Popularity Index" ASC
LIMIT 5;

--High discount but low popularity products (aggregated )
SELECT
	"Product Name",
	AVG(Discount) AS average_discount,
	avg("Popularity Index") as average_popularity
FROM orders
GROUP by "Product Name"
order by average_discount desc,average_popularity asc

--Estimated revenue and return rate by category
select
 Category,
 sum(price) as estimated_revenue,
 avg("Return Rate") as avg_return_rate
 from orders
 group by Category
 order by estimated_revenue desc,avg_return_rate desc


--Categories with high return popularity but low return rate
 select
	Category,
	avg("Popularity Index") as avg_popularity,
	avg("Return Rate") as avg_return_rate

from orders
group by Category 
order by  avg_popularity desc ,avg_return_rate asc


