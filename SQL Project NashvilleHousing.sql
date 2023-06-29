/*
 
 Cleaning Data in SQL Queries

 */

 Select *
 From SQLPortfolioProject..NashvilleHousing

 --Standardize Data Format 

  Select SaleDateConverted, CONVERT(Date,SaleDate)
 From SQLPortfolioProject..NashvilleHousing


 Update NashvilleHousing
 SET SaleDate = CONVERT(Date,SaleDate)

 --ANOTHER WAY TO DO THIS if above does not update properly


 ALTER TABLE NashvilleHousing
 Add SaleDateConverted Date;


 Update NashvilleHousing
SET SaleDateConverted=CONVERT (Date,SaleDate)

--------------------------------------------------------------------------------------------------------

--Populate Property Address Data
--Self-join done to see where PropertyAddress is missing in the data(NULL)
--Then after looking at table we transferred missing property address from table a to table b! :)*


Select *
From SQLPortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLPortfolioProject.dbo.NashvilleHousing a
JOIN SQLPortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLPortfolioProject.dbo.NashvilleHousing a
JOIN SQLPortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------
--Breaking Out Address into Individual Columns (Address,City,State)

 
Select PropertyAddress
From SQLPortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address 
From SQLPortfolioProject..NashvilleHousing



 Select PropertyAddress
From SQLPortfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From SQLPortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))






--Now that the address is seperated into address and city, the date is is more useable
--Now we are going to do it in a less advanced way w/o SUBSTRING :)


Select *
From SQLPortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
From SQLPortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SQLPortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)




Select *
From SQLPortfolioProject.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), COUNT (Soldasvacant)
From SQLPortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
,CASE when SoldAsVacant = 'Y' THEN 'Yes'
      when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From SQLPortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant= CASE when SoldAsVacant = 'Y' THEN 'Yes'
      when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END



------------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates


WITH RowNumCTE AS(
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


From SQLPortfolioProject..NashvilleHousing
--Order by parcelID
)
DELETE
From RowNumCTE
Where row_num>1

----------------------------------------------------------------------------------------------------
---Delete Unused Columns

Select *
From SQLPortfolioProject..NashvilleHousing

ALTER TABLE SQLPortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate



--Now we are done! :)