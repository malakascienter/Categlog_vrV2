
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPP_Get_RateAnalysisDetails] 
	-- Add the parameters for the stored procedure here
	@RateAnalysisHeaderID INT
AS
BEGIN


SELECT        dbo.RateAnalysisDetails.Id, dbo.RateAnalysisDetails.RateAnalysisHeaderID, dbo.RateAnalysisDetails.SequNo, dbo.RateAnalysisDetails.LocationID, dbo.RateAnalysisDetails.ItemHeaderID, dbo.RateAnalysisDetails.UnitID, 
                         dbo.RateAnalysisDetails.UnitPrice, dbo.RateAnalysisDetails.Quantity, dbo.RateAnalysisDetails.ProfitMarginVal, dbo.RateAnalysisDetails.OverheadCostVal, dbo.RateAnalysisDetails.isDisRate, 
                         dbo.RateAnalysisDetails.DisValue, dbo.RateAnalysisDetails.ItemType, dbo.Units.Name, dbo.StockItemHeaders.Name AS ItemName, dbo.Locations.Name AS LocationName
FROM            dbo.RateAnalysisDetails INNER JOIN
                         dbo.StockItemHeaders ON dbo.RateAnalysisDetails.ItemHeaderID = dbo.StockItemHeaders.Id INNER JOIN
                         dbo.Units ON dbo.RateAnalysisDetails.UnitID = dbo.Units.Id INNER JOIN
                         dbo.Locations ON dbo.RateAnalysisDetails.LocationID = dbo.Locations.Id
WHERE        (dbo.RateAnalysisDetails.RateAnalysisHeaderID = @RateAnalysisHeaderID)
END

GO

