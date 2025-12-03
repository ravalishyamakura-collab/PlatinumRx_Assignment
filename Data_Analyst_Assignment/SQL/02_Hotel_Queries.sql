-- Get user_id and the last booked room_no
SELECT user_id, room_no, booking_date
FROM (
    SELECT
        user_id,
        room_no,
        booking_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) AS rn
    FROM bookings
) AS x
WHERE rn = 1;

-- Booking id & total billing amount of bookings created in Nov 2021
SELECT 
    b.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM bookings b
JOIN booking_commercials bc ON bc.booking_id = b.booking_id
JOIN items i ON i.item_id = bc.item_id
WHERE b.booking_date >= '2021-11-01'
  AND b.booking_date < '2021-12-01'
GROUP BY b.booking_id
ORDER BY b.booking_id;

-- bill_id & bill amount for bills raised in Oct 2021 with amount > 1000
SELECT 
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON i.item_id = bc.item_id
WHERE bc.bill_date >= '2021-10-01'
  AND bc.bill_date < '2021-11-01'
GROUP BY bc.bill_id
HAVING bill_amount > 1000;

-- Most ordered & least ordered item per month (2021)
WITH monthly_qty AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m-01') AS month,
        bc.item_id,
        SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, bc.item_id
),
ranked AS (
    SELECT 
        month,
        item_id,
        total_qty,
        RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS rnk
    FROM monthly_qty
)
SELECT * FROM ranked WHERE rnk = 1 ORDER BY month;
WITH monthly_qty AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m-01') AS month,
        bc.item_id,
        SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, bc.item_id
),
ranked AS (
    SELECT 
        month,
        item_id,
        total_qty,
        RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS rnk
    FROM monthly_qty
)
SELECT * FROM ranked WHERE rnk = 1 ORDER BY month;

-- Customers with second-highest bill of each month (2021)
WITH bill_totals AS (
    SELECT 
        bc.bill_id,
        b.user_id,
        DATE_FORMAT(bc.bill_date, '%Y-%m-01') AS month,
        SUM(bc.item_quantity * i.item_rate) AS bill_amount
    FROM booking_commercials bc
    JOIN bookings b ON b.booking_id = bc.booking_id
    JOIN items i ON i.item_id = bc.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY bc.bill_id, b.user_id, month
),
ranked AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY month ORDER BY bill_amount DESC) AS rnk
    FROM bill_totals
)
SELECT month, bill_id, user_id, bill_amount
FROM ranked
WHERE rnk = 2
ORDER BY month;
