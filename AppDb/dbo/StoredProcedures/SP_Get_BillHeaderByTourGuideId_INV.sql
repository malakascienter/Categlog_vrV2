-- =============================================
-- Author:		<Author,,Ravindu>
-- Create date: <Create Date,,2025-07-16>
-- Description:	<Description,,Tour Guide Commission> 
-- =============================================
--[dbo].[SP_Get_BillHeaderByTourGuideId_INV]  6,1,'31/10/2023','31/10/2025'

CREATE PROCEDURE [dbo].[SP_Get_BillHeaderByTourGuideId_INV] 
	@TourGuideId	VARCHAR(10),
	@PropertyId     INT,
	@FromDate	VARCHAR(22),  
	@ToDate	VARCHAR(22)
AS
BEGIN
	DECLARE @IsTourGuideWithoutTax BIT

	SELECT @IsTourGuideWithoutTax = ISNULL(IsTourGuideWithoutTax,0)
	FROM Companies
	WHERE CompanyID = @PropertyId

	SELECT BH.InvoiceNo OrderNo,'NA' AS TableNo,BH.GuideCompanyPercentage AS TourGuideCompaniesPer,BH.GuidePercentage AS TourGuidePer,0 AS ServiceCharge
	,CASE WHEN @IsTourGuideWithoutTax = 1 THEN BH.SubAmount ELSE  BH.NetAmount END  AS Subtotal,
  0 AS TaxVal1, 0 AS TaxVal2 , 0 AS TaxVal3 , 0 AS TaxVal4,BH.GuideCompanyID AS TourGuideCompaniesId,L.Name AS Outlet,BH.CompanyID AS PropertyId,
  CONVERT(VARCHAR(10), BH.BusinessDate, 23) AS OrderDateString,'RT' AS BillType , 'Retail' AS BillTypeName
  ,L.Code OutletCode
  FROM [dbo].POS_InvoiceHeader BH 
  INNER JOIN Locations L ON BH.LocationID = L.Id AND BH.CompanyID = L.CompanyID
  WHERE BH.GuideID = @TourGuideId AND BH.CompanyID = @PropertyId AND BH.IsPaidCommission = 0 
  AND BH.BusinessDate >= CONVERT(DATETIME,@FromDate,103) AND BH.BusinessDate <= CONVERT(DATETIME,@ToDate,103)
END

GO

