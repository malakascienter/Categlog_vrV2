CREATE Procedure [dbo].[GetAllBoqPackageDetailsNew]
 @PackageHeaderId INT


As

BEGIN


Select BP.Id,PackageHeaderId,StockItemId,NoOfItems,Average,Name as ItemName from BOQPackagesdetails AS BP inner join StockItemHeaders ST ON BP.StockItemId=ST.Id  where PackageHeaderId=@PackageHeaderId 







END


--Select * from [dbo].[StockItemHeaders]


--select * from BOQPackagesdetails

--select * from BOQPackages

GO

