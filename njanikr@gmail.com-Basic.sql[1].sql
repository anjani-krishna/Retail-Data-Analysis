Create Database Ecommerce_Sales

----Q1.What is the total number of rows in each of the 3 tables in the database?

SELECT
(SELECT COUNT(*) FROM Customer) AS table1_rows,
(SELECT COUNT(*) FROM prod_cat_info) AS table2_rows,
(SELECT COUNT(*) FROM Transactions) AS table3_rows,
(SELECT COUNT(*) FROM Customer) + (SELECT COUNT(*) FROM prod_cat_info) + (SELECT COUNT(*) FROM Transactions)
AS total_rows;


=============================================================================================================================================================

----Q2. What is the total number of transactions that have a return?

Alter table Transactions
ALTER column Rate float;

SELECT COUNT (Rate) AS total_returns
FROM Transactions
WHERE Rate <0


==================================================================================================================================================================


----Q3. As you would have noticed, the dates provided across the datasets are not in a correct format. As first steps, pls convert the date variables into valid date formats before proceeding ahead.

UPDATE Transactions
SET tran_date = CONVERT(DATE, tran_date, 103)

ALTER table Transactions
ALTER column tran_date Date;


==================================================================================================================================================================

----Q4.What is the time range of the transaction data available for analysis? Show the output in number of days, months and years simultaneously in different columns.

SELECT MIN(tran_date) AS min_date, MAX(tran_date) AS max_date
FROM Transactions


SELECT DATEDIFF(DAY, MIN(CONVERT(DATE, Tran_date, 105)), MAX(CONVERT(DATE, Tran_date, 105))) as Days_Range, 
DATEDIFF(MONTH, MIN(CONVERT(DATE, Tran_date, 105)), MAX(CONVERT(DATE, Tran_date, 105))) as Months_Range,  
DATEDIFF(YEAR, MIN(CONVERT(DATE, Tran_date, 105)), MAX(CONVERT(DATE, Tran_date, 105))) as Years_Range
FROM Transactions



==========================================================================================================================================================================

----Q5. Which product category does the sub-category “DIY” belong to?
    
SELECT prod_cat FROM prod_cat_info
WHERE prod_subcat ='DIY'

  
===============================================================================================================


DATA ANALYSIS-

----Q1.Which channel is most frequently used for transactions?

SELECT TOP 1 
Store_type, COUNT(Store_type)AS Total_Count
FROM Transactions
GROUP BY Store_type
ORDER BY COUNT(Store_type) DESC;

===================================================================================================================

----Q2.What is the count of Male and Female customers in the database?

SELECT Gender, COUNT(Customer_id) AS COUNTG
FROM Customer
WHERE Gender IN ('M' , 'F')
GROUP BY Gender

========================================================================================================================

----Q3. From which city do we have the maximum number of customers and how many?

SELECT top 1
city_code, COUNT(city_code) CUST_CNT
FROM Customer
GROUP BY city_code
ORDER BY CUST_CNT DESC

===========================================================================================================================

----Q4. How many sub-categories are there under the Books category?

SELECT COUNT(prod_subcat) AS Sub_catcount
FROM prod_cat_info
WHERE prod_cat = 'BOOKS'
GROUP BY prod_cat

============================================================================================================================

----Q5. What is the maximum quantity of products ever ordered?

SELECT TOP 1
prod_cat_code, COUNT(prod_cat_code) AS Totalquantity
FROM Transactions
GROUP BY prod_cat_code
ORDER BY Totalquantity DESC;

====================================================================================================================================

----Q6.What is the net total revenue generated in categories Electronics and Books?

Alter table Transactions
ALTER column total_amt float;

SELECT
    prod_cat_code
    
    SUM(total_amt) AS NetTotalRevenue
FROM
    Transactions
WHERE
    prod_cat_code IN ('3', '5')
GROUP BY
    prod_cat_code;

SELECT SUM(total_amt) as Net_Revenue
FROM Transactions
WHERE prod_cat_code IN ('3' , '5')

========================================================================================================================================

----Q7.How many customers have >10 transactions with us, excluding returns?

Alter table Transactions
ALTER column transaction_id float;


SELECT COUNT(customer_id) AS CUSTOMER_COUNT
FROM Customer WHERE customer_id IN 
(
SELECT cust_id
FROM Transactions
LEFT JOIN Customer ON customer_id = CUST_ID
WHERE total_amt NOT LIKE '-%'
GROUP BY
CUST_ID
HAVING 
COUNT(transaction_id) > 10
)
=================================================================================================================================================

----Q.8 What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

SELECT SUM(total_amt) as AMOUNT
FROM Transactions
WHERE prod_cat_code IN ('1' , '5') and Store_type = 'Flagship store'


==================================================================================================================================================

----Q9. What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.

SELECT prod_subcat_code, SUM(total_amt) as Revenue
FROM Transactions
LEFT JOIN Customer ON cust_id=customer_Id
LEFT JOIN prod_cat_info ON prod_subcat_code = prod_sub_cat_code AND prod_cat_code = prod_cate_code
WHERE prod_cat_code= '3' AND Gender = 'M'
GROUP BY prod_subcat_code, prod_subcat

=====================================================================================================================================================
----Q10. What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?

SELECT TOP 5 
PROD_SUBCAT, (SUM(total_amt)/(SELECT SUM(total_amt) FROM Transactions))*100 AS PERCANTAGE_OF_SALES, 
(COUNT(CASE WHEN Qty< 0 THEN Qty ELSE NULL END)/SUM(Qty))*100 AS PERCENTAGE_OF_RETURN
FROM Transactions
INNER JOIN prod_cat_info ON prod_cat = PROD_CAT AND prod_subcat_code = PROD_SUB_CAT_CODE
GROUP BY PROD_SUBCAT
ORDER BY SUM(total_amt) DESC

====================================================================================================================================================

----Q11. For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?

SELECT cust_id,SUM(TOTAL_AMT) AS Revenue FROM Transactions
WHERE cust_id IN 
	(SELECT customer_id
	 FROM Customer
     WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
     AND CONVERT(DATE,tran_date,103) BETWEEN DATEADD(DAY,-30,(SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)) 
	 AND (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)
GROUP BY cust_id
==============================================================================================================================================================

----Q12. Which product category has seen the max value of returns in the last 3 months of transactions?

SELECT Top 1 prod_cat, SUM(total_amt) as Total_Return FROM Transactions 
INNER JOIN prod_cat_info  ON prod_cat_code = prod_cate_code AND 
                                        prod_subcat_code = prod_sub_cat_code
WHERE total_amt < 0 AND 
CONVERT(date, tran_date, 103) BETWEEN DATEADD(MONTH,-3,(SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)) 
     AND (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)
GROUP BY prod_cat
ORDER BY 2 ASC

==================================================================================================================================================

----Q13. Which store-type sells the maximum products; by value of sales amount and by quantity sold?

Alter table Transactions
ALTER column Qty float;

SELECT  Store_type, SUM(total_amt) TOT_SALES, SUM(Qty) TOT_QUAN
FROM Transactions
GROUP BY Store_type
HAVING SUM(total_amt) >=ALL (SELECT SUM(total_amt) FROM Transactions GROUP BY Store_type)
AND SUM(Qty) >=ALL (SELECT SUM(Qty) FROM Transactions GROUP BY Store_type)

====================================================================================================================================================

----Q14. What are the categories for which average revenue is above the overall average.

SELECT prod_cat, AVG(total_amt) AS Average
FROM Transactions
INNER JOIN prod_cat_info ON prod_cat_code=prod_cate_code AND prod_subcat_code=prod_sub_cat_code
GROUP BY prod_cat
HAVING AVG(total_amt)> (SELECT AVG(total_amt) FROM Transactions)

====================================================================================================================================================

----Q15. Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.

SELECT prod_cat, prod_subcat, AVG(total_amt) AS AVERAGE_REV, SUM(total_amt) AS REVENUE
FROM Transactions
INNER JOIN prod_cat_info ON prod_cat_code = prod_cate_code AND prod_subcat_code =prod_sub_cat_code
WHERE prod_cat IN
(
SELECT TOP 5 
prod_cat
FROM Transactions 
INNER JOIN prod_cat_info ON prod_cat_code= prod_cate_code AND prod_subcat_code=prod_sub_cat_code
GROUP BY prod_cat
ORDER BY SUM(Qty) DESC
)
GROUP BY prod_cat, prod_subcat




























































































================================================================================================================================

Q10. What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?


