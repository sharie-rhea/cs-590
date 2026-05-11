-- get nutrient codes for the nutrients we are interested in
SELECT "Nutrient code" AS protein_code
FROM digestmess.nutdes
WHERE "Nutrient description" ILIKE 'Protein'
\gset

SELECT "Nutrient code" AS fat_code
FROM digestmess.nutdes
WHERE "Nutrient description" ILIKE 'Total Fat'
\gset

SELECT "Nutrient code" AS vitc_code
FROM digestmess.nutdes
WHERE "Nutrient description" ILIKE 'Vitamin C'
\gset

-- create a view for metrics/100g
\echo Creating food_metrics_100g view
CREATE OR REPLACE VIEW digestmess.food_metrics_100g AS
SELECT
    f."Cn code",
    f."Descriptor",
    protein."Nutrient value" AS protein_g_per_100g,
    fat."Nutrient value"     AS fat_g_per_100g,
    vitc."Nutrient value"    AS vitamin_c_mg_per_100g
FROM digestmess.fdes f

LEFT JOIN digestmess.nutval protein
    ON protein."Cn Code" = f."Cn code"
   	AND protein."Nutrient code" = :protein_code
LEFT JOIN digestmess.nutval fat
    ON fat."Cn Code" = f."Cn code"
   	AND fat."Nutrient code" = :fat_code
LEFT JOIN digestmess.nutval vitc
    ON vitc."Cn Code" = f."Cn code"
   	AND vitc."Nutrient code" = :vitc_code;

-- create a view for metrics/serving 
\echo Creating food_metrics_per_serving view
CREATE OR REPLACE VIEW digestmess.food_metrics_per_serving AS
SELECT
    fm."Cn code",
    fm."Descriptor",
    w."Unit amount"::numeric AS grams_per_serving,

    ROUND((fm.protein_g_per_100g * w."Unit amount" / 100.0)::numeric, 2)
        AS protein_g_per_serving,
    ROUND((fm.fat_g_per_100g * w."Unit amount" / 100.0)::numeric, 2)
        AS fat_g_per_serving,
    ROUND((fm.vitamin_c_mg_per_100g * w."Unit amount" / 100.0)::numeric, 2)
        AS vitamin_c_mg_per_serving
FROM digestmess.food_metrics_100g fm

JOIN digestmess.wght w
    ON w."Cn code" = fm."Cn code"
   AND w."Sequence num" = 1;

-- QUERY 1: PROTEIN PER 100g
\echo Top 10 Protein Foods with Less Than 15g of Total Fat per 100g
SELECT
	-- truncate desciptor if it's too long for the display
    CASE
        WHEN LENGTH(fm."Descriptor") > 60
        THEN LEFT(fm."Descriptor", 57) || '...'
        ELSE fm."Descriptor"
    END AS Descriptor,
    protein_g_per_100g,
    fat_g_per_100g
FROM digestmess.food_metrics_100g fm

WHERE fat_g_per_100g < 15
ORDER BY protein_g_per_100g DESC
LIMIT 10;

-- QUERY 2: PROTEIN PER SERVING
\echo Top 10 Protein Foods with Less Than 15g of Total Fat per Serving
SELECT
	-- truncate desciptor if it's too long for the display
    CASE
        WHEN LENGTH("Descriptor") > 60
        THEN LEFT("Descriptor", 57) || '...'
        ELSE "Descriptor"
    END AS Descriptor,
    protein_g_per_serving,
    fat_g_per_serving
FROM digestmess.food_metrics_per_serving

WHERE fat_g_per_serving < 15
ORDER BY protein_g_per_serving DESC
LIMIT 10;

-- QUERY 3: VITAMIN C PER 100g
\echo Top 10 Vitamin C Foods with More Than 20g of Protein per 100g
SELECT
	-- truncate desciptor if it's too long for the display
    CASE
        WHEN LENGTH("Descriptor") > 60
        THEN LEFT("Descriptor", 57) || '...'
        ELSE "Descriptor"
    END AS Descriptor,
    vitamin_c_mg_per_100g,
    protein_g_per_100g
FROM digestmess.food_metrics_100g

WHERE protein_g_per_100g > 20
-- make sure to ignore NULLs
AND vitamin_c_mg_per_100g IS NOT NULL
ORDER BY vitamin_c_mg_per_100g DESC

LIMIT 10;

-- QUERY 4: VITAMIN C PER SERVING
\echo Top 10 Vitamin C Foods with More Than 20g of Protein per Serving
SELECT
	-- truncate desciptor if it's too long for the display
    CASE
        WHEN LENGTH("Descriptor") > 60
        THEN LEFT("Descriptor", 57) || '...'
        ELSE "Descriptor"
    END AS Descriptor,
    vitamin_c_mg_per_serving,
    protein_g_per_serving
FROM digestmess.food_metrics_per_serving

WHERE protein_g_per_serving > 20
-- make sure to ignore NULLs
AND vitamin_c_mg_per_serving IS NOT NULL
ORDER BY vitamin_c_mg_per_serving DESC
LIMIT 10;
