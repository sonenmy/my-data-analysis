SELECT * FROM pragma_table_info('ksprojects');-- Выведите названия и типы данных для каждой таблицы в базе данных.

SELECT main_category, goal, backers, pledged -- Jценить результат проекта, основываясь на его основной категории, сумме средств, установленной как цель, количестве спонсоров и сумме собранных средств. Верните только первые 10 строк.
  FROM ksprojects
 LIMIT 10;

SELECT main_category, goal, backers, pledged -- Отфильтруем данные, оставив только записи, где state проекта равен 'failed', 'canceled' или 'suspended'.
  FROM ksprojects
 WHERE state = 'failed' OR 'canceled' OR 'suspended'
 LIMIT 10; 

SELECT main_category, goal, backers, pledged -- Проекты, которые не были успешными.
  FROM ksprojects
 WHERE (state = 'failed' OR 'canceled' OR 'suspended') AND backers > 100 AND pledged > 20000
 LIMIT 10; 

SELECT main_category, goal, backers, pledged, pledged/goal AS pct_pledged -- Проекты по категориям вместе с процентом финансирования цели.
  FROM ksprojects 
  WHERE state = 'failed'
  ORDER BY main_category, pct_pledged DESC
  LIMIT 10;

SELECT main_category, goal, backers, pledged, pledged/goal AS pct_pledged, --Создайте поле funding_status
       CASE
       WHEN pledged/goal >= 1 THEN 'Fully funded'
       WHEN pledged/goal BETWEEN 0.75 AND 1 THEN 'Nearly funded'
       ELSE 'Not nearly funded'
       END AS funding_status
  FROM ksprojects 
  WHERE state = 'failed'
  LIMIT 10; -- проекты терпят неудачу из-за отсутствия спонсоров и финансирования
  
SELECT main_category, ROUND(AVG(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) * 100, 1) AS success_rate, AVG(pledged) AS avg_pledged -- В каких категориях самый высокий процент успеха и средние сборы.
  FROM ksprojects
 GROUP BY main_category
 ORDER BY success_rate DESC
 LIMIT 10;

SELECT state, ROUND(AVG(backers),2) AS avg_backers, ROUND(AVG(goal),2) AS avg_goal,
ROUND(AVG(pledged),2) AS avg_pledged, ROUND(AVG(pledged/goal),2) AS avg_pct_pledged -- Сколько спонсоров, какая цель, какая сумма собрана, какая доля собрана в среднем для разных проектов 
FROM ksprojects
GROUP BY state;