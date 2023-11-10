/*

Cleaning Data in SQL Queries

*/


SELECT * FROM nashville_housing;

--------------------------------------------------------------------------------------------------------------------------------------------

-- Standardise Date Format

SELECT 
	sale_date
FROM	
	nashville_housing;
    
ALTER TABLE nashville_housing
MODIFY sale_date DATE;

--------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM nashville_housing
ORDER BY parcel_id;

SELECT 
    a.parcel_id,
    a.property_address,
    b.parcel_id,
    b.property_address,
	IFNULL(a.property_address, b.property_address)
FROM
    nashville_housing a
        JOIN
    nashville_housing b ON a.parcel_id = b.parcel_id
        AND a.unique_id <> b.unique_id
WHERE
	a.property_address IS NULL;


    
UPDATE nashville_housing a
JOIN nashville_housing b
	ON
    a.parcel_id = b.parcel_id
	AND
    a.unique_id <> b.unique_id
SET a.property_address = IFNULL(a.property_address, b.property_address)
WHERE a.property_address IS NULL;



--------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Property Address into individual columns (Address, City, State)

SELECT property_address
FROM nashville_housing;

SELECT
SUBSTRING(property_address, 1, LOCATE(',', property_address) -1) AS address,
SUBSTRING(property_address, LOCATE(',', property_address) +1, LENGTH(property_address)) as address
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD property_split_address NVARCHAR(255);

UPDATE nashville_housing
SET property_split_address = SUBSTRING(property_address, 1, LOCATE(',', property_address) -1);


ALTER TABLE nashville_housing
ADD property_split_city NVARCHAR(255);

UPDATE nashville_housing
SET property_split_city = SUBSTRING(property_address, LOCATE(',', property_address) +1, LENGTH(property_address));

select * from nashville_housing;


-- Breaking out Owner Address into individual columns (Address, City, State)

select owner_address
from nashville_housing;

SELECT
	SUBSTRING_INDEX(owner_address, ',', 1), 
    SUBSTRING_INDEX(SUBSTRING_INDEX(owner_address, ',', -2), ',', 1), 
    SUBSTRING_INDEX(owner_address, ',', -1) 
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD owner_split_address NVARCHAR(255);

UPDATE nashville_housing
SET owner_split_address = SUBSTRING_INDEX(owner_address, ',', 1);



ALTER TABLE nashville_housing
ADD owner_split_city NVARCHAR(255);

UPDATE nashville_housing
SET owner_split_city = SUBSTRING_INDEX(SUBSTRING_INDEX(owner_address, ',', -2), ',', 1);



ALTER TABLE nashville_housing
ADD owner_split_state NVARCHAR(255);

UPDATE nashville_housing
SET owner_split_state = SUBSTRING_INDEX(owner_address, ',', -1) ;


--------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(sold_as_vacant), count(sold_as_vacant)
FROM nashville_housing
GROUP BY sold_as_vacant
ORDER BY 2;

SELECT
	sold_as_vacant,
    CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
    WHEN sold_as_vacant = 'N' THEN 'No'
    ELSE sold_as_vacant
    END
FROM nashville_housing;

UPDATE nashville_housing
SET sold_as_vacant =
	CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
    WHEN sold_as_vacant = 'N' THEN 'No'
    ELSE sold_as_vacant
    END;


--------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH row_num_cte AS(
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY 
		parcel_id,
        property_address,
        sale_price,
        sale_date,
        legal_reference
        ORDER BY
			unique_id
            ) AS row_num
FROM nashville_housing
)
SELECT *
FROM row_num_cte
WHERE row_num > 1;

WITH row_num_cte AS(
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY 
		parcel_id,
        property_address,
        sale_price,
        sale_date,
        legal_reference
        ORDER BY
			unique_id
            ) AS row_num
FROM nashville_housing
)
DELETE FROM nashville_housing USING nashville_housing
	JOIN row_num_cte ON nashville_housing.unique_id = row_num_cte.unique_id
WHERE row_num > 1;



--------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
select * from nashville_housing;

ALTER TABLE nashville_housing
	DROP COLUMN owner_address, 
	DROP COLUMN tax_district,
	DROP COLUMN property_address;
    






