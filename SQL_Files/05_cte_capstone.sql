--Tier 5, Query 1, business question: Split customers into four spend groups (quartiles) based on their total completed-order spend,
--so the top 25% of spenders are group 1. Show each group’s customer count, total spend, and its share of overall revenue.

WITH CUSTOMER_SPEND AS (
SELECT CUSTOMERS.CUSTOMER_ID, CUSTOMERS.FULL_NAME,
SUM(ORDER_ITEMS.QUANTITY * ORDER_ITEMS.UNIT_PRICE) AS TOTAL_SPENT

FROM CUSTOMERS
JOIN ORDERS
ON CUSTOMERS.CUSTOMER_ID = ORDERS.CUSTOMER_ID
JOIN ORDER_ITEMS
ON ORDER_ITEMS.ORDER_ID = ORDERS.ORDER_ID

WHERE
ORDERS.STATUS = 'completed'
GROUP BY CUSTOMERS.CUSTOMER_ID, CUSTOMERS.FULL_NAME
),

SPEND_GROUPS AS (SELECT  CUSTOMER_ID, FULL_NAME, TOTAL_SPENT,
NTILE(4) OVER (ORDER BY TOTAL_SPENT DESC ) AS SPEND_GROUP
FROM CUSTOMER_SPEND)

SELECT SPEND_GROUP,
COUNT(*) AS NUM_CUSTOMERS,
SUM(TOTAL_SPENT) AS GROUP_SPEND,
ROUND(SUM(TOTAL_SPENT) * 100.0 / SUM(SUM(TOTAL_SPENT)) OVER (), 1) AS PCT_OF_REVENUE
FROM SPEND_GROUPS
GROUP BY SPEND_GROUP
ORDER BY SPEND_GROUP;


--Tier 5, Query 2: do Prime members spend more?

--Business question: Compare Prime customers (anyone who has ever had a subscription) with non-Prime customers:
--how many customers in each group, average orders per customer, average spend per customer, and average order value.

WITH CUSTOMER_STATS AS (
SELECT CUSTOMERS.CUSTOMER_ID,COUNT(DISTINCT ORDERS.ORDER_ID) AS NUM_ORDERS,
SUM(ORDER_ITEMS.QUANTITY * ORDER_ITEMS.UNIT_PRICE) AS TOTAL_SPENT

FROM CUSTOMERS
JOIN ORDERS
ON CUSTOMERS.CUSTOMER_ID = ORDERS.CUSTOMER_ID
JOIN ORDER_ITEMS
ON ORDER_ITEMS.ORDER_ID = ORDERS.ORDER_ID

WHERE
ORDERS.STATUS = 'completed'
GROUP BY CUSTOMERS.CUSTOMER_ID
),

PRIME_CUSTOMERS AS (
SELECT DISTINCT CUSTOMER_ID
FROM CUSTOMER_SUBSCRIPTIONS
),
LABELLED AS(
SELECT customer_stats.customer_id,
       customer_stats.num_orders,
       customer_stats.total_spent,
	   CASE WHEN prime_customers.customer_id IS NOT NULL THEN 'Prime'
            ELSE 'Non-Prime' END AS member_type
FROM customer_stats
LEFT JOIN prime_customers
ON customer_stats.customer_id = prime_customers.customer_id)

SELECT MEMBER_TYPE,
       COUNT(CUSTOMER_ID) AS CUSTOMER_COUNT,
       ROUND(AVG(num_orders), 1) AS avg_orders,
       ROUND(AVG(total_spent)) AS avg_spend,
       ROUND(SUM(total_spent) / SUM(num_orders)) AS avg_order_value
	   FROM LABELLED
	   GROUP BY MEMBER_TYPE;

--Tier 5, Query 3: customer churn risk.

--Business question: Segment customers by how long it’s been since their last completed order:
-- Active (90 days or fewer), At Risk (91 to 180 days), Lapsed (over 180 days). For each segment, show the number of customers and their total historical spend.

WITH LAST_ORDERS AS(
SELECT CUSTOMERS.CUSTOMER_ID, MAX(ORDERS.ORDER_DATE) AS LAST_ORDER_DATE,
COUNT(DISTINCT ORDERS.ORDER_ID) AS NUM_ORDERS,
SUM(ORDER_ITEMS.QUANTITY * ORDER_ITEMS.UNIT_PRICE) AS TOTAL_SPENT
FROM CUSTOMERS
JOIN ORDERS
ON CUSTOMERS.CUSTOMER_ID = ORDERS.CUSTOMER_ID
JOIN ORDER_ITEMS
ON ORDERS.ORDER_ID = ORDER_ITEMS.ORDER_ID
WHERE ORDERS.STATUS = 'completed'
GROUP BY CUSTOMERS.CUSTOMER_ID
),
SEGMENTED AS (
    SELECT customer_id,
           total_spent,
           DATE '2025-12-31' - LAST_ORDER_DATE AS DAYS_SINCE_LAST_ORDER,
		   CASE WHEN DATE '2025-12-31' - LAST_ORDER_DATE <= 90 THEN'ACTIVE'
		   		WHEN DATE '2025-12-31' - LAST_ORDER_DATE <= 180 THEN 'AT RISK'
				ELSE 'LAPSED'
				END AS SEGMENT
			FROM LAST_ORDERS)

SELECT SEGMENT, COUNT(DISTINCT CUSTOMER_ID), SUM(TOTAL_SPENT)
FROM SEGMENTED
GROUP BY SEGMENT