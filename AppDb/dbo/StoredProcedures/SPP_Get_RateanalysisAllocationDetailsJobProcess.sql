
--[dbo].[SPP_Get_RateanalysisAllocationDetailsJobProcess] 2,2,3

CREATE PROCEDURE [dbo].[SPP_Get_RateanalysisAllocationDetailsJobProcess]
    -- Add the parameters for the stored procedure here
    @BOQID INT,
    @MainWorkId INT,
    @WorkId INT
AS
BEGIN
    DECLARE @TEMP TABLE
    (
        Id INT,
        RateAnalysisHeaderID INT,
        SequNo INT,
        LocationID INT,
        ItemHeaderID INT,
        UnitID INT,
        UnitPrice DECIMAL(18, 2),
        Quantity DECIMAL(18, 2),
        ProfitMarginVal DECIMAL(18, 2),
        OverheadCostVal DECIMAL(18, 2),
        isDisRate BIT,
        isProjectspecificSubstituteItem BIT,
        DisValue DECIMAL(18, 2),
        ItemType NVARCHAR(MAX),
        Name NVARCHAR(MAX),
        ItemName NVARCHAR(MAX),
        LocationName NVARCHAR(MAX),
        Currency INT,
        ExchangeRate DECIMAL,
        PackageId INT,
        IsProfitMarg BIT,
        ProfitMarginPercentage DECIMAL,
        DiscountPercentage DECIMAL,
        OHCPercentage DECIMAL(18, 2),
        ISOHCPercentage BIT,
        CostPercentage DECIMAL(18, 2),
		BOQID INT,
		MainWorkId INT,
		WorkId INT,
		IsBundle BIT,
		MainType INT,
		StockItemCode Varchar(max)

    );

    INSERT @TEMP
    (
        Id,
        RateAnalysisHeaderID,
        SequNo,
        LocationID,
        ItemHeaderID,
        UnitID,
        UnitPrice,
        Quantity,
        ProfitMarginVal,
        OverheadCostVal,
        isDisRate,
        DisValue,
        isProjectspecificSubstituteItem,
        ItemType,
        Name,
        ItemName,
        LocationName,
        Currency,
        ExchangeRate,
        PackageId,
        IsProfitMarg,
        ProfitMarginPercentage,
        DiscountPercentage,
        OHCPercentage,
        ISOHCPercentage,
		BOQID,
		MainWorkId,
		WorkId,
		IsBundle,
		MainType,
		StockItemCode
		
    )
    SELECT BRD.Id,
           BRD.RateID,
           BRD.SequNo,
           BRD.Location,
           BRD.ItemID,
           BRD.Unit,
           BRD.UnitPrice,
           BRD.Quantity,
           BRD.ProfitMarginVal,
           BRD.OverheadCostVal,
           BRD.IsPercentageOrValue,
           BRD.DiscountValue,
           BRD.isProjectspecificSubstituteItem,
           BRD.ItemType,
           dbo.Units.Name,
           dbo.StockItemHeaders.Name AS ItemName,
           dbo.Locations.Name AS LocationName,
           BRD.Currency,
           BRD.ExchangeRate,
           -1 AS PackageId,
           BRD.IsProfitMarg,
           BRD.ProfitMarginPercentage,
           BRD.DiscountPercentage,
           BRD.OHCPercentage,
           BRD.ISOHCPercentage,
		   BMA.BOQId,
		   BMA.Id,
		   BSA.Id,
		   StockItemHeaders.Isbundle,
		   1,
		   StockItemHeaders.StockItemCode
    FROM BOQMainWorkAllocations AS BMA
        INNER JOIN BOQSubWorkAllocations AS BSA
            ON BSA.MainWorkID = BMA.Id
               AND BSA.BOQID = BMA.BOQID
        INNER JOIN WorkDetails AS WD
            ON WD.WorkID = BSA.Id
        INNER JOIN BOQRateanalysisAllocationHeaders AS BRA
            ON WD.RateAnalysisHeaderID = BRA.RateAnalysisID
               AND BRA.BOQID = BMA.BOQID
        INNER JOIN BOQRateanalysisAllocationDetails AS BRD
            ON BRA.RateAnalysisID = BRD.RateID
               AND BRA.BOQID = BRD.BOQID
        INNER JOIN dbo.StockItemHeaders
            ON BRD.ItemID = dbo.StockItemHeaders.Id
        INNER JOIN dbo.Units
            ON BRD.unit = dbo.Units.Id
        INNER JOIN dbo.Locations
            ON BRD.Location = dbo.Locations.Id
    WHERE BMA.BOQID = @BoqID
          AND BMA.Id = @MainWorkId
          AND BSA.Id = @WorkId;

		  
    --SELECT *
    --FROM @TEMP;


	select *  into #TempBB from @TEMP where Isbundle=1

	select  BB.Id,
        BB.RateAnalysisHeaderID,
        BB.SequNo,
        BB.LocationID,
        BI.DetailStockItemHeaderId as  ItemHeaderID,
        BI.Unit as UnitID,
        BB.UnitPrice,
        BB.Quantity,
        BB.ProfitMarginVal,
        BB.OverheadCostVal,
        BB.isDisRate,
        BB.DisValue,
        BB.isProjectspecificSubstituteItem,
        BB.ItemType,
        BB.Name,
        ST.Name as ItemName,
        BB.LocationName,
        BB.Currency,
        BB.ExchangeRate,
        PackageId,
        BB.IsProfitMarg,
        BB.ProfitMarginPercentage,
        BB.DiscountPercentage,
        BB.OHCPercentage,
        BB.ISOHCPercentage,
		BB.BOQID,
		BB.MainWorkId,
		BB.WorkId,
		BB.IsBundle,
		ST.StockItemCode

		 into #TempTT from  [dbo].[BundleItems] as BI 
	inner join #TempBB as BB on BI.BundleStockItemHeaderId=BB.ItemHeaderId inner join StockItemHeaders as ST on BI.DetailStockItemHeaderId=ST.Id



	delete from @TEMP where IsBundle=1


	insert @TEMP(
	Id,
        RateAnalysisHeaderID,
        SequNo,
        LocationID,
        ItemHeaderID,
        UnitID,
        UnitPrice,
        Quantity,
        ProfitMarginVal,
        OverheadCostVal,
        isDisRate,
        DisValue,
        isProjectspecificSubstituteItem,
        ItemType,
        Name,
        ItemName,
        LocationName,
        Currency,
        ExchangeRate,
        PackageId,
        IsProfitMarg,
        ProfitMarginPercentage,
        DiscountPercentage,
        OHCPercentage,
        ISOHCPercentage,
		BOQID,
		MainWorkId,
		WorkId,
		IsBundle,
		MainType,StockItemCode) 
	select  Id,
        RateAnalysisHeaderID,
        SequNo,
        LocationID,
        ItemHeaderID,
        UnitID,
        UnitPrice,
        Quantity,
        ProfitMarginVal,
        OverheadCostVal,
        isDisRate,
        DisValue,
        isProjectspecificSubstituteItem,
        ItemType,
        Name,
        ItemName,
        LocationName,
        Currency,
        ExchangeRate,
        PackageId,
        IsProfitMarg,
        ProfitMarginPercentage,
        DiscountPercentage,
        OHCPercentage,
        ISOHCPercentage,
		BOQID,
		MainWorkId,
		WorkId,
		IsBundle,
		2,
		StockItemCode
		 from #TempTT

		 select * from @TEMP

	--select * from BOQMainWorkAllocations
	--select * from BOQSubWorkAllocations
	--select * from WorkDetails

	--select * from BOQheaders
	--select * from BundleItems

	--select * from StockItemHeaders where Id=61



END;

GO

