SELECT SUM(total) AS overall_sale
  FROM invoice;

SELECT AVG(total) AS avg_sale
  FROM invoice;

SELECT MIN(total) AS min_sale
  FROM invoice;

SELECT MAX(billing_country) AS last_billing_country
  FROM invoice;

SELECT COUNT(*) AS num_row
  FROM invoice;

SELECT COUNT(composer ) AS num_track_composer 
  FROM track;

SELECT SUM(milliseconds / 1000.0 / 60) AS total_runtime_minutes
  FROM track
 WHERE unit_price = 1.99;

SELECT MIN(milliseconds) AS min_runtime, MAX(milliseconds) AS max_runtime, COUNT(*) AS num_row 
  FROM track;

SELECT AVG(milliseconds / 1000.0/ 60) AS avg_runtime_minutes, AVG(bytes / 1024.0 / 1024) AS avg_size_megabyte
  FROM track;

SELECT AVG(milliseconds / 1000.0 / 60) AS avg_runtime_minutes
  FROM track;

SELECT ROUND(AVG(milliseconds / 1000.0 / 60), 2) AS avg_runtime_minutes_rounded
  FROM track;

SELECT SUM(total) / COUNT(total) AS avg_total
  FROM track;

SELECT SUM(milliseconds / 1000.0 / 60) AS total_runtime_minutes
  FROM track
 WHERE unit_price = 1.99;

SELECT COUNT(total) AS num_row, MIN(total) AS min_total, MAX(total) AS max_total, ROUND(AVG(total), 2) AS avg_total_rounded
  FROM invoice 
 WHERE total > 10;

SELECT COUNT(*) AS num_row
  FROM invoice 
 WHERE billing_country = 'USA';

SELECT billing_country, COUNT(*) AS num_row
 FROM invoice 
 GROUP BY billing_country;

SELECT invoice_id, SUM(unit_price * quantity) AS total
  FROM invoice_line
 GROUP BY invoice_id
 LIMIT 5;

SELECT billing_state, COUNT(*) AS num_row, AVG(total) AS avg_sale
  FROM invoice
 WHERE billing_country = 'USA'
 GROUP BY billing_state;

SELECT track_id, COUNT(*) AS num_row, SUM(unit_price * quantity) AS overall_sale
 FROM invoice_line 
 GROUP BY track_id
 ORDER BY overall_sale DESC, num_row DESC
 LIMIT 5;

SELECT billing_city, COUNT(*) AS num_row, SUM(total) AS overall_sale, MIN(total) AS min_sale, AVG(total) AS avg_sale, MAX(total) AS max_sale
  FROM invoice
 WHERE billing_country = 'France'OR 'Canada'
 GROUP BY billing_city
 ORDER BY num_row DESC
 LIMIT 3;

SELECT billing_country, billing_state, COUNT(*) AS num_row, AVG(total) AS avg_sale 
 FROM invoice
 GROUP BY billing_country, billing_state;

SELECT billing_country, billing_state, COUNT(*) AS num_row, AVG(total) AS avg_sale 
 FROM invoice
 GROUP BY billing_country, billing_state
 HAVING COUNT(*) > 40;

SELECT billing_country, billing_state, MIN(total) AS min_sale, MAX(total) AS max_sale
  FROM invoice
 GROUP BY billing_country, billing_state
HAVING AVG(total) < 10;

SELECT billing_country, billing_state, MIN(total) AS min_sale, MAX(total) AS max_sale
  FROM invoice
  WHERE billing_state <> 'None'
 GROUP BY billing_country, billing_state
HAVING AVG(total) < 10;

SELECT *
  FROM invoice_line
 INNER JOIN track
    ON invoice_line.track_id = track.track_id;

SELECT album.album_id, album.title, artist.artist_id, artist.name
 FROM album
 JOIN artist
 ON album.artist_id = artist.artist_id;

SELECT t.track_id, t.name AS track_name, t.composer, g.name AS genre
  FROM track AS t
  JOIN genre AS g
    ON t.genre_id = g.genre_id

SELECT *
  FROM invoice_line AS i
  JOIN track AS t
    ON i.track_id = t.track_id
 WHERE i.invoice_id = 19;

SELECT g.genre_id AS genre, COUNT(t.track_id) AS num_of_tracks
  FROM genre AS g
  JOIN track AS t
    ON g.genre_id = t.genre_id
 GROUP BY genre;

SELECT il.track_id, il.unit_price,
       t.name,
       mt.name AS media_type
  FROM invoice_line AS il
  JOIN track AS t
    ON t.track_id = il.track_id
  JOIN media_type AS mt
    ON t.media_type_id = mt.media_type_id;

SELECT i.invoice_id, e.first_name
  FROM invoice AS i
  JOIN customer AS c
    ON i.customer_id = c.customer_id
  JOIN employee AS e
    ON e.employee_id = c.support_rep_id
 GROUP BY  i.invoice_id, e.first_name;

SELECT e1.first_name || " " || e1.last_name AS employee,
       e2.first_name || " " || e2.last_name AS manager
  FROM employee AS e1
  JOIN employee AS e2
    ON e1.reports_to = e2.employee_id;

SELECT e1.first_name || " " || e1.last_name AS employee,
       e2.first_name || " " || e2.last_name AS manager
  FROM employee AS e1
  LEFT JOIN employee AS e2
    ON e1.reports_to = e2.employee_id;

SELECT c1.first_name, c1.last_name, c1.email, 
       c2.first_name, c2.last_name, c2.email 
  FROM customer AS c1
 CROSS JOIN customer AS c2
 WHERE ( c1.first_name, c1.last_name, c1.email ) <> (c2.first_name, c2.last_name, c2.email); 

SELECT t.track_id, t.name, COUNT(il.invoice_line_id) AS no_of_purchases
  FROM track AS t
  LEFT JOIN invoice_line AS il
    ON t.track_id = il.track_id
  LEFT JOIN invoice AS i
    ON i.invoice_id = il.invoice_id AND i.invoice_date BETWEEN '2020-01-01 00:00:00' AND '2020-12-31 00:00:00'
 GROUP BY t.track_id, t.name
 ORDER BY no_of_purchases DESC;

SELECT i1.invoice_id, i1.invoice_date, i1.total,
       ROUND((SELECT SUM(i2.total) 
                FROM invoice i2 
               WHERE i2.invoice_date < i1.invoice_date 
                  OR (i2.invoice_date = i1.invoice_date AND i2.invoice_id <= i1.invoice_id)), 2) AS running_total
  FROM invoice i1
  JOIN invoice i2
    ON i1.invoice_id >= i2.invoice_id
 GROUP BY i1.invoice_id;

SELECT *
 FROM invoice
 WHERE invoice_date BETWEEN '2017-01-01 00:00:00' AND '2018-06-30 00:00:00'
 UNION
 SELECT *
 FROM invoice
WHERE invoice_date BETWEEN '2018-01-01 00:00:00' AND '2018-12-31 00:00:00';

SELECT  invoice_id, customer_id, invoice_date, total
  FROM invoice
 WHERE invoice_date BETWEEN '2017-01-01 00:00:00' AND '2018-06-30 00:00:00'
 UNION ALL
 SELECT  invoice_id, customer_id, invoice_date, total
  FROM invoice
 WHERE invoice_date BETWEEN '2018-01-01 00:00:00' AND '2018-12-31 00:00:00';

SELECT *
  FROM invoice
 WHERE invoice_date BETWEEN '2017-01-01 00:00:00' AND '2018-06-30 00:00:00'
 INTERSECT
 SELECT *
   FROM invoice
  WHERE invoice_date BETWEEN '2018-01-01 00:00:00' AND '2018-12-31 00:00:00';

SELECT *
  FROM invoice
 WHERE invoice_date BETWEEN '2017-01-01 00:00:00' AND '2018-06-30 00:00:00'
EXCEPT
SELECT *
  FROM invoice
 WHERE invoice_date BETWEEN '2018-01-01 00:00:00' AND '2018-12-31 00:00:00'
 ORDER BY invoice_date DESC;

SELECT * 
  FROM track
 WHERE milliseconds > 60000
 INTERSECT 
 SELECT *
  FROM track
 WHERE milliseconds < 120000;

SELECT billing_country, 
       ROUND(COUNT(*)*100.0/
             (SELECT COUNT(*) 
                FROM invoice), 2)  AS sales_prop
  FROM invoice
 GROUP BY billing_country
 ORDER BY sales_prop DESC
 LIMIT 5;

SELECT customer_id, ROUND(COUNT(*)*100.0/
                          (SELECT COUNT(*) 
                             FROM invoice),2) AS sales_prop
  FROM invoice
 GROUP BY customer_id
 ORDER BY sales_prop DESC 
 LIMIT 5;

SELECT billing_country , ROUND(COUNT(total)*100.0/
                          (SELECT SUM(total) 
                             FROM invoice),2) AS country_share
  FROM invoice
 GROUP BY billing_country 
 ORDER BY country_share DESC 
 LIMIT 5;

SELECT COUNT(*) AS rows_tally 
  FROM invoice 
 WHERE total > (SELECT AVG(total) AS total_avg 
                  FROM invoice);

SELECT COUNT(*) AS rows_tally
  FROM invoice
 WHERE total > (SELECT MAX(total)*0.75
                  FROM invoice);

SELECT customer_id, AVG(total) AS  customer_avg
  FROM invoice
 GROUP BY customer_id
HAVING AVG(total) > (SELECT AVG(total)
                       FROM invoice 
                      WHERE customer_id = 5)

SELECT COUNT(*) AS tracks_tally
 FROM track
 WHERE media_type_id IN (SELECT media_type_id
                           FROM media_type
                          WHERE name LIKE '%MPEG%');

SELECT *
 FROM invoice
 WHERE customer_id IN (SELECT customer_id
                           FROM customer
                          WHERE first_name LIKE 'A%');

SELECT first_name, last_name
  FROM customer
 WHERE customer_id NOT IN (SELECT customer_id
                             FROM invoice
                            GROUP BY customer_id
                           HAVING SUM(total) < 100);

SELECT AVG(billing_city_max) AS billing_city_max_avg
  FROM (SELECT billing_city, MAX(total) AS billing_city_max
          FROM invoice
         GROUP BY billing_city);

SELECT c.last_name, c.first_name, i.total_avg
  FROM customer AS c
  JOIN (
       SELECT customer_id, AVG(total) AS total_avg 
         FROM invoice
        GROUP BY customer_id) AS i
           ON c.customer_id = i.customer_id;

SELECT i.billing_country AS country, i.invoice_tally / ct.customer_tally AS sale_avg_tally
  FROM (SELECT billing_country, COUNT(*) AS invoice_tally
          FROM invoice
         GROUP BY billing_country) AS i
  JOIN (SELECT country, COUNT(*) AS customer_tally
          FROM customer
         GROUP BY country) AS ct
   ON ct.country = i.billing_country
   ORDER BY sale_avg_tally DESC;

SELECT last_name, 
       first_name, 
       (SELECT AVG(total)
          FROM invoice i
         WHERE c.customer_id = i.customer_id) total_avg
  FROM customer c;

SELECT last_name,  first_name,  total_avg
  FROM customer c
  JOIN (SELECT customer_id, AVG(total) AS total_avg
          FROM invoice
         GROUP BY customer_id) i
    ON c.customer_id = i.customer_id;

SELECT track_id, name
  FROM track t
 WHERE NOT EXISTS(SELECT *
                FROM invoice_line i
               WHERE t.track_id = i.track_id);

SELECT e.first_name, e.last_name
  FROM employee e
 WHERE e.employee_id IN (SELECT c.support_rep_id
                         FROM customer c
                        WHERE c.customer_id IN (SELECT i.customer_id
                                             FROM invoice i

                                            WHERE i.total > 100 AND c.support_rep_id IS NOT NULL));

SELECT il.invoice_id,
    SUM(il.quantity * il.unit_price) AS total,
    SUM(tr.milliseconds) / 1000.0/ 60 AS minutes
  FROM invoice_line il
  JOIN track tr
    ON il.track_id = tr.track_id
 WHERE invoice_id IN (SELECT invoice_id 
                        FROM invoice
                       WHERE billing_country = 'USA') AND 
                                   tr.genre_id IN (SELECT genre_id
                                                     FROM genre 
                                                    WHERE name LIKE '%Metal%')
 GROUP BY il.invoice_id
HAVING SUM(il.quantity * il.unit_price) > 0 AND SUM(tr.milliseconds) > 0;

SELECT AVG(billing_city_tally) AS billing_country_tally_avg
  FROM (SELECT billing_city, COUNT(*) AS billing_city_tally
          FROM invoice
         GROUP BY billing_city);

WITH
city_sales_table AS (
SELECT billing_city, COUNT(*) AS billing_city_tally
  FROM invoice
 GROUP BY billing_city
)
SELECT AVG(billing_city_tally) AS billing_country_tally_avg
  FROM city_sales_table;

SELECT c.last_name, c.first_name, i.total_avg
  FROM customer AS c
  JOIN (SELECT customer_id, AVG(total) AS total_avg
          FROM invoice
         GROUP BY customer_id) AS i
    ON c.customer_id = i.customer_id;

WITH 
customer_avg_table AS ( 
SELECT c.last_name, c.first_name, c.customer_id, AVG(i.total) AS total_avg
  FROM invoice AS i
  JOIN customer AS c 
    ON i.customer_id = c.customer_id
 GROUP BY c.customer_id, c.last_name, c.first_name
)
SELECT last_name, first_name, total_avg
  FROM customer_avg_table;

SELECT ct.country, 
        ROUND(i.invoice_total / ct.customer_tally, 2) AS sale_avg
   FROM (SELECT billing_country, SUM(total) AS invoice_total
           FROM invoice
          GROUP BY billing_country) AS i
   JOIN (SELECT country, COUNT(*) AS customer_tally
           FROM customer
          GROUP BY country) AS ct
     ON i.billing_country = ct.country
  ORDER BY sale_avg DESC
  LIMIT 5;

WITH 
country_invoice_total_table AS (
SELECT billing_country, SUM(total) AS invoice_total
           FROM invoice
          GROUP BY billing_country
),
country_total_table AS (
SELECT country, COUNT(*) AS customer_tally
  FROM customer
 GROUP BY country
)
SELECT ct.country, ROUND(cit.invoice_total / ct.customer_tally, 2) AS sale_avg
  FROM country_invoice_total_table cit
  JOIN country_total_table ct
    ON cit.billing_country   = ct.country
 ORDER BY sale_avg DESC
 LIMIT 5;

WITH RECURSIVE
under_adams_table(employee_id, last_name, first_name, path) AS (
  SELECT 1, 'Adams', 'Andrew', 'Adams Andrew' AS path

 UNION ALL

  SELECT e.employee_id,
         e.last_name,
         e.first_name,
         u.path || '<--' || e.last_name || ' ' || e.first_name AS path
    FROM employee e
    JOIN under_adams_table u
      ON e.reports_to = u.employee_id
)
SELECT path
  FROM under_adams_table;






