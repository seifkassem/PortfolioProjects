SELECT *
FROM Housing.dbo.NashvilleHousing


-- Standardize data format

SELECT SaleDate_Converted, CONVERT(date, SaleDate) AS NewSaleDate
FROM Housing.dbo.NashvilleHousing;

ALTER TABLE Housing.dbo.NashvilleHousing
ADD SaleDate_Converted date;

UPDATE Housing.dbo.NashvilleHousing
SET Saledate_Converted = CONVERT(date, SaleDate);


-- Populate property address data

SELECT *
FROM Housing.dbo.NashvilleHousing
ORDER BY PropertyAddress;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS NewPropertyAddress
FROM Housing.dbo.NashvilleHousing a
JOIN Housing.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM Housing.dbo.NashvilleHousing a
	JOIN Housing.dbo.NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] != b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

SELECT *
FROM Housing.dbo.NashvilleHousing
ORDER BY PropertyAddress;


-- Breaking property address into individual columns(Address, City)

SELECT PropertyAddress
FROM Housing.dbo.NashvilleHousing

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM Housing.dbo.NashvilleHousing

ALTER TABLE Housing.dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

ALTER TABLE Housing.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE Housing.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE Housing.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM Housing.dbo.NashvilleHousing


-- Breaking owner address into individual columns(Address, City, State)

SELECT OwnerAddress
FROM Housing.dbo.NashvilleHousing

SELECT
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM Housing.dbo.NashvilleHousing

ALTER TABLE Housing.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE Housing.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE Housing.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE Housing.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE Housing.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE Housing.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Housing.dbo.NashvilleHousing


-- Change y to yes and n to no

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM Housing.dbo.NashvilleHousing

UPDATE Housing.dbo.NashvilleHousing
SET SoldAsVacant =CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

SELECT SoldAsVacant
FROM Housing.dbo.NashvilleHousing


-- Remove duplicates

WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER(
							PARTITION BY
								ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY UniqueID
						) AS row_num
	FROM Housing.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER(
							PARTITION BY
								ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY UniqueID
						) AS row_num
	FROM Housing.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Deleting unused columns

SELECT *
FROM Housing.dbo.NashvilleHousing

ALTER TABLE Housing.dbo.NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict