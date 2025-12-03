-- Revenue from each sales_channel for a given year
SELECT 
    sales_channel,
    SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel
ORDER BY revenue DESC;

-- Top 10 most valuable customers for the year
SELECT 
    cs.uid,
    c.name,
    SUM(cs.amount) AS total_spent
FROM clinic_sales cs
JOIN customer c ON c.uid = cs.uid
WHERE YEAR(cs.datetime) = 2021
GROUP BY cs.uid, c.name
ORDER BY total_spent DESC
LIMIT 10;

-- Month-wise revenue, expense, profit, and status
WITH rev AS (
    SELECT 
        DATE_FORMAT(datetime, '%Y-%m-01') AS month,
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY month
),
exp AS (
    SELECT 
        DATE_FORMAT(datetime, '%Y-%m-01') AS month,
        SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY month
)
SELECT 
    IFNULL(r.month, e.month) AS month,
    IFNULL(r.revenue, 0) AS revenue,
    IFNULL(e.expense, 0) AS expense,
    (IFNULL(r.revenue, 0) - IFNULL(e.expense, 0)) AS profit,
    CASE 
        WHEN (IFNULL(r.revenue, 0) - IFNULL(e.expense, 0)) > 0 THEN 'profitable'
        ELSE 'not-profitable'
    END AS status
FROM rev r
LEFT JOIN exp e ON r.month = e.month
UNION
SELECT 
    e.month,
    r.revenue,
    e.expense,
    (r.revenue - e.expense),
    CASE WHEN (r.revenue - e.expense) > 0 THEN 'profitable' ELSE 'not-profitable' END
FROM exp e
LEFT JOIN rev r ON r.month = e.month
ORDER BY month;

-- Most profitable clinic per city in a month
WITH sales AS (
    SELECT cid, SUM(amount) AS revenue
    FROM clinic_sales
    WHERE datetime >= '2021-09-01'
      AND datetime < '2021-10-01'
    GROUP BY cid
),
exp AS (
    SELECT cid, SUM(amount) AS expense
    FROM expenses
    WHERE datetime >= '2021-09-01'
      AND datetime < '2021-10-01'
    GROUP BY cid
),
profit AS (
    SELECT 
        c.cid,
        c.clinic_name,
        c.city,
        IFNULL(s.revenue, 0) - IFNULL(e.expense, 0) AS profit
    FROM clinics c
    LEFT JOIN sales s ON s.cid = c.cid
    LEFT JOIN exp e ON e.cid = c.cid
)
SELECT city, cid, clinic_name, profit
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY city ORDER BY profit DESC) AS rn
    FROM profit
) x
WHERE rn = 1;

-- Second least profitable clinic per state
WITH profit AS (
    SELECT 
        c.cid,
        c.clinic_name,
        c.state,
        IFNULL(s.revenue, 0) - IFNULL(e.expense, 0) AS profit
    FROM clinics c
    LEFT JOIN (
        SELECT cid, SUM(amount) AS revenue
        FROM clinic_sales
        WHERE datetime >= '2021-09-01'
          AND datetime < '2021-10-01'
        GROUP BY cid
    ) s ON s.cid = c.cid
    LEFT JOIN (
        SELECT cid, SUM(amount) AS expense
        FROM expenses
        WHERE datetime >= '2021-09-01'
          AND datetime < '2021-10-01'
        GROUP BY cid
    ) e ON e.cid = c.cid
)
SELECT state, cid, clinic_name, profit
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY state ORDER BY profit ASC) AS rn
    FROM profit
) x
WHERE rn = 2;
