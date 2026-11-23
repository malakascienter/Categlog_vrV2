
-- Combinebundle 2,2,3,3525
CREATE Procedure [dbo].[Combinebundle] @BOQID INT,@MainWorkId INT,@WorkId INT,@SundryPack INT
AS
BEGIN
 DECLARE @TEMPTT TABLE
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




Insert into @TEMPTT EXEC [dbo].[SPP_Get_RateanalysisAllocationDetailsJobProcess] @BOQID,@MainWorkId,@WorkId





Insert into @TEMPTT(
Id ,
        RateAnalysisHeaderID ,
        SequNo ,
        LocationID ,
        ItemHeaderID ,
        UnitID ,
        UnitPrice,
        Quantity,
        ProfitMarginVal,
        OverheadCostVal,
        isDisRate,
        isProjectspecificSubstituteItem,

        DisValue,
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
        CostPercentage,
		BOQID,
		MainWorkId,
		WorkId,
		IsBundle,
		MainType,
		StockItemCode
)
select 1,
	   0,		
	   0,
	   ST.LocationId,
	   BI.DetailStockItemHeaderId,
	   BI.Unit,
	   0,
	   BI.Quantity,
	   0,
	   0,
	   0,
	   0,
	   0,
	  'I',
	  '',
	  ST.Name,
	  '',
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  3,
	  ST.StockItemCode
	   from BundleItems as BI
inner join StockItemheaders as ST on BI.DetailStockItemHeaderId = ST.Id 
where BundleStockItemHeaderId=@SundryPack





select * from @TEMPTT


END

GO

