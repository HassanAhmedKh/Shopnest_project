--Tier 2, Query 2 — business question: Find all customers who have never placed an order.

SELECT PRODUCT_NAME, PRICE
FROM PRODUCTS
WHERE PRICE > (SELECT AVG(PRODUCTS.PRICE) FROM PRODUCTS);

--Tier 2, Query 2 — business question: Find all customers who have never placed an order.
SELECT FULL_NAME
FROM CUSTOMERS
WHERE CUSTOMER_ID NOT IN (SELECT CUSTOMER_ID FROM ORDERS);

-- Tier 2, Query 3 — business question: Find the names and cities of customers who have placed at
-- least one order with a total value (sum of quantity × unit_price across that order’s items) greater than 10,000 PKR.
SELECT DISTINCT CUSTOMERS.FULL_NAME, CUSTOMERS.CITY
FROM CUSTOMERS

JOIN ORDERS
ON CUSTOMERS.CUSTOMER_ID = ORDERS.CUSTOMER_ID

WHERE ORDERS.ORDER_ID IN (
SELECT ORDER_ID
FROM ORDER_ITEMS
GROUP BY ORDER_ID
HAVING SUM(ORDER_ITEMS.QUANTITY * ORDER_ITEMS.UNIT_PRICE) > 10000
);

--Tier 2, Query 4: a correlated subquery Find all products priced higher than the average price of their own category.
SELECT PRODUCT_NAME, CATEGORY_ID, PRICE
FROM PRODUCTS P1
WHERE PRICE > (
SELECT AVG(PRICE)
FROM PRODUCTS P2
WHERE P2.CATEGORY_ID  = P1.CATEGORY_ID
);

--Tier 2, Query 5: Business question: Redo Tier 2 Q2 (customers who have never placed an order), but using NOT EXISTS instead of NOT IN
SELECT FULL_NAME
FROM CUSTOMERS C
WHERE NOT EXISTS (
SELECT 1
FROM ORDERS O
WHERE O.CUSTOMER_ID = C.CUSTOMER_ID
);