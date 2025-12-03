-- cleaning sql queries

SELECT *
FROM Nashvilledata;

select SaleDateconverted
from PortfolioProjects..Nashvilledata

--if the date is in incorrect format try

SELECT SaleDate, convert(Date,SaleDate)
from PortfolioProjects..Nashvilledata

ALTER TABLE Nashvilledata
ADD SaleDateconverted Date;

UPDATE Nashvilledata
SET SaleDateconverted = CONVERT(Date,SaleDate)

SELECT *
From PortfolioProjects.dbo.Nashvilledata
-- where PropertyAddress is NULL 
order by ParcelID 

-- populate property address data ,where some of the adresses are null

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID ,b.PropertyAddress ,
ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.Nashvilledata a
JOIN PortfolioProjects.dbo.Nashvilledata b
 on A.ParcelID = B.ParcelID
 and a.UniqueID <> b.UniqueID
-- where a.PropertyAddress IS NULL
 
 UPDATE a
 SET 
  PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.Nashvilledata a
JOIN PortfolioProjects.dbo.Nashvilledata b
 on A.ParcelID = B.ParcelID
 and a.UniqueID <> b.UniqueID
 where a.PropertyAddress IS NULL

 --Breakingout address into individual columns (Address,city,state)

SELECT PropertyAddress
From PortfolioProjects.dbo.Nashvilledata
-- where PropertyAddress is NULL 
-- order by ParcelID 

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProjects..Nashvilledata

ALTER TABLE Nashvilledata
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashvilledata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE Nashvilledata
ADD PropertySplitcity NVARCHAR(55);

UPDATE Nashvilledata
SET PropertySplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

Select PropertySplitAddress ,PropertySplitcity
from PortfolioProjects..Nashvilledata

select OwnerAddress,
PARSENAME(Replace(OwnerAddress,',', '.'),3),
PARSENAME(Replace(OwnerAddress,',', '.'),2),
PARSENAME(Replace(OwnerAddress,',', '.'),1)
from PortfolioProjects..Nashvilledata

-- change Y and N to Yes and No in "Sold as vacant" field
SELECT Distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProjects.dbo.Nashvilledata
group by SoldAsVacant
order by 2

update Nashvilledata
set SoldAsVacant = Case 
 when SoldAsVacant = 'Y' Then REPLACE(SoldAsVacant,'Y','Yes')
 When SoldAsVacant = 'N' Then REPLACE(SoldAsVacant,'N','No')
 Else SoldAsVacant
 End 

 Select SoldAsVacant
 from Nashvilledata

--Delete and check Duplicated

with rownumCTE as (
Select *,
Row_Number() over(
PARTITION By ParcelID,
             PropertyAddress,
             SalePrice,
             SaleDate,
             LegalReference
             order by UniqueID) row_num
  from PortfolioProjects.dbo.Nashvilledata
 
)       
 DELETE
 from rownumCTE 
where row_num >1
-- order by PropertyAddress

-- below query is empty as it removed duplicates in above query

with rownumCTE as (
Select *,
Row_Number() over(
PARTITION By ParcelID,
             PropertyAddress,
             SalePrice,
             SaleDate,
             LegalReference
             order by UniqueID) row_num
  from PortfolioProjects.dbo.Nashvilledata
 
)       
 Select *
 from rownumCTE 
where row_num >1
order by PropertyAddress

--Delete unused Coulmns
Alter Table PortfolioProjects.dbo.Nashvilledata
drop COLUMN TaxDistrict, PropertyAddress

Select * from PortfolioProjects..Nashvilledata
