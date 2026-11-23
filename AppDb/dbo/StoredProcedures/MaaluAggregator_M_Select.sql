
CREATE PROCEDURE [dbo].[MaaluAggregator_M_Select]
    @PropertyId   INT,
    @AggregatorId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [ID], [Aggregator], [AddPercentage], [PayType], [Active], [SortOrder],
           [PriceTypeID], [AggregatorChargeHeaderID], [ButtonColour], [IsIntegrate]
    FROM [dbo].[POS_Aggregators]
    WHERE [PropertyId] = @PropertyId
      AND [ID]         = @AggregatorId;
END

GO

