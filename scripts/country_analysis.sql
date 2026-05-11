SELECT DISTINCT
    country,
    LEN(country) AS country_length
FROM gold.dim_customers
WHERE country IS NULL
   OR TRIM(country) = '';

   SELECT
    ci.cst_key,
    cl.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_loc_a101 cl
ON ci.cst_key = cl.cid
WHERE cl.cntry IS NULL;

SELECT *
FROM gold.dim_customers
WHERE country = '' OR TRIM(country) = '';

SELECT *
FROM gold.dim_customers
WHERE country IS NULL;
