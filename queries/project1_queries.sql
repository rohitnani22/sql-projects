--TOP 5 MOST EXPENSIVE PRODUCTS
select    "Product Name",price
from orders
order by price desc 
limit 5 ;

--AVERAGE PRICE PER CATEGORY 
SELECT  
Category,
round(AVG(Price),2) AS average_price
from orders
group by Category;

-- TOP 5 CATEGORIES WITH HIGHEST AVERAGE PRICE
SELECT  
Category,
round(AVG(Price),2) AS average_price
from orders
group by Category
order by average_price desc 
LIMIT 5 ;


-- TOP 5 PRODUCTS WITH HIGHEST DISCOUNT
select "Product Name",
Discount
from orders
order by Discount desc 
limit 5;

--maximum discount per category
select Category,
 max(Discount)
from orders
GROUP by Category
order by Discount desc ;

-- average discount per category
select Category,
 avg(Discount) as average_discount
from orders
GROUP by Category
order by average_discount desc ;

-- TOP 5 CATEGORIES WITH HIGHEST AVERAGE PRICE AND MAXIMUM DISCOUNT
WITH cte AS (
    SELECT Category,
     AVG(price) AS average_price,
    MAX(Discount) AS maximum_discount
    FROM orders 
    GROUP BY Category
)
SELECT Category,
       average_price,
       maximum_discount
FROM cte 
ORDER BY average_price DESC;

-- TOP 3 MOST EXPENSIVE PRODUCTS PER CATEGORY
select *
from 
(
select 
	Category,
	"Product Name",
	price,
	row_number()over(
	partition by Category
	order by Price desc )
	as rank 
		from orders )
where rank <=3



-- TOP 3 MOST EXPENSIVE PRODUCTS PER CATEGORY USING RANK FUNCTION
    select *
    from 
(
    select 
      Category,
      "Product Name",
      price,
      rank()over(
      partition by Category
      order by Price desc )
      as rank 
        from orders )
    where rank <=3



--TOP 3 MOST EXPENSIVE PRODUCTS PER CATEGORY USING DENSE_RANK FUNCTION
   select *
    from 
(
    select 
      Category,
      "Product Name",
      price,
      dense_rank()over(
      partition by Category
      order by Price desc )
      as rank 
        from orders )
    where rank <=3

-- PERCENTAGE CONTRIBUTION OF EACH CATEGORY TO THE TOTAL SALES
    SELECT 
    Category,
   ROUND(SUM(Price),2) AS total_price,
    ROUND(
   SUM(Price) * 100.0 / SUM(SUM(Price)) OVER (),2 )
   AS percentage_contribution
FROM orders
GROUP BY Category
ORDER BY percentage_contribution DESC