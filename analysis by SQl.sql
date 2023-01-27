--- The proportion of card types
WITH a(Card_type,amount_by_card_type) AS (SELECT Card_type, SUM(Amount) FROM credit_card GROUP BY Card_type),
	b(total_amount) AS (SELECT SUM(CAST(amount_by_card_type AS BIGINT)) from a)
SELECT a.Card_type, a.amount_by_card_type, CONCAT((CAST((ROUND((CAST(a.amount_by_card_type AS decimal(20,2)) / b.total_amount *100),2)) AS decimal(5,2))),'%') AS By_percent
FROM a,b
ORDER BY 2 DESC
--- The proportion of Gender
WITH a(Gender,amount_by_Gender) AS (SELECT Gender, SUM(CAST(Amount AS BIGINT)) FROM credit_card GROUP BY Gender),
	b(total_amount) AS (SELECT SUM(CAST(amount_by_Gender AS BIGINT)) from a)
SELECT a.Gender, a.amount_by_Gender, CONCAT((CAST((ROUND((CAST(a.amount_by_Gender AS decimal(20,2)) / b.total_amount *100),2)) AS decimal(5,2))),'%') AS By_percent
FROM a,b 
ORDER BY 2 DESC
--- The transaction type
WITH a(Exp_Type,amount_by_Exp_Type) AS (SELECT Exp_Type, SUM(CAST(Amount AS BIGINT)) FROM credit_card GROUP BY Exp_Type),
	b(total_amount) AS (SELECT SUM(CAST(amount_by_Exp_Type AS BIGINT)) from a)
SELECT a.Exp_Type, a.amount_by_Exp_Type, CONCAT((CAST((ROUND((CAST(a.amount_by_Exp_Type AS decimal(20,2)) / b.total_amount *100),2)) AS decimal(5,2))),'%') AS By_percent
FROM a,b 
ORDER BY 2 DESC
--- The difference from last year
WITH a(year,amount) AS (SELECT YEAR(DATE), Amount FROM credit_card),
	b(year,amount_per_year) AS (SELECT year, SUM(CAST(amount AS bigint)) FROM a GROUP BY year),
	c(year,amount_of_year,last_year) AS (SELECT year, amount_per_year, (LAG(amount_per_year) OVER (ORDER BY year)) FROM b)
SELECT year, amount_of_year, c.last_year, 
	CAST((amount_of_year - last_year) AS decimal(20,2)) / last_year * 100 AS amt_diff, 
	(amount_of_year - last_year)/last_year AS amt_raito
FROM c
--- The transaction type over years
SELECT year(date) AS Year, Exp_Type, SUM(CAST(Amount AS BIGINT)) AS total_amt 
FROM credit_card 
GROUP BY year(date), Exp_Type
ORDER BY 1,2
--- The transaction type over years in other format
WITH a(year, Exp_Type,amount_by_Exp_Type) AS (SELECT year(date), Exp_Type, SUM(CAST(Amount AS BIGINT)) FROM credit_card GROUP BY year(date), Exp_Type),
	Travel (Year,amount_by_Exp_Type) AS (SELECT year, amount_by_Exp_Type FROM a WHERE Exp_Type = 'Travel'),
	Entertainment (Year,amount_by_Exp_Type) AS (SELECT year, amount_by_Exp_Type FROM a WHERE Exp_Type = 'Entertainment'),
	Food (Year,amount_by_Exp_Type) AS (SELECT year, amount_by_Exp_Type FROM a WHERE Exp_Type = 'Food'),
	Bills (Year,amount_by_Exp_Type) AS (SELECT year, amount_by_Exp_Type FROM a WHERE Exp_Type = 'Bills'),
	Fuel (Year,amount_by_Exp_Type) AS (SELECT year, amount_by_Exp_Type FROM a WHERE Exp_Type = 'Fuel'),
	Grocery (Year,amount_by_Exp_Type) AS (SELECT year, amount_by_Exp_Type FROM a WHERE Exp_Type = 'Grocery')
SELECT Travel.year, 
	Travel.amount_by_Exp_Type AS Travel, 
	Entertainment.amount_by_Exp_Type AS Entertainment, 
	Food.amount_by_Exp_Type AS Food, 
	Bills.amount_by_Exp_Type AS Bills, 
	Fuel.amount_by_Exp_Type AS Fuel, 
	Grocery.amount_by_Exp_Type AS Grocery
FROM Travel
JOIN Entertainment
ON Travel.year = Entertainment.year
JOIN Food
ON Entertainment.year = Food.Year
JOIN Bills
ON Bills.year = Food.Year
JOIN Fuel
ON Bills.year = Fuel.Year
JOIN Grocery
ON Grocery.year = Fuel.Year
