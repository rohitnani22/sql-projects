# 📊 SQL Projects Portfolio

##  Project : E-COMMERCE SALES ANALYSIS 
### *PRODUCT ANALYSIS*
#### **Top 5 Most Expensive Products**
```sql
SELECT "Product Name", price
FROM orders
ORDER BY price DESC 
LIMIT 5;
```
![Top 5 most expensive products](screenshots/Screenshot%202026-03-22%20120858.png)

📌 Insight: Identifies expensive products. These items drive high per-unit revenue but may have lower sales volume.


### *Category Analysis*

#### **Average price per category**
```sql
SELECT  
Category,
round(AVG(Price),2) AS average_price
from orders
group by Category;
```
![Average price per category](screenshots/Screenshot%202026-03-22%20122339.png)

📌 Insight: Shows which categories are positioned as premium vs. budget. Helps understand pricing strategy across segments.

#### **Top 5  categories with highest average price**
```sql
SELECT  
Category,
round(AVG(Price),2) AS average_price
from orders
group by Category
order by average_price desc 
LIMIT 5 ;
```
![Top 5 categories with highest average price](screenshots/Screenshot%202026-03-22%20122102.png)

📌 Insight: Identifies the most premium categories. These likely target high-end customers or have higher production costs.

#### **Top 5 products with highest discount**
```sql
select "Product Name",
Discount
from orders
order by Discount desc 
limit 5;
```
![Top 5 products with highest discount](screenshots/2.png)

📌 Insight: Reveals products with aggressive discounting. May indicate clearance items, overstock, or loss leaders.
#### **Maximum discount per category**
```sql
select Category,
 max(Discount)
from orders
GROUP by Category
order by Discount desc ;
```
![Maximum discount per category](screenshots/Screenshot%202026-03-22%20123008.png)

📌 Insight: Shows the deepest discount offered in each category. Useful for understanding discount ceilings and promotion strategies.
#### **Average discount per category**
```sql
select Category,
 avg(Discount) as average_discount
from orders
GROUP by Category
order by average_discount desc ;
```
![Average discount per category](screenshots/Screenshot%202026-03-22%20123305.png)

📌 Insight: Reveals which categories typically offer higher discounts.

#### **Top 5 categories with highest average price and maximum discount**
```sql
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
```
![Top 5 categories with highest average price and maximum discount](screenshots/Screenshot%202026-03-22%20135657.png)

📌 Insight: Combines pricing and discount data. Premium categories with high discounts may indicate markdowns or competitive pricing pressure.

### *window functions*
#### **Top 3 most expensive products per category**
```sql
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
```
![Top 3 most expensive products per category using row_number](screenshots/Screenshot%202026-03-22%20140726.png)

📌 Insight: ROW_NUMBER gives unique ranking. If there's a tie in price, only one product gets rank 1,2,3 — others are excluded.

#### **Top 3 most expensive products per category using rank function**
```sql
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
    
   ```
   ![Top 3 most expensive products per category using rank](screenshots/Screenshot%202026-03-22%20141547.png)
 

📌 Insight: RANK creates gaps for ties. If two products tie for #1, next rank is #3 (skips #2). Shows all tied products within top positions.

#### **Top 3 most expensive products per category using dense rank function**

```sql
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
  ```
  ![Top 3 most expensive products per category using dense_rank](screenshots/1.png)

📌 Insight: DENSE_RANK has no gaps. If two products tie for #1, next rank is #2. Best for showing all top products without skipping ranks
 #### **Percentage contribution of each category to total sales**
 ```sql
    SELECT 
    Category,
   ROUND(SUM(Price),2) AS total_price,
    ROUND(
   SUM(Price) * 100.0 / SUM(SUM(Price)) OVER (),2 )
   AS percentage_contribution
FROM orders
GROUP BY Category
ORDER BY percentage_contribution DESC
``` 
![Percentage contribution of each category to total sales](screenshots/Screenshot%202026-03-22%20142517.png)

📌 Insight: Shows which categories drive the most revenue. Focus marketing and inventory on top contributors; investigate underperforming ones.

## Project 2 : RETAIL ANALYTICS
    
  
 #### **High price but low popularity categories**
 ```sql
select 
  Category,
  round(avg(price),2)as average_price,
  round(avg("Popularity Index"),2) as avg_popularity
from orders
group by Category
order by average_price desc,avg_popularity ASC
```
![High price but low popularity categories](screenshots/Screenshot%202026-03-22%20150438.png)

📌 Insight: Identifies expensive categories that customers don't like. These may need price adjustment, quality improvement, or better marketing.

#### **High price but low popularity categories with average price above 500 and average popularity index below 50**
```sql
--(THRESHOLDS CAN BE ADJUSTED BASED ON THE DATA DISTRIBUTION)
SELECT 
  Category,
  ROUND(AVG(price),2) AS average_price,
  ROUND(AVG("Popularity Index"),2) AS avg_popularity
FROM orders
GROUP BY Category
HAVING AVG(price) > 500 
   AND AVG("Popularity Index") < 50
ORDER BY average_price DESC;
```
![High price low popularity categories filtered](screenshots/Screenshot%202026-03-22%20150750.png)

📌 Insight: Flags specific underperforming premium categories. These are the biggest opportunities for improvement — high price, low satisfaction.

#### **High discount but low popularity products (row-level)**
```sql
SELECT 
    "Product Name",
    Discount,
    "Popularity Index"
FROM orders
ORDER BY Discount DESC, "Popularity Index" ASC
LIMIT 5;
```
![High discount low popularity products row level](screenshots/Screenshot%202026-03-22%20152345.png)

📌 Insight: Finds individual products where discounts aren't working. Despite heavy discounts, customers still don't like these items.

#### **High discount but low popularity products (aggregated )**
```sql
SELECT
	"Product Name",
	AVG(Discount) AS average_discount,
	avg("Popularity Index") as average_popularity
FROM orders
GROUP by "Product Name"
order by average_discount desc,average_popularity asc
```
![High discount low popularity products aggregated](screenshots/Screenshot%202026-03-22%20151906.png)

📌 Insight: Product-level view of discount effectiveness. Products consistently discounted but still unpopular may need to be discontinued.
#### **Estimated revenue and return rate by category**
```sql
select
 Category,
 sum(price) as estimated_revenue,
 avg("Return Rate") as avg_return_rate
 from orders
 group by Category
 order by estimated_revenue desc,avg_return_rate desc
 ```
 ![Estimated revenue and return rate by category](screenshots/Screenshot%202026-03-22%20153718.png)

📌 Insight: Reveals revenue vs. return trade-offs. High-revenue categories with high return rates may have quality or expectation issues.

#### **Categories with high return popularity but low return rate**
```sql
 select
	Category,
	avg("Popularity Index") as avg_popularity,
	avg("Return Rate") as avg_return_rate

from orders
group by Category 
order by  avg_popularity desc ,avg_return_rate asc
```
![Categories with high popularity low return rate](screenshots/Screenshot%202026-03-22%20155105.png)

📌 Insight: Identifies winning categories — customers love them and rarely return them. Double down on these for marketing and inventory focus.




