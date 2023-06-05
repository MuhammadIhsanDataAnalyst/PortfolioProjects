-- CLEANING DATA IN SQL Queries

Select *
From NashvilleHousing

-- Standardize Date Format

Select SaleDate, Convert(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDateConverted, Convert(Date,SaleDate)
From NashvilleHousing

---------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From NashvilleHousing
Where PropertyAddress is null

Select *
From NashvilleHousing
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------

-- Breaking out Adress into individual columns (Adress, City, State)

Select PropertyAddress
From NashvilleHousing

Select
Substring (PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as Address
, Substring (PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);
Update NashvilleHousing
Set PropertySplitAddress = Substring (PropertyAddress, 1, Charindex(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);
Update NashvilleHousing
Set PropertySplitCity = Substring (PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress))

Select *
From NashvilleHousing

Select OwnerAddress
From NashvilleHousing

Select
Parsename(Replace(OwnerAddress,',','.'),3)
, Parsename(Replace(OwnerAddress,',','.'),2)
, Parsename(Replace(OwnerAddress,',','.'),1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);
Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);
Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);
Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1)

Select *
From NashvilleHousing

---------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End

---------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE As(
Select *,
	Row_Number() Over (
	Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
	Order By UniqueID) row_num
From NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1

With RowNumCTE As(
Select *,
	Row_Number() Over (
	Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
	Order By UniqueID) row_num
From NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1

---------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate

---------------------------------------------------------------------------------------------------