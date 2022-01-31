select *
From Portfolio_Project..NashHousing;

--Standardizing the date format
select SalesDate, CONVERT(Date, SaleDate)
From Portfolio_Project..NashHousing;



Alter Table NashHousing
add SalesDate date;

Update NashHousing
set SalesDate = CONVERT(Date, SaleDate);



--Populating Property Addresses
select *
From Portfolio_Project..NashHousing
order by ParcelID;

--With this, UniqueID was unique in this table while ParcelID was the Same value. With this information, You can create a join statement
--with itself to compare the PropertyAddress Columns to see if the null could be filled. After seeing this, you can create an ISNULL function
--to create a copied column of b.PropertyAddress. After this, you can update the a table because with a set function and and set the Null
--PropertyAddress to equal the ISNULL function to update the null values to the correct addresses. Then rerun the first query to verify the
--changes went through.
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project..NashHousing a
join Portfolio_Project..NashHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project..NashHousing a
join Portfolio_Project..NashHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ];

--Breaking all address into separate columns (address, city, State)
Select PropertyAddress
from Portfolio_Project..NashHousing
--Using a substring and a nested CHARINDEX, I was able to split the Address into essentially an Address and City columns

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as PropertySplitCity
from Portfolio_Project..NashHousing;

--After Splitting the Columns, I used the Alter Table function to add new columns for my split data from above
Alter Table NashHousing
add PropertySplitAddress nvarchar(255);

Alter Table NashHousing
add PropertySplitCity nvarchar(255);

--I ran both Alter Table functions then ran the Upate Query to update the new columns with the information
Update NashHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update NashHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Now I will do the same for the OwnerAddress Column in a slightly different way using a PARSNAME function
--I used Replace to change the commas to periods so PARSENAME could recognize the delimitor
Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) as State
From Portfolio_Project..NashHousing


Alter Table NashHousing
add OwnerSplitAddress nvarchar(255);

Alter Table NashHousing
add OwnerSplitCity nvarchar(255);

Alter Table NashHousing
add OwnerSplitState nvarchar(255);


Update NashHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Update NashHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Update NashHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


--Changing SoldAsVacant column to have values either be "Yes" or "No"
--This is to check to See the counts of each option typed in the SoldAsVacant column
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Portfolio_Project..NashHousing
group by SoldAsVacant
order by 2

--This is to change the Y and N to Yes and No with a Case Statement
select SoldAsVacant,
	Case When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
		 End
from Portfolio_Project..NashHousing

--After confirming the Case Statement worked I ran the update function to update the table
--After running the Update Statement, I re-ran the first statement to confirm that there were only "Yes" and "No" in the SoldAsVacant column
update NashHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
		 End


--Removing the Dupelicates using a CTE
With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
From Portfolio_Project..NashHousing
)
SELECT *
From RowNumCTE
Where row_num > 1


--Deleting unnecessary columns
Alter Table Portfolio_Project..NashHousing
Drop column PropertyAddress, TaxDistrict, OwnerAddress

Select *
from Portfolio_Project..NashHousing