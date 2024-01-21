/*
Data Cleaning in SQL
Data used can be found here:
https://github.com/reyjeeve/Data-Analyst-Portfolio/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx
*/

Select *
From PortfolioProject..NashvilleHousing


--Standardizing Date Format

Select saleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted=Convert(Date,SaleDate)

--Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
Order by ParcelID
	/* Properties with the same Parcel ID
	has the same property address.
	*/
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1 , CHARINDEX(',', PropertyAddress) -1) as Street,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as City

From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress=SUBSTRING(PropertyAddress,1 , CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

Select *
From PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant Field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE When SoldAsVacant  ='Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
	END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant=
			CASE When SoldAsVacant  ='Y' Then 'Yes'
				When SoldAsVacant = 'N' Then 'No'
				Else SoldAsVacant
			END

-- Remove Duplicates

WITH RowNumCTE AS
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num>1

WITH RowNumCTE AS
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
)
SELECT *
From RowNumCTE
Where row_num>1

--DELETE UNUSED COLUMNS

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Select *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
