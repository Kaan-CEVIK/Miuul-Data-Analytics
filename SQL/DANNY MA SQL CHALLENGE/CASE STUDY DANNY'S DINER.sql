DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

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
