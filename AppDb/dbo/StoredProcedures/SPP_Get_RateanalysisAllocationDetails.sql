--select * from [dbo].[CostProvisionSnapShot]

--[dbo].[SPP_Get_RateanalysisAllocationDetails] 1,3
CREATE PROCEDURE [dbo].[SPP_Get_RateanalysisAllocationDetails] 
	-- Add the parameters for the stored procedure here
	@RateAnalysisHeaderID INT,
	@BOQID INT
AS
BEGIN
	DECLARE @TEMP table ( Id int,RateAnalysisHeaderID int,  SequNo int, LocationID int, ItemHeaderID int, UnitID int, UnitPrice decimal(18,2), Quantity decimal(18,2),ProfitMarginVal decimal(18,2), OverheadCostVal decimal(18,2), isDisRate bit,isProjectspecificSubstituteItem bit, DisValue decimal(18,2),ItemType nvarchar(max) ,Name nvarchar(max), ItemName nvarchar(max), LocationName nvarchar(max),  Currency INT,
			  ExchangeRate Decimal,PackageId int,IsProfitMarg bit,ProfitMarginPercentage Decimal,DiscountPercentage Decimal, OHCPercentage decimal(18,2),
			  ISOHCPercentage bit ,CostPercentage Decimal(18,2),UnitTax Decimal(18,2))
	--DECLARE @TEMP2 AS TABLE ( ID INT IDENTITY(1,1),ItemType VARCHAR(1)  )
	--insert into @temp SELECT ID, Name FROM Table
	--DECLARE @Type nvarchar(max),@count INT = 1

	--INSERT INTO @TEMP2
	--SELECT  ItemType FROM RateAnalysisDetails WHERE RateAnalysisHeaderID = @RateAnalysisHeaderID

	--WHILE (@count <= (SELECT COUNT(1) FROM @TEMP2 ))
	--BEGIN

	--SELECT @Type = ItemType FROM @TEMP2 WHERE id = @count

	--IF @Type='I'
	--BEGIN
    --SELECT @Type AS Type
	INSERT @TEMP
			( Id ,
			  RateAnalysisHeaderID ,
			  SequNo ,
			  LocationID ,
			  ItemHeaderID ,
			  UnitID ,
			  UnitPrice ,
			  Quantity ,
			  ProfitMarginVal ,
			  OverheadCostVal ,
			  isDisRate ,
			  DisValue ,
			  isProjectspecificSubstituteItem,
			  ItemType ,
			  Name ,
			  ItemName ,
			  LocationName,
			  Currency,
			  ExchangeRate,
			  PackageId,
			  IsProfitMarg,
			  ProfitMarginPercentage,
			  DiscountPercentage,
			  OHCPercentage,
			  ISOHCPercentage,
			  CostPercentage,
			  UnitTax
			)
	   SELECT        dbo.BOQRateanalysisAllocationDetails.Id, dbo.BOQRateanalysisAllocationDetails.RateID, dbo.BOQRateanalysisAllocationDetails.SequNo, dbo.BOQRateanalysisAllocationDetails.Location, dbo.BOQRateanalysisAllocationDetails.ItemID,dbo.BOQRateanalysisAllocationDetails.Unit, 
							 dbo.BOQRateanalysisAllocationDetails.UnitPrice, dbo.BOQRateanalysisAllocationDetails.Quantity, dbo.BOQRateanalysisAllocationDetails.ProfitMarginVal, dbo.BOQRateanalysisAllocationDetails.OverheadCostVal, dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue,                       
							 dbo.BOQRateanalysisAllocationDetails.DiscountValue,dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem, dbo.BOQRateanalysisAllocationDetails.ItemType, dbo.Units.Name, dbo.StockItemHeaders.Name AS ItemName, dbo.Locations.Name AS LocationName,dbo.BOQRateanalysisAllocationDetails.Currency,dbo.BOQRateanalysisAllocationDetails.ExchangeRate,-1 as PackageId,dbo.BOQRateanalysisAllocationDetails.IsProfitMarg,dbo.BOQRateanalysisAllocationDetails.ProfitMarginPercentage,dbo.BOQRateanalysisAllocationDetails.DiscountPercentage,dbo.BOQRateanalysisAllocationDetails.OHCPercentage,dbo.BOQRateanalysisAllocationDetails.ISOHCPercentage,CPS.Percentage as CostPercentage,dbo.BOQRateanalysisAllocationDetails.UnitTax
	FROM            dbo.BOQRateanalysisAllocationDetails INNER JOIN
							 dbo.StockItemHeaders ON dbo.BOQRateanalysisAllocationDetails.ItemID = dbo.StockItemHeaders.Id INNER JOIN
							 dbo.Units ON dbo.BOQRateanalysisAllocationDetails.unit = dbo.Units.Id INNER JOIN
							 dbo.Locations ON dbo.BOQRateanalysisAllocationDetails.Location = dbo.Locations.Id LEFT JOIN CostProvisionSnapShot as CPS ON CPS.ItemId= dbo.BOQRateanalysisAllocationDetails.ItemID and CPS.RateHeaderId = dbo.BOQRateanalysisAllocationDetails.RateID and CPS.BoqId=dbo.BOQRateanalysisAllocationDetails.BOQID
	WHERE        (dbo.BOQRateanalysisAllocationDetails.RateID = @RateAnalysisHeaderID AND dbo.BOQRateanalysisAllocationDetails.BOQID=@BOQID AND ItemType='I') 
	UNION ALL
	
	SELECT        dbo.BOQRateanalysisAllocationDetails.Id,dbo.BOQRateanalysisAllocationDetails.RateID,dbo.BOQRateanalysisAllocationDetails.SequNo,0 as Location, dbo.BOQRateanalysisAllocationDetails.ItemID, dbo.BOQRateanalysisAllocationDetails.Unit,dbo.BOQRateanalysisAllocationDetails.UnitPrice,dbo.BOQRateanalysisAllocationDetails.Quantity, dbo.BOQRateanalysisAllocationDetails.ProfitMarginVal, dbo.BOQRateanalysisAllocationDetails.OverheadCostVal, dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue, dbo.BOQRateanalysisAllocationDetails.DiscountValue,dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem,dbo.BOQRateanalysisAllocationDetails.ItemType,LU.LaborUnitName, dbo.LabourTypes.LabourName ,'',dbo.BOQRateanalysisAllocationDetails.Currency,dbo.BOQRateanalysisAllocationDetails.ExchangeRate,-1 as PackageId,dbo.BOQRateanalysisAllocationDetails.IsProfitMarg,dbo.BOQRateanalysisAllocationDetails.ProfitMarginPercentage,dbo.BOQRateanalysisAllocationDetails.DiscountPercentage,dbo.BOQRateanalysisAllocationDetails.OHCPercentage,dbo.BOQRateanalysisAllocationDetails.ISOHCPercentage,0 as CostPercentage,dbo.BOQRateanalysisAllocationDetails.UnitTax                        
	FROM            dbo.LabourTypes INNER JOIN
							 dbo.BOQRateanalysisAllocationDetails ON dbo.LabourTypes.Id = dbo.BOQRateanalysisAllocationDetails.ItemID
							 INNER JOIN dbo.LaborUnits LU ON LU.Id = dbo.BOQRateanalysisAllocationDetails.Unit
	WHERE        (dbo.BOQRateanalysisAllocationDetails.RateID =  @RateAnalysisHeaderID AND dbo.BOQRateanalysisAllocationDetails.BOQID=@BOQID AND ItemType='L')

  UNION ALL
	
	--SELECT        dbo.BOQRateanalysisAllocationDetails.Id,dbo.BOQRateanalysisAllocationDetails.RateID,min(dbo.BOQRateanalysisAllocationDetails.SequNo),0, dbo.BOQRateanalysisAllocationDetails.ItemID,dbo.BOQRateanalysisAllocationDetails.Unit,avg(BOQRateanalysisAllocationDetails.UnitPrice),dbo.BOQRateanalysisAllocationDetails.PackQty, sum(dbo.BOQRateanalysisAllocationDetails.ProfitMarginVal), sum(dbo.BOQRateanalysisAllocationDetails.OverheadCostVal), dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue, dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem, sum(dbo.BOQRateanalysisAllocationDetails.DiscountValue),'L','', dbo.BOQPackages.Description ,''                        
	--FROM          dbo.BOQPackages INNER JOIN
	--			  dbo.BOQRateanalysisAllocationDetails ON dbo.BOQPackages.Id = dbo.BOQRateanalysisAllocationDetails.PackID
				  
	--WHERE        (dbo.BOQRateanalysisAllocationDetails.RateID =  @RateAnalysisHeaderID AND ItemType='P')
 --   group by dbo.BOQRateanalysisAllocationDetails.Id,dbo.BOQRateanalysisAllocationDetails.RateID,  dbo.BOQRateanalysisAllocationDetails.ItemID, dbo.BOQRateanalysisAllocationDetails.Unit,dbo.BOQRateanalysisAllocationDetails.PackQty, dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem , dbo.BOQPackages.Description ,dbo.BOQRateanalysisAllocationDetails.Discountvalue

	SELECT       dbo.BOQRateanalysisAllocationDetails.Id,dbo.BOQRateanalysisAllocationDetails.RateID,min(dbo.BOQRateanalysisAllocationDetails.SequNo) AS SequNo,dbo.BOQRateanalysisAllocationDetails.Location AS Location,dbo.BOQRateanalysisAllocationDetails.ItemID,dbo.BOQRateanalysisAllocationDetails.Unit,avg(BOQRateanalysisAllocationDetails.UnitPrice) AS UnitPrice,dbo.BOQRateanalysisAllocationDetails.packQty AS Quantity, sum(dbo.BOQRateanalysisAllocationDetails.ProfitMarginVal) AS ProfitMarginVal, sum(dbo.BOQRateanalysisAllocationDetails.OverheadCostVal) AS OverheadCostVal, dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue, sum(dbo.BOQRateanalysisAllocationDetails.DiscountValue) AS DiscountValue , dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem,'P' AS ItemType,'' AS Name, dbo.BOQPackages.Description AS ItemName ,L.Name AS LocationName,dbo.BOQRateanalysisAllocationDetails.Currency,90 AS ExchangeRate,dbo.BOQPackages.Id as PackageId,dbo.BOQRateanalysisAllocationDetails.IsProfitMarg,dbo.BOQRateanalysisAllocationDetails.ProfitMarginPercentage,dbo.BOQRateanalysisAllocationDetails.DiscountPercentage,dbo.BOQRateanalysisAllocationDetails.OHCPercentage,dbo.BOQRateanalysisAllocationDetails.ISOHCPercentage,0 as CostPercentage,dbo.BOQRateanalysisAllocationDetails.UnitTax                              
	FROM          dbo.BOQPackages INNER JOIN
				  dbo.BOQRateanalysisAllocationDetails ON dbo.BOQPackages.Id = dbo.BOQRateanalysisAllocationDetails.PackID
				  LEFT JOIN dbo.Locations L ON L.Id=dbo.BOQRateanalysisAllocationDetails.Location
				  
	WHERE        (dbo.BOQRateanalysisAllocationDetails.RateID =  @RateAnalysisHeaderID AND ItemType='P' AND dbo.BOQRateanalysisAllocationDetails.BOQID=@BOQID)
    group by dbo.BOQRateanalysisAllocationDetails.RateID,dbo.BOQRateanalysisAllocationDetails.OHCPercentage,dbo.BOQRateanalysisAllocationDetails.ISOHCPercentage,dbo.BOQRateanalysisAllocationDetails.IsProfitMarg,dbo.BOQRateanalysisAllocationDetails.ItemID,dbo.BOQRateanalysisAllocationDetails.Id, dbo.BOQRateanalysisAllocationDetails.Unit,dbo.BOQRateanalysisAllocationDetails.packQty, dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem , dbo.BOQPackages.Description ,dbo.BOQRateanalysisAllocationDetails.Discountvalue,dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue,dbo.BOQRateanalysisAllocationDetails.Location,L.Name,dbo.BOQPackages.Id,dbo.BOQRateanalysisAllocationDetails.Currency,dbo.BOQRateanalysisAllocationDetails.ProfitMarginPercentage,dbo.BOQRateanalysisAllocationDetails.DiscountPercentage,dbo.BOQRateanalysisAllocationDetails.UnitTax 




	 SELECT * FROM @TEMP ORDER BY SequNo






	--END 
	--ELSE	
	--BEGIN
		--SELECT @Type

		--INSERT @TEMP
		--	( Id ,
		--	  RateAnalysisHeaderID ,
		--	  SequNo ,
		--	  LocationID ,
		--	  ItemHeaderID ,
		--	  UnitID ,
		--	  UnitPrice ,
		--	  Quantity ,
		--	  ProfitMarginVal ,
		--	  OverheadCostVal ,
		--	  isDisRate ,
		--	  DisValue ,
		--	  ItemType ,
		--	  Name ,
		--	  ItemName ,
		--	  LocationName
		--	)



	--END

	--SET @count +=1;

	--END

END

GO

