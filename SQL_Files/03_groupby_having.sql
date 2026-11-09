--Tier 3, Query 1: Business question: Show total revenue per month for completed orders only, sorted from the earliest month to the latest.
SELECT TO_CHAR(DATE_TRUNC('MONTH',ORDERS.ORDER_DATE), 'YYYY-MM') AS MONTHS
, SUM(ORDER_ITEMS.UNIT_PRICE *ORDER_ITEMS.QUANTITY)
AS TOTAL_REVENUE
FROM ORDERS
JOIN ORDER_ITEMS
ON ORDERS.ORDER_ID = ORDER_ITEMS.ORDER_ID

WHERE ORDERS.STATUS = 'completed'
GROUP BY DATE_TRUNC('MONTH',ORDERS.ORDER_DATE)
ORDER BY DATE_TRUNC('MONTH',ORDERS.ORDER_DATE);

--Tier 3, Query 2: Business question: For each city, show the number of distinct customers who placed completed orders and the total revenue 
--from those orders. Only include cities whose revenue is above a threshold you choose, and sort by revenue from highest to lowest.

SELECT CUSTOMERS.CITY, SUM(ORDER_ITEMS.QUANTITY * ORDER_ITEMS.UNIT_PRICE)
AS TOTAL_REVENUE,
COUNT(DISTINCT CUSTOMERS.CUSTOMER_ID)
AS NUM_OF_CUSTOMERS

FROM CUSTOMERS
JOIN ORDERS
ON CUSTOMERS.CUSTOMER_ID = ORDERS.CUSTOMER_ID

JOIN ORDER_ITEMS
ON  ORDERS.ORDER_ID = ORDER_ITEMS.ORDER_ID
WHERE ORDERS.STATUS = 'completed'
GROUP BY CUSTOMERS.CITY
HAVING SUM(ORDER_ITEMS.QUANTITY * ORDER_ITEMS.UNIT_PRICE) > 1000000
-- Cities with under 1M PKR revenue excluded as low-volume markets
ORDER BY SUM(ORDER_ITEMS.QUANTITY * ORDER_ITEMS.UNIT_PRICE) DESC;



--Tier 3, Query 3: HAVING with two conditions.
--Business question: Find products with an average rating of at least 4.0 and at least 5 reviews.
-- Show the product name, its category name, the average rating (rounded to 2 decimals) and the number of reviews, sorted by average rating from highest to lowest.

SELECT PRODUCTS.PRODUCT_ID, PRODUCTS.PRODUCT_NAME, CATEGORIES.CATEGORY_NAME, ROUND(AVG(REVIEWS.RATING),2) AS AVERAGE_RATING,
COUNT(REVIEWS.REVIEW_ID) AS NUM_OF_REVIEWS

FROM REVIEWS

JOIN PRODUCTS
ON REVIEWS.PRODUCT_ID = PRODUCTS.PRODUCT_ID

JOIN CATEGORIES
ON PRODUCTS.CATEGORY_ID = CATEGORIES.CATEGORY_ID

GROUP BY PRODUCTS.PRODUCT_ID, CATEGORIES.CATEGORY_NAME
HAVING AVG(REVIEWS.RATING) >= 4 AND COUNT(REVIEWS.REVIEW_ID) >= 5
ORDER BY AVERAGE_RATING DESC;

--Tier 3, Query 4: conditional aggregation with CASE
--Business question: For each payment method, show the number of orders paid, how many of them were returned,
-- and the return rate as a percentage (rounded to 1 decimal). Sort by return rate, highest first.

SELECT PAYMENTS.PAYMENT_METHOD,
COUNT(ORDERS.ORDER_ID)
AS ORDERS,
SUM(CASE WHEN ORDERS.STATUS = 'returned' THEN 1 ELSE 0 END)
AS RETURNED,
ROUND(SUM(CASE WHEN ORDERS.STATUS = 'returned' THEN 1 ELSE 0 END) * 100.0/ COUNT(ORDERS.ORDER_ID),1)
AS RETURN_PERCENTAGE

FROM PAYMENTS
JOIN ORDERS
ON PAYMENTS.ORDER_ID = ORDERS.ORDER_ID

GROUP BY PAYMENTS.PAYMENT_METHOD
ORDER BY SUM(CASE WHEN ORDERS.STATUS = 'returned' THEN 1 ELSE 0 END) * 100.0/ COUNT(ORDERS.ORDER_ID) DESC;
