WITH weekly_sales AS (
    SELECT
        EXTRACT(week FROM time_id) AS week_number,
        cust_id,
        SUM(amount_sold) AS weekly_total
    FROM
        sh.sales
    WHERE
        EXTRACT(year FROM time_id) = 1999
        AND EXTRACT(week FROM time_id) IN (49, 50, 51)
    GROUP BY
        EXTRACT(week FROM time_id),
        cust_id
),
cumulative_sales AS (
    SELECT
        week_number,
        cust_id,
        SUM(weekly_total) OVER (PARTITION BY cust_id ORDER BY week_number) AS cum_sum
    FROM
        weekly_sales
),
centered_avg_sales AS (
    SELECT
        week_number,
        cust_id,
        ROUND((LAG(weekly_total, 1) OVER (PARTITION BY cust_id ORDER BY week_number) + weekly_total + LEAD(weekly_total, 1) OVER (PARTITION BY cust_id ORDER BY week_number)) / 3, 2) AS centered_3_day_avg
    FROM
        weekly_sales
)
SELECT
    ws.week_number,
    ws.cust_id,
    ws.weekly_total,
    cs.cum_sum,
    csa.centered_3_day_avg
FROM
    weekly_sales ws
JOIN
    cumulative_sales cs ON ws.week_number = cs.week_number AND ws.cust_id = cs.cust_id
JOIN
    centered_avg_sales csa ON ws.week_number = csa.week_number AND ws.cust_id = csa.cust_id
ORDER BY
    ws.week_number,
    ws.cust_id;
