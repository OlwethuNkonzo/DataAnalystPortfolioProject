SELECT * FROM [Portfolio].[dbo].[NashvilleHousing]

-----------------------------------------------------------------------------------------------------------
--Standardize the Date Format 

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM 
Portfolio.dbo.NashvilleHousing

UPDATE [Portfolio].[dbo].[NashvilleHousing]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

-------------------------------------------------------------------------------------------------------------------------
--Populated Property Address Data

SELECT *
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM
[Portfolio].[dbo].[NashvilleHousing]

ALTER TABLE [Portfolio].[dbo].[NashvilleHousing]
ADD PropertySplitAddress nvarchar(255)

UPDATE [Portfolio].[dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Portfolio].[dbo].[NashvilleHousing]
ADD PropertySplitCity nvarchar(255)

UPDATE [Portfolio].[dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * FROM [Portfolio].[dbo].[NashvilleHousing]

--Split the Owner Address column into three columns (Address, City, State)
SELECT OwnerAddress FROM [Portfolio].[dbo].[NashvilleHousing]

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio.dbo.NashvilleHousing

ALTER TABLE [Portfolio].[dbo].[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Portfolio].[dbo].[NashvilleHousing]
Add OwnerSplitCity Nvarchar(255);

Update [Portfolio].[dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE [Portfolio].[dbo].[NashvilleHousing]
Add OwnerSplitState Nvarchar(255);

Update [Portfolio].[dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
select *
from Portfolio.dbo.NashvilleHousing
------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from Portfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Portfolio.dbo.NashvilleHousing


Update Portfolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID) row_num
FROM Portfolio.dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns 
SELECT *
FROM Portfolio.dbo.NashvilleHousing

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict