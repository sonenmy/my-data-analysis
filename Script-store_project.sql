SELECT --таблица с данными о клиентах, связана с таблицами employees через salesRepEmployeesNumber, orders через customerNumber, payments через customerNumber
    'customers' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info ('customers')) AS number_of_attributes,
    (SELECT COUNT(*) FROM customers) AS number_of_rows
UNION ALL
SELECT --таблица с данными о моделях автомобилей, связана с таблицей productlines через productLine
    'products' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info ('products')) AS number_of_attributes,
    (SELECT COUNT(*) FROM products) AS number_of_rows
UNION ALL
SELECT --таблица с данными о категориях продуктовых линеек, связана с таблицей products через productLine
    'productlines' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info ('productlines')) AS number_of_attributes,
    (SELECT COUNT(*) FROM productlines) AS number_of_rows
UNION ALL
SELECT --таблица с данными о заказах клиентов, связана с таблицами customers через customerNumber, orderdetails через orderNumber
    'orders' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info ('orders')) AS number_of_attributes,
    (SELECT COUNT(*) FROM orders) AS number_of_rows
UNION ALL
SELECT --таблица с данными о деталях каждого заказа, связана с таблицами products через productCode, orders через orderNumber
    'orderdetails' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info ('orderdetails')) AS number_of_attributes,
    (SELECT COUNT(*) FROM orderdetails) AS number_of_rows
UNION ALL
SELECT --таблица с данными о записях о платежах клиентов, связана с таблицей customers через customerNumber
    'payments' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info ('payments')) AS number_of_attributes,
    (SELECT COUNT(*) FROM payments) AS number_of_rows
UNION ALL
SELECT --таблица с данными о сотрудниках, связана с таблицами customers через customerNumber и salesRepEmployeeNumber, offices через officeCode, сама с собой через reportsTo и employeeNumber
    'employees' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info ('employees')) AS number_of_attributes,
    (SELECT COUNT(*) FROM employees) AS number_of_rows
UNION ALL
SELECT --таблица с данными о торговых офисах, связана с таблицей employees через officeCode
    'offices' AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info ('offices')) AS number_of_attributes,
    (SELECT COUNT(*) FROM offices) AS number_of_rows

/* Вопрос 1: Какие товары следует заказывать больше или меньше? */ 
    
WITH low_stock AS (
    SELECT p.productCode, 
       ROUND(
             IFNULL(
                   (SELECT SUM(od.quantityOrdered)
                      FROM orderdetails od
                     WHERE od.productCode = p.productCode
                    ),
                    0
                    ) * 1.0 / p.quantityInStock, 
                    2
                    ) AS low_stock
      FROM products p
     GROUP BY p.productCode
     ORDER BY low_stock DESC
),
product_performance AS (
     SELECT productCode, 
            SUM(quantityOrdered*priceEach) AS product_performance
       FROM orderdetails
      GROUP BY productCode
      ORDER BY product_performance DESC
)
SELECT 
    p.productName,
    p.productLine,
    ls.low_stock,
    pp.product_performance
  FROM 
    products p
  JOIN 
    low_stock ls 
    ON p.productCode = ls.productCode
  JOIN 
    product_performance pp 
    ON p.productCode = pp.productCode
ORDER BY ls.low_stock DESC, pp.product_performance DESC 
LIMIT 10;


/* Вопрос 2. Как мы должны соотносить маркетинговые и коммуникационные стратегии с поведением клиентов? */ 

SELECT o.customerNumber, --прибыль по каждому клиенту
 	SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orders o
  JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
  JOIN products p
    ON od.productCode = p.productCode
 GROUP BY o.customerNumber

WITH profit AS ( 
			SELECT o.customerNumber, 
 					SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  			  FROM orders o
  			  JOIN orderdetails od
    			ON o.orderNumber = od.orderNumber
  			  JOIN products p
   			    ON od.productCode = p.productCode
 			 GROUP BY o.customerNumber
 			 ),
vip_customers AS ( -- Топ-5 VIP-клиентов (наибольшая прибыль)
 SELECT 'VIP' AS customer_type,
 		c.contactLastName, 
	    c.contactFirstName, 
	    c.city, 
	    c.country,
	    pr.profit
   FROM customers c 
   JOIN profit pr
     ON c.customerNumber = pr.customerNumber
  ORDER BY profit DESC
  LIMIT 5
),
low_involvement_customers AS ( -- Топ-5 менее вовлеченных клиентов (наименьшая прибыль)
SELECT 'Low Involvement' AS customer_type,
 		c.contactLastName, 
	    c.contactFirstName, 
	    c.city, 
	    c.country,
	    pr.profit
   FROM customers c 
   JOIN profit pr
     ON c.customerNumber = pr.customerNumber
  ORDER BY profit ASC
  LIMIT 5
)
SELECT *
  FROM vip_customers 
UNION ALL
SELECT *
  FROM low_involvement_customers 
ORDER BY customer_type DESC, profit DESC;

/* Вопрос 3: Сколько мы можем потратить на привлечение новых клиентов? */ 

WITH 
payment_with_year_month_table AS (
SELECT *, 
       CAST(SUBSTR(paymentDate, 1,4) AS INTEGER)*100 + CAST(SUBSTR(paymentDate, 6,7) AS INTEGER) AS year_month
  FROM payments p
),
customers_by_month_table AS (
SELECT p1.year_month, COUNT(*) AS number_of_customers, SUM(p1.amount) AS total
  FROM payment_with_year_month_table p1
 GROUP BY p1.year_month
),
new_customers_by_month_table AS (
SELECT p1.year_month, 
       COUNT(DISTINCT customerNumber) AS number_of_new_customers,
       SUM(p1.amount) AS new_customer_total,
       (SELECT number_of_customers
          FROM customers_by_month_table c
        WHERE c.year_month = p1.year_month) AS number_of_customers,
       (SELECT total
          FROM customers_by_month_table c
         WHERE c.year_month = p1.year_month) AS total
  FROM payment_with_year_month_table p1
 WHERE p1.customerNumber NOT IN (SELECT customerNumber
                                   FROM payment_with_year_month_table p2
                                  WHERE p2.year_month < p1.year_month)
 GROUP BY p1.year_month
)
SELECT year_month, 
       ROUND(number_of_new_customers*100/number_of_customers,1) AS number_of_new_customers_props,
       ROUND(new_customer_total*100/total,1) AS new_customers_total_props
  FROM new_customers_by_month_table;

/* Как видно из данных, количество новых клиентов снижается с 2003 года, 
и в 2004 году были зафиксированы самые низкие показатели. Год 2005 также присутствует в базе данных, 
но отсутствует в таблице выше, что означает отсутствие новых клиентов с сентября 2004 года. 
Это указывает на необходимость инвестиций в привлечение новых клиентов. */

WITH profit AS ( 
			SELECT o.customerNumber, 
 					SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  			  FROM orders o
  			  JOIN orderdetails od
    			ON o.orderNumber = od.orderNumber
  			  JOIN products p
   			    ON od.productCode = p.productCode
 			 GROUP BY o.customerNumber
 			 )
SELECT  ROUND(AVG(pr.profit), 2) AS ltv
FROM profit pr
/*  можно использовать для прогнозирования будущей прибыли. Например, если мы привлечем десять новых клиентов 
в следующем месяце, мы заработаем 390 395 долларов. Это поможет нам определить бюджет для привлечения новых клиентов.*/

/* вопрос 1: закзывать больше винтажные автомобили так как закупка редкая, и моттоциклы их закупка быстрая, но и сбыт быстрый
   вопрос 2: для вайпи клиентов после 2го места большой разрыв, нужно поднят именно их лояльность
   для наименее активных, котрые ипримерно в 7 раз меньше приносят прибыли, может можно составить более афордбл сегмент, если он есть
   то его им показывать
   вопрос 3: в средне клиент приносит прибыль в 40 000 что на 113 369 меньше чем средний чек у 5 топэнд
   и на 32 068 больше чем средний чек баттоменд, следовательно у нас медиана смещена ближе к концу, следует привлекать новых покупателей с топенд */

SELECT --Топ-5 самых прибыльных продуктов
    p.productCode,
    p.productName,
    SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orderdetails od
  JOIN products p 
    ON od.productCode = p.productCode
 GROUP BY p.productCode, p.productName
 ORDER BY profit DESC
 LIMIT 5;

SELECT --Анализ сезонности продаж
    STRFTIME('%Y-%m', orderDate) AS month,
    SUM(quantityOrdered * priceEach) AS monthly_sales
  FROM orders o
  JOIN orderdetails od 
    ON o.orderNumber = od.orderNumber
 GROUP BY month
 ORDER BY month;
/* в ноябре можно заметить большой всплеск прибыли, сезонность присутствует */