SELECT * FROM credit_card_transactions;

-- 1. Write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
WITH total_spend_per_city AS (
    SELECT city, SUM(amount) AS total_spend
    FROM credit_card_transactions
    GROUP BY city
),
total_amount_spent AS (
    SELECT SUM(CAST(amount AS BIGINT)) AS total_amount
    FROM credit_card_transactions
)

SELECT TOP 5 total_spend_per_city.*, ROUND((total_spend*1.0/total_amount*100),2) as percent_contribution
FROM total_spend_per_city 
INNER JOIN total_amount_spent ON 1=1
ORDER BY total_spend DESC;


-- 2. Write a query to print highest spend month and amount spent in that month for each card type
WITH cte AS (
    SELECT card_type, 
    DATEPART(year, transaction_date) AS yr,
    DATEPART(month, transaction_date) AS mnth,
    SUM(amount) AS amount_spend
    FROM credit_card_transactions
    GROUP BY card_type, DATEPART(year, transaction_date), DATEPART(month, transaction_date)
)
SELECT * FROM (
    SELECT *, RANK() OVER(PARTITION BY card_type ORDER BY amount_spend DESC) AS rn from cte
) a WHERE rn=1;


-- 3. Write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1,000,000 total spends(We should have 4 rows in the o/p one for each card type)
WITH cte AS (
    SELECT *, SUM(amount) OVER(PARTITION BY card_type ORDER BY transaction_date, transaction_id ASC) AS total_spend
    FROM credit_card_transactions
)

SELECT * FROM (
    SELECT *, RANK() OVER(PARTITION BY card_type ORDER BY total_spend ASC) AS rn  
    FROM cte WHERE total_spend >= 1000000) a
WHERE rn = 1;


-- 4. write a query to find city which had lowest percentage spend for gold card type
-- each city has done some spend on different card type
WITH cte AS (
    SELECT city, card_type, 
    SUM(amount) AS amount,
    SUM(CASE WHEN card_type='Gold' THEN amount END) AS gold_amount
    FROM credit_card_transactions 
    GROUP BY city, card_type
)

SELECT TOP 1 city, SUM(gold_amount)*1.0/SUM(amount) AS gold_ratio
FROM cte
GROUP BY city
HAVING SUM(gold_amount) IS NOT NULL
ORDER BY gold_ratio;


-- 5. write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
SELECT DISTINCT exp_type FROM credit_card_transactions;

WITH cte AS (
    SELECT city, exp_type, SUM(amount) AS total_amount FROM credit_card_transactions
    GROUP BY city, exp_type
)

SELECT city,
MAX(CASE WHEN rn_asc = 1 THEN exp_type END) AS lowest_expense_type,
MIN(CASE WHEN rn_desc = 1 THEN exp_type END) AS hightest_expense_type
FROM 
(
    SELECT *, 
    RANK() OVER(PARTITION BY city ORDER BY total_amount DESC) rn_desc,
    RANK() OVER(PARTITION BY city ORDER BY total_amount ASC) rn_asc
    FROM cte
) A
GROUP BY city;

-- 6. write a query to find percentage contribution of spends by females for each expense type
SELECT exp_type, 
SUM(CASE WHEN gender='F' THEN amount ELSE 0 END)*1.0/SUM(amount) AS percent_female_contribution 
FROM credit_card_transactions
GROUP BY exp_type
ORDER BY percent_female_contribution;

-- 7. which card and expense type combination saw highest month over month growth in Jan-2014
with cte as (
select card_type,exp_type,datepart(year,transaction_date) yt
,datepart(month,transaction_date) mt,sum(amount) as total_spend
from credit_card_transcations
group by card_type,exp_type,datepart(year,transaction_date),datepart(month,transaction_date)
)
select  top 1 *, (total_spend-prev_mont_spend) as mom_growth
from (
select *
,lag(total_spend,1) over(partition by card_type,exp_type order by yt,mt) as prev_mont_spend
from cte) A
where prev_mont_spend is not null and yt=2014 and mt=1
order by mom_growth desc;

--8- during weekends which city has highest total spend to total no of transcations ratio 
select top 1 city , sum(amount)*1.0/count(1) as ratio
from credit_card_transcations
where datepart(weekday,transaction_date) in (1,7)
--where datename(weekday,transaction_date) in ('Saturday','Sunday')
group by city
order by ratio desc;

--9- which city took least number of days to reach its
--500th transaction after the first transaction in that city;
with cte as (
select *
,row_number() over(partition by city order by transaction_date,transaction_id) as rn
from credit_card_transcations)
select top 1 city,datediff(day,min(transaction_date),max(transaction_date)) as datediff1
from cte
where rn=1 or rn=500
group by city
having count(1)=2
order by datediff1;
