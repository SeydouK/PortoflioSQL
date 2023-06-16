/*

Cleaning Data in SQL Querries

*/

SELECT *
FROM NationalHousing

-- Standardize Date Format 

ALTER TABLE NationalHousing
ADD SaleDateConverted Date

UPDATE NationalHousing
SET SaleDateConverted = CONVERT(Date,Saledate)

SELECT SaleDate, SaleDateConverted, CONVERT(Date,SaleDate) 
FROM NationalHousing

-- Populate Property Address Data

SELECT * 
FROM NationalHousing
-- WHERE PropertyAddress is NULL

SELECT a.ParcelID, a .PropertyAddress, a.ParcelID, b.PropertyAddress
FROM NationalHousing AS a
JOIN NationalHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM NationalHousing AS a
JOIN NationalHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State

SELECT PropertyAddress
FROM NationalHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
-- CHARINDEX(',', PropertyAddress)
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM NationalHousing

ALTER TABLE NationalHousing
ADD PropertySplitAddress Nvarchar(255);

ALTER TABLE NationalHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NationalHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

UPDATE NationalHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity 
FROM NationalHousing

-- Simpler way to achieve the same result 

SELECT OwnerAddress
FROM NationalHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 
FROM NationalHousing

SELECT OwnerAddress
FROM NationalHousing


ALTER TABLE NationalHousing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE NationalHousing
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE NationalHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NationalHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

UPDATE NationalHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 

UPDATE NationalHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState 
FROM NationalHousing

-- Change Y and N to Yes anc No in 'Sold as Vacant" field 

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NationalHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant, 
CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NationalHousing


UPDATE NationalHousing
SET SoldAsVacant = CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END


-- Remove Dublicates 
WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num

FROM NationalHousing
-- ORDER BY ParcelID
) 

DELETE
FROM RowNumCTE
WHERE row_num > 1 
-- ORDER BY PropertyAddress

-- DELETE UNUSED COLUMNS

ALTER TABLE NationalHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM NationalHousing
