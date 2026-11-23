
-- [dbo].[Report_PrintTourGuideCommission] 1

CREATE PROCEDURE [dbo].[Report_PrintTourGuideCommission]
	@StockTxnID VARCHAR(50)

AS
BEGIN

    SELECT TH.DocumentNo,TH.DocumentDate,TG.Description AS TourGuide,BH.InvoiceNo OrderNo,L.Name AS Outlet,
	TD.OrderAmount AS BillAmount,TH.TotalAmount AS CommissionAmount,TH.Remark,BH.BusinessDate OrderDate
	,TD.CommissionAmount BillCommisionAmount, (TD.TourGuideCompaniesPer + TD.TourGuidePer) CommisonPercentage
	FROM TourGuideTxnHeader TH 
	INNER JOIN TourGuideTxnDetails TD ON TH.Id = TD.TourGuideTxnHeaderId AND TH.PropertyId = TD.PropertyId
	INNER JOIN TourGuideCompanies TC ON TD.TourGuideCompaniesId = TC.Id
	inner join TourGuideMaster TG ON TG.Id = TH.TourGuideId
	INNER JOIN POS_InvoiceHeader BH ON TD.OrderNo = BH.InvoiceNo AND TD.OrderDate = BH.BusinessDate  AND TD.PropertyId = BH.CompanyID
	INNER JOIN Locations L ON BH.LocationID = L.Id AND BH.CompanyID = L.PropertyId
	WHERE TH.Id =@StockTxnID

END

GO

