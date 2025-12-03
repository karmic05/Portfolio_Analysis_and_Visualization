USE invest;

SELECT * 
FROM customer_details
WHERE full_name = 'Paul Bistre';
-- customer_id for Paul Bistre is 148

-- Getting all information related to Paul Bistre across all tables and creating a VIEW out of it

CREATE VIEW Jainam_Gogree_Final AS 
SELECT
    cd.full_name AS `Client Name`,
    cd.customer_id AS `Customer ID`,
    ad.account_id AS `Account ID`,
    sm.major_asset_class AS `Major Asset Class`,
    sm.minor_asset_class AS `Minor Asset Class`,
    sm.security_name AS `Security Name`,
    sm.sec_type AS `Security Type`,
    hc.ticker AS `Ticker`,
    pd.date AS `Date`,
    hc.quantity AS `Quantity`,
    pd.value AS `Price`,
    LAG(pd.value, 1) 
			OVER(
				PARTITION BY pd.ticker
				ORDER BY 
					pd.date) AS `Initial Price`,
    pd.price_type AS `Price Type`,
    (hc.value * hc.quantity) AS `Total Value`
FROM 
    customer_details as cd 
LEFT JOIN 
    invest.account_dim AS ad 
    ON cd.customer_id = ad.client_id
LEFT JOIN 
    invest.holdings_current AS hc 
    ON ad.account_id = hc.account_id
LEFT JOIN 
    invest.security_masterlist AS sm 
    ON hc.ticker = sm.ticker
LEFT JOIN 
    invest.pricing_daily_new AS pd ON 
    hc.ticker = pd.ticker 
WHERE 
    cd.full_name = 'Paul Bistre'
;


-- 1.1 Calculating 12M Rate of Return

SELECT a.*, LN(a.P1/a.P0) * 100 AS `Rate of Return(%)`
FROM 
	(SELECT 
		`Ticker`, 
        `Security Name`,
        `Security Type`,
        `Major Asset Class`,
        `Minor Asset Class`,
		`Date`, 
		`Price` AS P1,
		LAG(`Price`, 250) 
			OVER(
				PARTITION BY `Ticker`
				ORDER BY 
					`Date`) AS P0,
		`Total Value`
	FROM 
		Jainam_Gogree_Final
	WHERE
		`Date` >= '2021-09-09'
		AND 
		`Price Type` = 'Adjusted') AS a
;


-- 1.2 Calculating 18M Rate of Return

SELECT a.*, LN(a.P1/a.P0) * 100 AS `Rate of Return(%)`
FROM 
	(SELECT 
		`Ticker`,
        `Security Name`,
        `Security Type`,
        `Major Asset Class`,
        `Minor Asset Class`,
		`Date`, 
		`Price` AS P1,
		LAG(`Price`, 376) 
			OVER(
				PARTITION BY `Ticker`
				ORDER BY 
					date) AS P0,
		`Total Value`
                    
	FROM 
		Jainam_Gogree_Final
	WHERE
		`Date` >= '2021-03-09'
		AND 
		`Price Type` = 'Adjusted') AS a
ORDER BY `Rate of Return(%)` DESC
;


-- Calculating 24M Rate of Return

SELECT a.*, LN(a.P1/a.P0) * 100 AS `Rate of Return(%)`
FROM 
	(SELECT 
		`Ticker`, 
        `Security Name`,
        `Security Type`,
        `Major Asset Class`,
        `Minor Asset Class`,
		`Date`, 
		`Price` AS P1,
		LAG(`Price`, 500) 
			OVER(
				PARTITION BY `Ticker`
				ORDER BY 
					`Date`) AS P0,
		`Total Value`
	FROM 
		Jainam_Gogree_Final
	WHERE
		`Date` >= '2020-09-09'
		AND 
		`Price Type` = 'Adjusted') AS a
;

-- Calculating Portfolio's Rate of Return

SELECT a.*, LN(SUM(a.P1)/SUM(a.P0)) * 100 AS `Rate of Return(%)`
FROM 
	(SELECT 
		`Price` AS P1,
		LAG(`Price`, 3750) 
			OVER(
				PARTITION BY `Ticker`
				ORDER BY 
					`Date`) AS P0,
		`Total Value`
	FROM 
		Jainam_Gogree_Final
	WHERE
		`Date` >= '2007-09-09'
		AND 
		`Price Type` = 'Adjusted') AS a
;


-- Calculating Risk (Sigma) for each security over the recent 12 Months

SELECT 
z.*,
STD(z.`Rate of Return`) AS `Risk(%)`
FROM 
	(
	SELECT 
    a.*, LN(a.P1/a.P0) * 100 AS `Rate of Return`
	FROM 
		(
        SELECT 
		`Ticker`, 
        `Security Name`,
        `Security Type`,
        `Major Asset Class`,
        `Minor Asset Class`,
		`Date`, 
		`Price` AS P1,
		LAG(`Price`, 250) 
			OVER(
				PARTITION BY `Ticker`
				ORDER BY 
					`Date`) AS P0
		FROM 
			Jainam_Gogree_Final
		WHERE 
			`Date` >= '2021-09-09'
			AND 
			`Price Type` = 'Adjusted') AS a
	) as z
GROUP BY z.`Ticker`
;
    
    
-- Calculating average daily Rate of Return for each security 
    
SELECT 
z.*,
AVG(z.`Rate of Return`) AS `Expected ROR(%)`
FROM 
	(
	SELECT 
    a.*, LN(a.P1/a.P0) * 100 AS `Rate of Return`
	FROM 
		(
        SELECT 
		`Ticker`, 
        `Security Name`,
        `Security Type`,
        `Major Asset Class`,
        `Minor Asset Class`,
		`Date`, 
		`Price` AS P1,
		LAG(`Price`, 1) 
			OVER(
				PARTITION BY `Ticker`
				ORDER BY 
					`Date`) AS P0
		FROM 
			Jainam_Gogree_Final
		WHERE 
            `Ticker` = 'IGSB'
            AND
			`Date` >= '2021-08-09'
			AND 
			`Price Type` = 'Adjusted') AS a
	) as z
GROUP BY z.`Ticker`
;
    
    
    
-- Calculating Risk Adjusted Returns for each security
    
SELECT 
z.*, 
AVG(z.`Rate of Return`) AS `Expected ROR(%)`, 
STD(z.`Rate of Return`) AS `Risk(%)`,
AVG(z.`Rate of Return`)/STD(z.`Rate of Return`) AS `Risk Adjusted Returns(%)`
FROM 
	(
	SELECT 
    a.*, LN(a.P1/a.P0) * 100 AS `Rate of Return`
	FROM 
		(
        SELECT
		`Ticker`, 
        `Security Name`,
        `Security Type`,
        `Major Asset Class`,
        `Minor Asset Class`,
		`Date`, 
		`Price` AS P1,
		LAG(`Price`, 250) 
			OVER(
				PARTITION BY `Ticker`
				ORDER BY 
					`Date`) AS P0
		FROM 
			Jainam_Gogree_Final
		WHERE 
        `Ticker` = 'IGSB'
            AND
			`Price Type` = 'Adjusted') AS a
	) as z
GROUP BY z.`Ticker`
ORDER BY `Risk Adjusted Returns(%)` DESC
;


    