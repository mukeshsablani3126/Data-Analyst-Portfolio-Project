/*
Cleaning Data in SQL Queries
*/

Select *
 FROM [Portfolio Project].[dbo].[Nashville Housing];

 -- Standardize Date Format

Select SaleDateConv, CONVERT(Date,SaleDate)
From [Portfolio Project].[dbo].[Nashville Housing];


ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing]
Add SaleDateConv Date;
 
 UPDATE [Portfolio Project].[dbo].[Nashville Housing]
 SET SaleDateConv  = CONVERT(Date,SaleDate)

--Removing null from property address

Select *
From [Portfolio Project].[dbo].[Nashville Housing]
--Where PropertyAddress is null
order by ParcelID


Select A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
From [Portfolio Project].[dbo].[Nashville Housing] as A
JOIN [Portfolio Project].[dbo].[Nashville Housing] as B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null


UPDATE A
SET PropertyAddress=ISNULL(A.PropertyAddress,B.PropertyAddress)
From [Portfolio Project].[dbo].[Nashville Housing] as A
JOIN [Portfolio Project].[dbo].[Nashville Housing] as B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

--Breaking property address into address, city, state


Select PropertyAddress
From [Portfolio Project].[dbo].[Nashville Housing];

Select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From [Portfolio Project].[dbo].[Nashville Housing]


ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing]
Add PropertySplitAddress Nvarchar(255);

Update [Portfolio Project].[dbo].[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing]
Add PropertySplitCity Nvarchar(255);

Update [Portfolio Project].[dbo].[Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select *
FROM [Portfolio Project].[dbo].[Nashville Housing];

Select OwnerAddress
From [Portfolio Project].[dbo].[Nashville Housing];


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project].[dbo].[Nashville Housing]


ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project].[dbo].[Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing]
Add OwnerSplitCity Nvarchar(255);

Update [Portfolio Project].[dbo].[Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update [Portfolio Project].[dbo].[Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From [Portfolio Project].[dbo].[Nashville Housing];


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project].[dbo].[Nashville Housing]
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From [Portfolio Project].[dbo].[Nashville Housing];

UPDATE [Portfolio Project].[dbo].[Nashville Housing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates---

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
					) as row_num
From [Portfolio Project].[dbo].[Nashville Housing]
)
Select *
From RowNumCTE
Where row_num>1
order by PropertyAddress;
Select * 
From [Portfolio Project].[dbo].[Nashville Housing]

-- Delete Unused Columns
ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing]
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE [Portfolio Project].[dbo].[Nashville Housing]
DROP COLUMN SaleDate

Select * 
From [Portfolio Project].[dbo].[Nashville Housing]
 