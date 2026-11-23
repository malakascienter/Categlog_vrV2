-- =============================================
-- Author:		<Author,,Thisen>
-- Create date: <Create Date,,2025-11-17>
-- Description:	<Description,,Tour Guide Commission> 
-- =============================================
--[dbo].[SP_Get_BillHeaderByFromDateTourGuideId_INV] -999,1,'08/01/2022','17/11/2025'

create PROCEDURE [dbo].[SP_Get_BillHeaderByFromDateTourGuideId_INV] 
	@TourGuideId	VARCHAR(10),
	@PropertyId     INT,
	@FromDate	VARCHAR(22),  
	@ToDate	VARCHAR(22)
AS
BEGIN
	SELECT distinct  BH.GuideID ID,TM.Description Text
  FROM [dbo].POS_InvoiceHeader BH 
  INNER JOIN Locations L ON BH.LocationID = L.Id AND BH.CompanyID = L.CompanyID
    INNER JOIN TourGuideMaster TM ON BH.GuideID = TM.Id
  WHERE BH.GuideID = CASE WHEN @TourGuideId =-999 THEN  BH.GuideID ELSE @TourGuideId END AND BH.CompanyID = @PropertyId AND BH.IsPaidCommission = 0 
  AND BH.BusinessDate >= CONVERT(DATETIME,@FromDate,103) AND BH.BusinessDate <= CONVERT(DATETIME,@ToDate,103)
END

GO

