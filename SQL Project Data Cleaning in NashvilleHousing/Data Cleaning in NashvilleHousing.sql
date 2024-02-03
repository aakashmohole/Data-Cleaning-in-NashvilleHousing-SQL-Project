/*
DATA CLEANING
*/
SELECT *
FROM PortfolioProject..NashvilleHousing
---------------------------------------------------------------------------------------
--Standardize Data Formate
---------------------------------------------------------------------------------------

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

--Created New Col SaleDateConverted
ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date;

-- Added New date in col
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------
-- Populate Property Address Data
--------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing	B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing	B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL


----------------------------------------------------------------------------------------------------
-- Breaking out address into Individual Col (Address, City, Satate)
-----------------------------------------------------------------------------------------------------

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is Null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress ,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) As city
FROM PortfolioProject..NashvilleHousing


--Created New Col PropertySpiltAddress
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySpiltAddress Nvarchar(255);

-- Added New Address in col
UPDATE NashvilleHousing
SET PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySpiltCity Nvarchar(255);

-- Added New City in col
UPDATE NashvilleHousing
SET PropertySpiltCity = SUBSTRING(PropertyAddress ,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing


SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

-- Another Method to spilt data
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing


--Created New Col PropertySpiltAddress
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSpiltAddress Nvarchar(255);

-- Added New Address in col
UPDATE NashvilleHousing
SET OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSpiltCity Nvarchar(255);

-- Added New City in col
UPDATE NashvilleHousing
SET OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSpiltState Nvarchar(255);

-- Added New City in col
UPDATE NashvilleHousing
SET OwnerSpiltState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing



-------------------------------------------------------------------------------------------------
-- Change Y And N into YES OR NO in "Sold as Vacant" Field
------------------------------------------------------------------------------------------------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-----------------------------------------------------------------------------------------
-- REMOVE DUPLICATES
-----------------------------------------------------------------------------------------


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
)
--DELETE 
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress


SELECT *
FROM PortfolioProject..NashvilleHousing

---------------------------------------------------------------------
-- DELETE UNUSED COL
-------------------------------------------------------------------

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress