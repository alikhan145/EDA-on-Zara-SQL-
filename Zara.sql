select * from zara;

alter table zara
drop column url;

select currency from zara
group by currency;

select * from zara;

alter table zara
rename column `Product Position` to Product_Position;

alter table zara
rename column `Product ID` to Product_ID,
rename column `Product Category` to Product_Category,
rename column `Sales Volume` to Sales_Volume;


select * from zara;

with duplicate_cte as 
(
select * ,
row_number() over (partition by Product_ID , Product_Position , Promotion , Product_Category,
Seasonal , Sales_Volume , brand , sku , name , description , price , currency , scraped_at, terms ,section ) as row_num
from zara 
)
select * from 
duplicate_cte
where row_num > 1;



create table zara2
(
Product_ID int ,
Product_Position text ,
Promotion text ,
Product_Category text ,
Seasonal text ,
Sales_Volume int ,
brand text ,
sku text ,
name text ,
description text ,
price double ,
currency text ,
scraped_at text ,
terms text ,
section text,
row_num int
)
engine= InnoDB default charset=utf8mb4 collate =utf8mb4_0900_ai_ci;


select * from zara2;

insert into zara2
select * ,
row_number() over (partition by Product_ID , Product_Position , Promotion , Product_Category,
Seasonal , Sales_Volume , brand , sku , name , description , price , currency , scraped_at, terms ,section ) as row_num
from zara ;


select * from zara2;

select section , count(*)
from zara2
group by section;

select description , count(*)
from zara2
group by description;

select Product_Position , count(Product_Position)
from zara2
group by Product_Position
having count(Product_Position) > 1;

select Product_Position
from zara2
where Product_Position is null;

select * from zara2;

use diwali;
select max(price) from zara2; 
select avg(price) from zara2; 

select distinct name,price 
from zara2
group by name, price; 




-- EDA





-- What is the overall sales volume?

select * from zara2;

select sum(sales_volume) as overall_sales
from zara2;

-- Which product has the highest sales volume?

select Product_ID , max(sales_volume)
from zara2
group by Product_ID
limit 1;

-- Is there a correlation between sales volume and price?

select * from zara2;

select corr(sales_volume,price) as correlation
from zara2;


-- How do sales volumes vary across different product categories or brands?

select Product_Category, brand , sum(Sales_Volume) as total_sales
from zara2
group by Product_Category, brand;


-- How many products are currently being promoted?

select * from zara2;

select count(distinct Product_ID) as product_promoted
from zara2
where promotion = 'yes';


-- What types of promotions are most common?

select * from zara2;

select promotion , count(*) as promotion_count
from zara2
group by promotion
order by promotion_count ;

-- Do promoted products have higher sales volumes compared to non-promoted products?




-- What are the most common product categories?
select * from zara2;

select distinct product_category, count(*) as category_count
from zara2
group by product_category
order by category_count desc;

-- Are there any seasonal products? How do their sales volumes vary over time?

select distinct product_id
from zara2
where seasonal = 'yes';

-- How do their sales volumes vary over time (Analyze sales volumes over time)

SELECT 
    YEAR(scraped_at) AS Year,
    MONTH(scraped_at) AS Month,
    SUM(Sales_Volume) AS Total_Sales_Volume
FROM 
    zara2
WHERE 
    Seasonal = 'Yes'
GROUP BY 
    YEAR(scraped_at), MONTH(scraped_at)
ORDER BY 
    Year, Month;


-- What are the most common brands and SKUs?

select * from zara2;

select sku,brand, count(*) as count_sku
from zara2
group by sku,brand
order by count_sku;

-- Is there any correlation between product descriptions and sales volume?
select * from zara2;

use diwali;
select corr(description,sales_volume) as correlation
from zara2;

-- What is the average price of products?

select avg(price)
from zara2;


-- How do prices vary across different product categories or brands?

select * from zara2;

select brand ,product_category , avg(price)
from zara2
group by  brand ,product_category
order by avg(price);


-- Is there any correlation between price and sales volume?
SELECT
    (
        SUM((price - mean_column1) * (sales_volume - mean_column2)) 
        / 
        (SQRT(SUM(POW(price - mean_column1, 2))) * SQRT(SUM(POW(sales_volume - mean_column2, 2))))
    ) AS Correlation
FROM
    (
        SELECT
            AVG(price) AS mean_column1,
            AVG(sales_volume) AS mean_column2
        FROM
            zara2
    ) AS mean_values, zara2;

-- How does sales volume vary over time (e.g., by month or quarter)?

SELECT 
    YEAR(sales_volume) AS Year,
    MONTH(sales_volume) AS Month,
    SUM(Sales_Volume) AS Total_Sales_Volume
FROM 
    zara2
group by  year , month;


-- Are there any trends in product availability or promotions over time?

SELECT 
    YEAR(Product_ID) AS Year,
    MONTH(Product_ID) AS Month,
    COUNT(*) AS Product_Count
FROM 
    zara2
where YEAR(Product_ID) and MONTH(Product_ID) is not null
GROUP BY 
    YEAR(Product_ID), MONTH(Product_ID)
ORDER BY 
    Year, Month;


-- Are there any missing values in the dataset?

SELECT 
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Product_ID,
    SUM(CASE WHEN Product_Position IS NULL THEN 1 ELSE 0 END) AS Product_Position,
    SUM(CASE WHEN Promotion IS NULL THEN 1 ELSE 0 END) AS Promotion,
    SUM(CASE WHEN Product_Category IS NULL THEN 1 ELSE 0 END) AS Product_Category,
    SUM(CASE WHEN Seasonal IS NULL THEN 1 ELSE 0 END) AS Seasonal,
    SUM(CASE WHEN brand IS NULL THEN 1 ELSE 0 END) AS brand,
    SUM(CASE WHEN sku IS NULL THEN 1 ELSE 0 END) AS sku,
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name,
    SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS description,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price,
    SUM(CASE WHEN currency IS NULL THEN 1 ELSE 0 END) AS currency,
    SUM(CASE WHEN scraped_at IS NULL THEN 1 ELSE 0 END) AS scraped_at,
    SUM(CASE WHEN terms IS NULL THEN 1 ELSE 0 END) AS terms,
    SUM(CASE WHEN section IS NULL THEN 1 ELSE 0 END) AS section
FROM 
    zara2;

-- Are there any outliers in sales volume or price?

SELECT
    AVG(price) AS Avg_Price,
    MEDIAN(price) AS Median_Price,
    STDDEV(price) AS Stddev_Price,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price) AS Q1_Price,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY price) AS Q3_Price,
    AVG(Sales_Volume) AS Avg_Sales_Volume,
    MEDIAN(Sales_Volume) AS Median_Sales_Volume,
    STDDEV(Sales_Volume) AS Stddev_Sales_Volume,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Sales_Volume) AS Q1_Sales_Volume,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Sales_Volume) AS Q3_Sales_Volume
FROM
    zara2;
    


-- Is the currency consistent across all records?

-- What are the most common terms used in product descriptions?
select * from zara2;

select description, count(*)
from zara2
group by description;



-- Is there any correlation between product descriptions and sales volume or price?


