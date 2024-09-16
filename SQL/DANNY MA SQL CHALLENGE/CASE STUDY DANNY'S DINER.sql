CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-------------------------- Bu kısımdan itibaren Case Study Soruları yer almaktadır.---------------------------------


--What is the total amount each customer spent at the restaurant?
SELECT customer_id,SUM(price) PRICE
FROM SALES S
JOIN MENU M ON S.product_id = M.product_id
GROUP BY customer_id

--How many days has each customer visited the restaurant?
SELECT customer_id,COUNT(DISTINCT order_date) AS v�s�t_day
FROM sales
GROUP BY customer_id

--What was the first item from the menu purchased by each customer?
WITH CTE_TABLO AS
(
SELECT customer_id,product_name,order_date,
RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) RNK
FROM SALES S
JOIN MENU M ON S.product_id = M.product_id
)
SELECT customer_id,product_name,order_date
FROM CTE_TABLO
WHERE RNK = 1

--What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT customer_id, product_name,COUNT(product_name) order_amount

FROM SALES S
JOIN MENU M ON S.product_id = M.product_id
WHERE product_name = 'ramen'
GROUP BY customer_id,product_name

--Which item was the most popular for each customer?
WITH CTE_TABLO AS
(
SELECT customer_id, 
		product_name,
		COUNT(product_name) order_amount,
		RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_name) DESC) RNK
FROM SALES S
JOIN MENU M ON S.product_id = M.product_id
GROUP BY customer_id, product_name
)

SELECT  customer_id, 
		product_name,
		order_amount
FROM CTE_TABLO
WHERE RNK = 1

--Which item was purchased first by the customer after they became a member?
WITH CTE_TABLO AS
(
SELECT S.customer_id,
		product_name,
		RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) RNK
FROM SALES S
JOIN MENU M ON S.product_id = M.product_id
JOIN MEMBERS MEM ON MEM.customer_id = S.customer_id
WHERE order_date >= join_date
)
SELECT customer_id,
		product_name
FROM CTE_TABLO
WHERE RNK = 1

--Which item was purchased just before the customer became a member?

WITH CTE_TABLO AS
(
SELECT S.customer_id,
		product_name,
		order_date,
		join_date,
		RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date DESC) RNK
FROM SALES S
JOIN MENU M ON S.product_id = M.product_id
JOIN MEMBERS MEM ON MEM.customer_id = S.customer_id
WHERE order_date < join_date
)
SELECT  customer_id,
		product_name
FROM CTE_TABLO
WHERE RNK = 1

--What is the total items and amount spent for each member before they became a member?
SELECT S.customer_id,
		product_name,
		COUNT(S.customer_id)
FROM SALES S
JOIN MENU M ON S.product_id = M.product_id
JOIN MEMBERS MEM ON MEM.customer_id = S.customer_id
WHERE order_date < join_date
GROUP BY S.customer_id,
		product_name
		
--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT customer_id,
		product_name,
		price,
		CASE 
			WHEN product_name = 'sushi' THEN price * 10 * 2
			ELSE price * 10 
		END
FROM SALES S
JOIN MENU M ON S.product_id = M.product_id

--In the first week after a customer joins the program (including their join date)
--they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH CTE_TABLO AS
(
SELECT S.customer_id,
		join_date AS start_date,
		DATEADD(DAY, 6, join_date) AS end_date,
		order_date,
		product_name,
		price,
		Case 
			WHEN order_date BETWEEN join_date AND DATEADD(DAY, 6, join_date) THEN price * 2*10
			WHEN product_name = 'sushi' THEN price * 20
			ELSE price * 10
			END AS POINTS
FROM SALES S
JOIN MENU M ON S.product_id = M.product_id
JOIN MEMBERS MEM ON MEM.customer_id = S.customer_id
WHERE order_date <= '2021-01-31'
)
SELECT customer_id,
		SUM(POINTS)
FROM CTE_TABLO
GROUP BY customer_id
