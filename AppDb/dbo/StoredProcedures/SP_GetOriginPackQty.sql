
--SP_GetOriginPackQty 3,2,2,2,0

CREATE PROCEDURE [dbo].[SP_GetOriginPackQty]

	
	@PackId int,
	@ItemId int,
	@TotalPackQty decimal(18 ,2),
	@IndividualQty decimal(18 ,2),
	@OutValue decimal(18 ,2) output
	
AS
BEGIN
	declare @AppliedPackValue  decimal(18,2) , @PackRate decimal(18,2)
	set @AppliedPackValue  =0;
	--@PackRate
	select @PackRate = BPQ.Average from BOQPackages as BP inner join 
	BOQPackagesDetails BPQ on bp.Id = BPQ.PackageHeaderId
	where BP.Id = @PackId and BPQ.StockItemId = @ItemId 


	set @OutValue = (@TotalPackQty / @PackRate) * @IndividualQty

	--select @OutValue

END

GO

