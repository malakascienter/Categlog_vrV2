
CREATE PROCEDURE [dbo].[SP_Get_BillHeaderByTourGuideId] 
	@TourGuideId	VARCHAR(10),
	@PropertyId     INT,
	@Outlet VARCHAR(3),
	@FromDate	VARCHAR(10),  
	@ToDate	VARCHAR(10)
AS
BEGIN 

  SELECT BH.OrderNo,BH.TableNo,BH.TourGuideCompaniesPer,BH.TourGuidePer,BH.ServiceCharge,BH.Subtotal,
  BH.TaxVal1, BH.TaxVal2 , BH.TaxVal3 , BH.TaxVal4,BH.TourGuideCompaniesId,BH.Outlet,BH.PropertyId,
  L.description AS OutletName,CONVERT(VARCHAR(10), BH.OrderDate, 23) AS OrderDateString,'FB' AS BillType , 'F & B' AS BillTypeName
  FROM [dbo].[BillHeader] BH INNER JOIN Location_Ref L ON BH.Outlet = L.code AND BH.PropertyId = L.PropertyId
  WHERE BH.TourGuideId = @TourGuideId AND BH.PropertyId = @PropertyId AND BH.IsPaidCommission = 0 
  AND BH.OrderDate >= CONVERT(DATETIME,@FromDate,103) AND BH.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
  --AND BH.Outlet = @Outlet remove outlet filter request by aruna


  UNION ALL


  SELECT BH.InvoiceNo OrderNo,'NA' AS TableNo,BH.GuideCompanyPercentage AS TourGuideCompaniesPer,BH.GuidePercentage AS TourGuidePer,0 AS ServiceCharge,BH.SubAmount AS Subtotal,
  0 AS TaxVal1, 0 AS TaxVal2 , 0 AS TaxVal3 , 0 AS TaxVal4,BH.GuideCompanyID AS TourGuideCompaniesId,CONVERT(VARCHAR(MAX),BH.LocationID) AS Outlet,BH.CompanyID AS PropertyId,
  L.Name AS OutletName,CONVERT(VARCHAR(10), BH.BusinessDate, 23) AS OrderDateString,'RT' AS BillType , 'Retail' AS BillTypeName
  FROM [dbo].POS_InvoiceHeader BH INNER JOIN Locations L ON BH.LocationID = L.Id AND BH.CompanyID = L.CompanyID
  WHERE BH.GuideID = @TourGuideId AND BH.CompanyID = @PropertyId AND BH.IsPaidCommission = 0 
  AND BH.BusinessDate >= CONVERT(DATETIME,@FromDate,103) AND BH.BusinessDate <= CONVERT(DATETIME,@ToDate,103) 
  --AND BH.Outlet = @Outlet remove outlet filter request by aruna


END

GO

