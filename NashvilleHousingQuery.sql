-- Cleaning data using SQL

SELECT *
FROM Project.dbo.NashvilleHousing

-- Changing SaleDate format from date-time to date

Select SaleDateConverted, CONVERT(Date,SaleDate)
FROM Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate property address data
--    visual inspection to see how we could populate the address

SELECT *
FROM Project.dbo.NashvilleHousing
ORDER BY ParcelID

--    populating the NULL using JOINS    
--  DOUBT: what happens if there are odd number of entries having same ParcelID. To which row will it combine with? or is that row lost?

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM Project.dbo.NashvilleHousing A
JOIN Project.dbo.NashvilleHousing B
 ON A.ParcelID = B.ParcelID
  AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL 


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Project.dbo.NashvilleHousing A
JOIN Project.dbo.NashvilleHousing B
 ON A.ParcelID = B.ParcelID
  AND A.[UniqueID ] <> B.[UniqueID ]

-- Splitting address column into adress, city, state
--   FIRST we will split PropertyAddress
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address, /* we use -1 to get rid of the comma in the output*/
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address /*CHARINDEX gives us a number value which corresponds to position*/
FROM Project.dbo.NashvilleHousing

/* FOR TESTING */
SELECT *
FROM Project.dbo.NashvilleHousing

/* nvarchar assigns memory according to how many characters are there. char assigns a fixed amount of storage*/

ALTER TABLE Project.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
UPDATE Project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Project.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);
UPDATE Project.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--  NOW we split OwnerAddress

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3), /* PARSENAME does things backwards than SUBSTRING. the endmost split string is taken as 1*/
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Project.dbo.NashvilleHousing

ALTER TABLE Project.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255),
OwnerSplitCity Nvarchar(255),
OwnerSplitState Nvarchar(255);

UPDATE Project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Changing 'Y' and 'N' into 'Yes' and 'No' in SoldAsVacant column

SELECT distinct(SoldAsVacant),count(SoldAsVacant)
FROM Project.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
      END
FROM Project.dbo.NashvilleHousing


UPDATE Project.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
      END

-- Remove duplicates
/* usually ppl dont do this. use with caution as u might delete all data*/

WITH rownumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
              PropertyAddress,
			  SaleDate,
			  SalePrice,
			  LegalReference
 ORDER BY UniqueID
 ) row_num
FROM Project.dbo.NashvilleHousing
)
DELETE
FROM rownumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-- Delete unused columns

ALTER TABLE Project.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict
