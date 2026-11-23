--[dbo].[GetAllBoqPackageDetails] 1017,53,154
CREATE Procedure [dbo].[GetAllBoqPackageDetails]
 @PackageHeaderId INT,
 @BoqID INT,
 @RateID INT 

As

BEGIN


--Select BP.Id,PackageHeaderId,StockItemId,NoOfItems,Average,Name as ItemName from BOQPackagesdetails AS BP inner join StockItemHeaders ST ON BP.StockItemId=ST.Id  where PackageHeaderId=@PackageHeaderId 


SELECT DISTINCT BDR.Id,BPD.PackageHeaderId,BPD.StockItemId,BDR.PackBreakdownQty AS QTY,BPD.Average,SH.Name as ItemName ,BDR.Quantity as cal
 FROM dbo.BOQPackagesDetails BPD
 INNER JOIN dbo.BOQRateanalysisAllocationDetails BDR ON BDR.PackID=BPD.PackageHeaderId 
 INNER JOIN dbo.StockItemHeaders SH ON SH.Id=BPD.StockItemId AND SH.Id = BPD.StockItemId  WHERE BDR.BOQID=@BoqID AND BDR.PackID=@PackageHeaderId AND BDR.RateID=@RateID




END


--Select * from [dbo].[StockItemHeaders]


--select * from BOQPackagesdetails
--SELECT * FROM dbo.BOQRateanalysisAllocationDetails WHERE BOQID=1 AND RateID=9 AND PackID=1
--select * from BOQPackages AND BPD.StockItemId=BDR.ItemID 

GO

