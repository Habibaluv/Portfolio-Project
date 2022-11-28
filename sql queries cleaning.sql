/*

Cleaning Data in SQL Queries

*/

Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
set SaleDate=convert(date,saledate)

Alter table NashvilleHousing
Add SaleDateConverted date;

Update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted=convert(date,saledate)
-----------------------------------------------------

---Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------

--Splitting address into Individual Columns (Address, City, State)

 
 Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update  PortfolioProject..NashvilleHousing
set PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update  PortfolioProject..NashvilleHousing
set OwnerSplitCity =PARSENAME(Replace(OwnerAddress,',','.'),2)


Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertyState Nvarchar(255);

Update  PortfolioProject..NashvilleHousing
set PropertyState =PARSENAME(Replace(OwnerAddress,',','.'),1)


Select*
from PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------

---Standardization of Y and N to Yes and No in "sold as Vacant" field

Select Distinct (SoldasVacant), count(soldasvacant)
From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
,Case When SoldAsVacant='Y' then 'Yes'
      When SoldAsVacant='N' then 'No'
	  Else SoldAsVacant
	  End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant=Case When SoldAsVacant='Y' then 'Yes'
      When SoldAsVacant='N' then 'No'
	  Else SoldAsVacant
	  End

----------------------------------------------------------------------------------------------------------

--Remove Duplicates
With RowNumCTE as(
Select *,
	ROW_NUMBER() Over(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--0Order By ParcelID
)
Delete
From RowNumCTE

Where row_num>1
--Order by PropertyAddress


-----------------------------------------------------------------------------------------------------

--Delte Unused Columns


Select * 
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate