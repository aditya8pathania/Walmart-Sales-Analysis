SELECT * FROM Walmart_Sales;

-- 1. Creating Database
CREATE DATABASE IF NOT EXISTS Walmart;

-- 2. Using Database For Querying
USE Walmart;

-- 3. Creating Table 
CREATE TABLE `Walmart_Sales` (
	`Invoice ID` VARCHAR(11) NOT NULL, 
	`Branch` VARCHAR(1) NOT NULL, 
	`City` VARCHAR(9) NOT NULL, 
	`Customer type` VARCHAR(6) NOT NULL, 
	`Gender` VARCHAR(6) NOT NULL, 
	`Product line` VARCHAR(22) NOT NULL, 
	`Unit price` DECIMAL(38, 2) NOT NULL, 
	`Quantity` DECIMAL(38, 0) NOT NULL, 
	`Tax 5%%` DECIMAL(38, 4) NOT NULL, 
	`Total` DECIMAL(38, 4) NOT NULL, 
	`Date` DATETIME NOT NULL, 
	`Time` TIME NOT NULL, 
	`Payment` VARCHAR(11) NOT NULL, 
	cogs DECIMAL(38, 2) NOT NULL, 
	`gross margin percentage` DECIMAL(38, 9) NOT NULL, 
	`gross income` DECIMAL(38, 4) NOT NULL, 
	`Rating` DECIMAL(38, 1) NOT NULL
);

-- 4. Loading Data Into Table
LOAD DATA INFILE 'C:/Users/Solis/Desktop/Project/Walmart_Sales.csv'
INTO TABLE Walmart_Sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 5. Data Wrangling / Cleaning  - Already Cleaned As we use NOT NULL while table creation so records inserted are not null 

-- 6. Feature Engineering -- Creating time_of_day column and inserting values into it
ALTER TABLE Walmart_Sales 
ADD COLUMN time_of_day VARCHAR(20);

UPDATE Walmart_Sales
SET time_of_day = (
CASE 
	WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN "MORNING" 
	WHEN `time` BETWEEN '12:00:01' AND '16:00:00' THEN "AFTERNOON"
    ELSE "EVENING"
END
);

ALTER TABLE Walmart_Sales
ADD COLUMN day_name VARCHAR(10);

UPDATE Walmart_Sales
SET day_name = DAYNAME(date);

ALTER TABLE Walmart_Sales
ADD COLUMN month_name varchar(10);

UPDATE Walmart_Sales 
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------------------------
-- ---------------------------- Generic Questions ---------------------------------------

-- 1. How many unique cities does the data have 
SELECT DISTINCT(City) FROM Walmart_Sales;

-- 2. In which City is each Branch 
SELECT DISTINCT(City),branch FROM Walmart_Sales;

-- ---------------------------- Product --------------------------------------------------

-- 1. How many Unique Product Lines does the data have ?
SELECT DISTINCT(`Product line`) FROM Walmart_Sales;

-- 2. What is the Most common Payment 
SELECT payment,COUNT(payment) AS cnt FROM Walmart_Sales
GROUP BY payment
ORDER BY cnt DESC
LIMIT 1;

-- 3. What is the most selling Product Line 
SELECT `Product Line`, COUNT(`Product Line`) as cnt FROM Walmart_Sales
GROUP BY `Product Line`
ORDER BY cnt DESC; 

-- 4. What is the total revenue by Month 
SELECT month_name,SUM(Total) AS Revenue FROM Walmart_Sales
GROUP BY month_name
ORDER BY Revenue DESC;

-- 5.What month had the largest COGS ?
SELECT sum(cogs) as COGS,month_name FROM Walmart_Sales
GROUP BY month_name
ORDER BY COGS DESC;

-- 6. What Product Line had the Largest Revenue 
SELECT `Product line`,SUM(Total) AS Revenue FROM Walmart_Sales
GROUP BY `Product line`
ORDER BY Revenue DESC;

-- 7. What is the City with largest revenue?
SELECT City,Branch,SUM(Total) AS Revenue FROM Walmart_Sales
GROUP BY City,Branch 
ORDER BY Revenue DESC;

-- 8. What Product Lines has the Largest VAT ?
SELECT `Product line`,AVG(`Tax 5%%`) AS VAT FROM Walmart_sales
GROUP BY `Product line`
ORDER BY VAT DESC;

-- 9. Fetch Each Product Line and add column to those product line showing 'Good','Bad' . Good If its greater than average sales else Bad
ALTER TABLE Walmart_sales
ADD COLUMN Review varchar(4);

UPDATE Walmart_sales
SET Review = (
CASE
	WHEN Total > (Select avg(Total) from Walmart_Sales) THEN "Good"
    ELSE "BAD"
END
);

-- 10. Which Branch Sold more Products than average product sold 
SELECT Branch,SUM(Quantity) AS Sales FROM Walmart_Sales 
GROUP BY Branch 
HAVING Sales > AVG(Quantity);

-- 11. What is the most common product line by Gender ?
SELECT `Product line`,Gender,COUNT(Gender) FROM Walmart_Sales
GROUP BY `Product line`,Gender
ORDER BY `Product line`;

-- 12. What is the Average Rating of Each Product Line ?
select `Product line`,ROUND(avg(Rating),2) as Avg_Rating from Walmart_Sales
group by `Product Line`
order by Avg_Rating DESC;

-- ---------------------------------------------------------------------------------------
-- --------------------------------------- Sales -----------------------------------------

-- 1. Number of Sales made in each time of the day per weekday
SELECT time_of_day,COUNT(*) AS Total_Sales
FROM Walmart_sales
WHERE day_name = "Sunday"
GROUP BY time_of_day
ORDER BY Total_Sales DESC;

-- 2. Which of the customer types brings the most revenue?
SELECT `Customer type`,SUM(Total) AS Revenue FROM Walmart_Sales
GROUP BY `Customer type`
ORDER BY Revenue DESC; 

-- 3. Which City has the largest tax percent/VAT (Value Added Tax) ?
SELECT City,AVG(`Tax 5%%`) AS VAT FROM Walmart_Sales
GROUP BY City
ORDER BY VAT DESC;

-- 4. Which Customer type pays the most in VAT ?
SELECT `Customer type`,AVG(`Tax 5%%`) AS VAT FROM Walmart_Sales
GROUP BY `Customer type`;

-- ---------------------------------------------------------------------------------------
-- -------------------------------------- Customer ---------------------------------------

-- 1. How many unique customer types does the data have?
SELECT DISTINCT(`Customer type`) FROM walmart_sales;

-- 2. How many unique payment methods does the data have?
SELECT DISTINCT(Payment) FROM walmart_sales;

-- 3. What is the most common customer type?
select `Customer type`,count(*) as Users from walmart_sales
group by `Customer type`;

-- 4. Which customer type buys the most?
SELECT `Customer type`,count(*) as cnt FROM walmart_sales
GROUP BY `Customer type`; 

-- 5. What is the gender of most of the customers ?
SELECT gender,COUNT(*) as Gender_Ratio FROM walmart_sales
GROUP BY gender;

-- 6. What is the gender distribution per branch ?
SELECT gender,COUNT(*) AS Distribution_Count FROM walmart_sales
WHERE branch = 'B'
GROUP BY gender;

-- 7. Which time of the day do customers give most ratings ?
SELECT time_of_day,AVG(Rating) AS Avg_Rating FROM walmart_sales
GROUP BY time_of_day
ORDER BY Avg_Rating DESC;

-- 8. Which time of the day do customers give most ratings per branch ?
SELECT time_of_day,AVG(Rating) AS Avg_Rating FROM walmart_sales
WHERE Branch = 'C'
GROUP BY time_of_day
ORDER BY Avg_Rating DESC;

-- 9. Which day of the week has the best avg ratings ?
SELECT day_name,AVG(Rating) AS Avg_Rating FROM walmart_sales
GROUP BY day_name
ORDER BY Avg_Rating DESC;

-- 10. Which day of the week has the best average ratings per branch ?
SELECT day_name,AVG(Rating) AS Avg_Rating FROM walmart_sales
WHERE Branch = 'B'
GROUP BY day_name
ORDER BY Avg_Rating DESC;
