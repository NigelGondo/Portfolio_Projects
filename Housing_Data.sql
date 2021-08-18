-- DATA CLEANING OF NASHVILLE HOUSING DATA 2013 - 2016
-- DATA WAS OBTAINED FROM KAGGLE

-- SELECTING THE FIRST 1000 ROWS TO EYE BALL THE DATA
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Housing].[dbo].[Housing];


 -- STANDARDSING THE DATE FORMAT IN THE SALEDATE COLUMN AS IT HAS AN UNNECESSARY TIME STAMP
SELECT 
	SaleDate
FROM Housing;

ALTER TABLE Housing
ADD SaleDateAltered Date; -- DON'T WANT TO REMOVE THE ORIGINAL COLUMN AS YET SO ADDING A NEW COLUMN THAT WILL CONVERT THE DATA TYPE TO JUST 'DATE'

UPDATE [Housing].[dbo].[Housing]
SET SaleDateAltered = CONVERT(Date, SaleDate);

SELECT 
	SaleDate, 
	SaleDateAltered
FROM Housing;


-- DEALING WITH NULL VALUES IN THE PROPERTY ADDRESS COLUMN
SELECT *
FROM Housing
WHERE PropertyAddress IS NULL; 

SELECT 
	ParcelID, 
	PropertyAddress
FROM Housing;

SELECT 
	H1.ParcelID, 
	H1.PropertyAddress, 
	H2.ParcelID, 
	H2.PropertyAddress, 
	ISNULL(H1.PropertyAddress, H2.PropertyAddress) -- THE ISNULL WILL POPULATE THE NULL VALUES
FROM Housing H1										-- SELF JOINING THE TABLE
JOIN Housing H2
ON H1.ParcelID = H2.ParcelID
AND H1.UniqueID <> H2.UniqueID
WHERE H1.PropertyAddress IS NULL;

UPDATE H1
SET PropertyAddress = ISNULL(H1.PropertyAddress, H2.PropertyAddress) -- NULL VALUES HAVE NOW BEEN POPULATED IN THE PROPERTY ADDRESS COLUMN
FROM Housing H1
JOIN Housing H2
ON H1.ParcelID = H2.ParcelID
AND H1.UniqueID <> H2.UniqueID
WHERE H1.PropertyAddress IS NULL;


-- WANT TO SLIPT THE OBJECTS IN THE PROPERTYADDRESS COLUMN INTO (ADDRESS AND CITY)
SELECT PropertyAddress
FROM Housing;

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM Housing;

ALTER TABLE Housing
Add Address_ NVARCHAR(255);

UPDATE Housing
SET Address_ = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE Housing
ADD City NVARCHAR(255); 

UPDATE Housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM Housing;


-- WANT TO SLIPT THE OBJECTS IN THE OWNERADDRESS COLOMN INTO (ADDRESS AND CITY)
SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Owner_Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as Owner_City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as Owner_State
FROM Housing;

ALTER TABLE Housing
Add Owner_Address NVARCHAR(255);

UPDATE Housing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE Housing
ADD Owner_City NVARCHAR(255); 

UPDATE Housing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE Housing
ADD Owner_State NVARCHAR(255); 

UPDATE Housing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT * FROM Housing;


-- THE COLUMN SOLD AS VACANT IS CATEGORICAL AND HAS YES, NO, Y AND N. TO KEEP THINGS CONSISTENT I WILL CONVERT Y AND N TO YES AND NO
SELECT DISTINCT(SoldAsVacant), 
	COUNT(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant;


SELECT 
	SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END as SoldAsVacant_updated
FROM Housing;


UPDATE Housing
SET SoldAsVacant =	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'  -- UPDATING THE COLUMN FOR CONSISTENCY
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
					END;


-- REMOVING DUPLICATES
WITH Row_Num_CTE AS (
					SELECT *,
							ROW_NUMBER() OVER (
							PARTITION BY ParcelID,
										SalePrice,
										SaleDate,
										PropertyAddress,
										LegalReference
										ORDER BY UniqueID
										) row_num
					 FROM Housing
					 )
SELECT *
FROM Row_Num_CTE
WHERE row_num > 1
ORDER BY PropertyAddress;


-- DELETING UNNECESSARY COLUMNS
ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

SELECT * FROM Housing;