CREATE PROCEDURE [dbo].[SP_SelectBOQRate]
	@RateID int,
	@BoqId int
AS
BEGIN
	
	DECLARE @TEMP table ( Id int,RateAnalysisHeaderID int,  SequNo int, LocationID int, ItemHeaderID int, UnitID int, UnitPrice decimal(18,2), Quantity decimal(18,2),ProfitMarginVal decimal(18,2), OverheadCostVal decimal(18,2), isDisRate bit,isProjectspecificSubstituteItem bit, DisValue decimal(18,2),ItemType nvarchar(max) ,Name nvarchar(max), ItemName nvarchar(max), LocationName nvarchar(max))
	--DECLARE @TEMP2 AS TABLE ( ID INT IDENTITY(1,1),ItemType VARCHAR(1)  )
	--insert into @temp SELECT ID, Name FROM Table
	--DECLARE @Type nvarchar(max),@count INT = 1

	--INSERT INTO @TEMP2
	--SELECT  ItemType FROM RateAnalysisDetails WHERE RateAnalysisHeaderID = @RateID

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
			  LocationName
			)
	   SELECT        dbo.BOQRateanalysisAllocationDetails.Id, dbo.BOQRateanalysisAllocationDetails.RateID, dbo.BOQRateanalysisAllocationDetails.SequNo, dbo.BOQRateanalysisAllocationDetails.Location, dbo.BOQRateanalysisAllocationDetails.ItemID,dbo.BOQRateanalysisAllocationDetails.Unit, 
							 dbo.BOQRateanalysisAllocationDetails.UnitPrice, dbo.BOQRateanalysisAllocationDetails.Quantity, dbo.BOQRateanalysisAllocationDetails.ProfitMarginVal, dbo.BOQRateanalysisAllocationDetails.OverheadCostVal, dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue, 
							 dbo.BOQRateanalysisAllocationDetails.DiscountValue,dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem, dbo.BOQRateanalysisAllocationDetails.ItemType, dbo.Units.Name, dbo.StockItemHeaders.Name AS ItemName, dbo.Locations.Name AS LocationName
	FROM            dbo.BOQRateanalysisAllocationDetails INNER JOIN
							 dbo.StockItemHeaders ON dbo.BOQRateanalysisAllocationDetails.ItemID = dbo.StockItemHeaders.Id INNER JOIN
							 dbo.Units ON dbo.BOQRateanalysisAllocationDetails.unit = dbo.Units.Id INNER JOIN
							 dbo.Locations ON dbo.BOQRateanalysisAllocationDetails.Location = dbo.Locations.Id
	WHERE        (dbo.BOQRateanalysisAllocationDetails.RateID = @RateID AND dbo.BOQRateanalysisAllocationDetails.BOQID=@BOQID AND ItemType ='I')
	UNION ALL
	
	SELECT        dbo.BOQRateanalysisAllocationDetails.Id,dbo.BOQRateanalysisAllocationDetails.RateID,dbo.BOQRateanalysisAllocationDetails.SequNo,0, dbo.BOQRateanalysisAllocationDetails.ItemID, dbo.BOQRateanalysisAllocationDetails.Unit,dbo.BOQRateanalysisAllocationDetails.UnitPrice,dbo.BOQRateanalysisAllocationDetails.Quantity, dbo.BOQRateanalysisAllocationDetails.ProfitMarginVal, dbo.BOQRateanalysisAllocationDetails.OverheadCostVal, dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue,dbo.BOQRateanalysisAllocationDetails.DiscountValue,dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem,'L',LU.LaborUnitName, dbo.LabourTypes.LabourName ,''                        
	FROM            dbo.LabourTypes INNER JOIN
							 dbo.BOQRateanalysisAllocationDetails ON dbo.LabourTypes.Id = dbo.BOQRateanalysisAllocationDetails.ItemID
							 INNER JOIN dbo.LaborUnits LU ON LU.Id = dbo.BOQRateanalysisAllocationDetails.Unit
	WHERE        (dbo.BOQRateanalysisAllocationDetails.RateID =  @RateID AND dbo.BOQRateanalysisAllocationDetails.BOQID=@BOQID AND ItemType='L')
	UNION ALL
	

	--SELECT        dbo.BOQRateanalysisAllocationDetails.Id,dbo.BOQRateanalysisAllocationDetails.RateID AS RateAnalysisHeaderID,
	--min(dbo.BOQRateanalysisAllocationDetails.SequNo),0, dbo.BOQRateanalysisAllocationDetails.ItemID as ItemHeaderID, 
	--dbo.BOQRateanalysisAllocationDetails.Unit as UnitID,avg(dbo.BOQRateanalysisAllocationDetails.UnitPrice),dbo.BOQRateanalysisAllocationDetails.PackQty, 
	--sum(dbo.BOQRateanalysisAllocationDetails.ProfitMarginVal), 
	--sum(dbo.BOQRateanalysisAllocationDetails.OverheadCostVal),dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue as isDisRate, dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem, 
	--sum(dbo.BOQRateanalysisAllocationDetails.DiscountValue) as DisValue,'L','', dbo.BOQPackages.Description ,''    
	                    
	--FROM          dbo.BOQPackages INNER JOIN
	--			  dbo.BOQRateanalysisAllocationDetails ON dbo.BOQPackages.Id = dbo.BOQRateanalysisAllocationDetails.PackID 
				  
	--WHERE        (BOQRateanalysisAllocationDetails.RateID =  @RateID AND ItemType='P')
 --   group by dbo.BOQRateanalysisAllocationDetails.Id,dbo.BOQRateanalysisAllocationDetails.RateID,  
	-- dbo.BOQRateanalysisAllocationDetails.ItemID, dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue,dbo.BOQRateanalysisAllocationDetails.PackQty,
	--  dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem , dbo.BOQPackages.Description, dbo.BOQRateanalysisAllocationDetails.Unit 

	 
	 	SELECT        dbo.BOQRateanalysisAllocationDetails.PackID as Id,dbo.BOQRateanalysisAllocationDetails.RateID AS RateAnalysisHeaderID,
	min(dbo.BOQRateanalysisAllocationDetails.SequNo),0, dbo.BOQRateanalysisAllocationDetails.PackID as ItemHeaderID, dbo.BOQRateanalysisAllocationDetails.Unit as UnitID,
	avg(dbo.BOQRateanalysisAllocationDetails.UnitPrice),dbo.BOQRateanalysisAllocationDetails.PackQty, 
	sum(dbo.BOQRateanalysisAllocationDetails.ProfitMarginVal), sum(dbo.BOQRateanalysisAllocationDetails.OverheadCostVal),
	dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue as isDisRate, dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem, 
	sum(dbo.BOQRateanalysisAllocationDetails.DiscountValue) as DisValue,'L','', dbo.BOQPackages.Description ,''     
	                   
	FROM          dbo.BOQPackages INNER JOIN
				  dbo.BOQRateanalysisAllocationDetails ON dbo.BOQPackages.Id = dbo.BOQRateanalysisAllocationDetails.PackID 
				  
	WHERE        (BOQRateanalysisAllocationDetails.RateID =  @RateID AND ItemType='P' )
	group by dbo.BOQRateanalysisAllocationDetails.RateID,   dbo.BOQRateanalysisAllocationDetails.PackID, dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue,dbo.BOQRateanalysisAllocationDetails.PackQty, dbo.BOQRateanalysisAllocationDetails.isProjectspecificSubstituteItem , dbo.BOQPackages.Description, dbo.BOQRateanalysisAllocationDetails.Unit 
    SELECT * FROM @TEMP ORDER BY SequNo


END

GO

