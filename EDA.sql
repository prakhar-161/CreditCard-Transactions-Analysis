-- Basic EDA on the dataset

SELECT * FROM credit_card_transactions;
SELECT count(1) AS no_of_rows FROM credit_card_transactions;      -- 26052

SELECT 
    COUNT(DISTINCT city) AS no_of_cities,               -- 986
    COUNT(DISTINCT card_type) AS no_of_card_types,      -- 4
    COUNT(DISTINCT exp_type) AS no_of_exp_type          -- 6
FROM credit_card_transactions;    

SELECT DISTINCT card_type FROM credit_card_transactions;    -- Silver, Signature, Gold, Platinum
SELECT DISTINCT exp_type FROM credit_card_transactions;     -- Entertainment, Food, Bills, Fuel, Travel, Grocery

SELECT min(transaction_date) AS min_tran_date, max(transaction_date) AS max_tran_date FROM credit_card_transactions;    -- Oct 2013 - May 2015

-- Total amount spent on each credit card type
SELECT card_type, SUM(amount) AS amount_per_card_type 
FROM credit_card_transactions
GROUP BY card_type
ORDER BY amount_per_card_type DESC;

-- Total amount spent by each gender
SELECT gender, SUM(CAST(amount AS DECIMAL(18,2))) AS amount_spent_by_each_gender
FROM credit_card_transactions
GROUP BY gender
ORDER by amount_spent_by_each_gender DESC;

















