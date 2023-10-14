

Select *
From PortfolioProject1..NashvilleHousing


-- Standardize Date Format 


Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject1..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SalesDateConverted Date;

Update NashvilleHousing
SET SalesDateConverted = CONVERT(Date,SaleDate)



-- Populate Property Address data

Select *
From PortfolioProject1..NashvilleHousing
--Where PropertyAddress is NULL 
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL 


Update a  
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL 




-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject1..NashvilleHousing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
From PortfolioProject1..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);


Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



Select OwnerAddress
From PortfolioProject1..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject1..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);


Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);


Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);


Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldasVacant)
From PortfolioProject1..NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldasVacant 
, CASE When SoldasVacant = 'Y' THEN 'Yes'
		When SoldasVacant = 'N' THEN 'No'
		Else SoldasVacant
		End
From PortfolioProject1..NashvilleHousing



Update NashvilleHousing
SET SoldAsVacant = CASE When SoldasVacant = 'Y' THEN 'Yes'
		When SoldasVacant = 'N' THEN 'No'
		Else SoldasVacant
		End





-- Remove Duplicates 


WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
	
From PortfolioProject1..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress





-- Delete Unused Columns

Select *
From PortfolioProject1..NashvilleHousing

ALTER TABLE PortfolioProject1..NashVilleHousing 
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress
