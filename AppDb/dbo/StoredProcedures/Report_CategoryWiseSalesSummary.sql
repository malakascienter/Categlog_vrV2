-- =============================================
-- Author		: Chamathka Sooriyapala
-- Create date	: 2021-07-07
-- Description	: Menu Category Wise Summary
-- =============================================
-- Report_CategoryWiseSalesSummary '2021-07-01', '101'
CREATE PROCEDURE [dbo].[Report_CategoryWiseSalesSummary] 
	@Date	varchar(10),
	@Outlet	VARCHAR(100)
AS
BEGIN

	DECLARE	@OutletSubTotal MONEY,
			@OutletNetTotal	MONEY

	SELECT	@OutletSubTotal =  SUM(BH.Subtotal + BH.Discount),
			@OutletNetTotal = SUM(BH.Subtotal +BH.TaxVal1 + BH.TaxVal2 + BH.TaxVal3 + BH.TaxVal4 + BH.ServiceCharge)
	FROM	BillHeader BH
	WHERE	CONVERT(DATE, OrderDate) = CONVERT(DATETIME,@Date,103) AND Outlet = @Outlet

	SELECT BT.MainMenuCode, BT.Rate, BT.Qty, BT.ItWiseDiscount, BT.OrderDate,BT.Outlet,BT.IsIncludeChargeToPrice,BT.ResNetVal,BT.BillDisVal,BT.BillDisPer
	INTO #BILLTRANS
	FROM BillTrans BT
	WHERE CONVERT(DATE, BT.OrderDate) = CONVERT(DATETIME,@Date,103) AND BT.Outlet = @Outlet

	SELECT		C.Code AS CategoryCode,
				C.Description AS CategoryName, 
				SUM (BT.Rate * BT.Qty)/ @OutletSubTotal * 100 AS GroupPerformance,
				SUM (BT.Qty) AS	Quantity,
			--	SUM (BT.Rate * BT.Qty) AS SubTotal,
				SUM(((BT.Qty*BT.Rate*BT.ResNetVal)  -  (BT.BillDisVal + ((BT.Qty*BT.Rate*BT.ResNetVal) * BT.BillDisPer/100))               ))  as NetTotal  ,--Net
				SUM((BT.Qty*BT.Rate*BT.ResNetVal)                 )    as SubTotal  --Gross
				--SUM ((BT.Rate * BT.Qty) - BT.ItWiseDiscount) AS NetTotal
	FROM		#BILLTRANS BT
	LEFT JOIN	MainMenu MM ON MM.ItemCode = BT.MainMenuCode
	LEFT JOIN	Category C ON C.Code = MM.Category
	WHERE		CONVERT(DATE, BT.OrderDate) = CONVERT(DATETIME,@Date,103) AND BT.Outlet = @Outlet
	GROUP BY	C.Code, C.Description
END

GO

