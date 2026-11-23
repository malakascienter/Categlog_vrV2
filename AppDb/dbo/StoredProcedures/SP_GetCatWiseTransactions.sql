-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024/03/18
-- Description:	Option to calculate CategoryWise Transactions
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetCatWiseTransactions]
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @CategoryID INT, @FromDate DATE,@ToDate DATE,@PropertyID INT,@GRN decimal(18,6),@IssueNote DECIMAL(18,6),
@SupplierReturn DECIMAL(18,6),@ReconcilationIN DECIMAL(18,6),@ReconcilationOut DECIMAL(18,6) ,@IssueReturn DECIMAL(18,6),@KitchenIssue DECIMAL(18,6)


SET @PropertyID=1
SET @FromDate='2024/01/01'
SET @ToDate='2024/04/01'




CREATE TABLE #TempStockBalanceCalculation(
	CategoryID INT null,
	CategoryName nvarchar(500) null,
	GRN DECIMAL(18,6) null,
	IssueNote DECIMAL(18,6) null,
	SupplierReturn DECIMAL(18,6) null,
	ReconcilationIN DECIMAL(18,6) null,
	ReconcilationOut DECIMAL(18,6) null,
	IssueReturn DECIMAL(18,6) null,
	KitchenIssue DECIMAL(18,6) null,
	Balance DECIMAL(18,6) null
)





insert into #TempStockBalanceCalculation(CategoryID)
select distinct H.CategoryID
from StockTransactionDetails d
inner join stockitemheaders h on d.stockitemid = h.id
INNER JOIN Categories ca on ca.id = h.CategoryID
INNER JOIN STOCKTRANSACTIONDETAILS SD ON SD.STOCKITEMID = H.ID
where h.CompanyId=@PropertyID


update tp
set tp.CategoryName = ca.name
from #TempStockBalanceCalculation tp
inner join Categories ca on ca.id = tp.CategoryID

select *
into #TempItems
from #TempStockBalanceCalculation


while exists(select 1 from #TempItems)
begin
	SELECT TOP(1) @CategoryID =CategoryID  FROM #TempItems

	---------GRN-----------
	SELECT DISTINCT @GRN =ISNULL(sum(d.quantity* d.UnitPrice)-SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END )+ISNULL(sum(sx.TaxAmount),0),0)  
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = 1 -- AND IH.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	LEFT join stocktransactionwisetaxes sx on sx.StockTransactionDetailID = D.ID
	WHERE ih.categoryid=@CategoryID --AND H.TransactionDate between '2023-11-01' and '2023-11-30'
	and h.transactiontype='GR' 
	and h.propertyid=@PropertyID

	update #TempStockBalanceCalculation
	set GRN = @GRN
	WHERE CategoryID=@CategoryID

	-----------GRN END-----------


	---------Issue Note-----------
	SELECT DISTINCT @IssueNote =ISNULL(sum(d.quantity* d.UnitPrice)-SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END )+ISNULL(sum(sx.TaxAmount),0),0)   
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = 1 -- AND IH.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	LEFT join stocktransactionwisetaxes sx on sx.StockTransactionDetailID = D.ID
	WHERE ih.categoryid=@CategoryID --AND H.TransactionDate between '2023-11-01' and '2023-11-30'
	and h.transactiontype='IN' 
	and h.propertyid=@PropertyID





	update #TempStockBalanceCalculation
	set IssueNote = @IssueNote
	WHERE CategoryID=@CategoryID

	-----------Issue Note END-----------

	---------Supplier Return-----------
	SELECT DISTINCT @SupplierReturn =ISNULL(sum(d.quantity* d.UnitPrice)-SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END )+ISNULL(sum(sx.TaxAmount),0),0)   
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = 1 -- AND IH.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	LEFT join stocktransactionwisetaxes sx on sx.StockTransactionDetailID = D.ID
	WHERE ih.categoryid=@CategoryID --AND H.TransactionDate between '2023-11-01' and '2023-11-30'
	and h.transactiontype='SR' 
	and h.propertyid=@PropertyID





	update #TempStockBalanceCalculation
	set SupplierReturn = @SupplierReturn
	WHERE CategoryID=@CategoryID

	-----------Supplier Return END-----------


		---------Reconcilation IN-----------
	SELECT DISTINCT @ReconcilationIN =ISNULL(sum(d.quantity* d.UnitPrice)-SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END )+ISNULL(sum(sx.TaxAmount),0),0)   
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = 1 -- AND IH.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	LEFT join stocktransactionwisetaxes sx on sx.StockTransactionDetailID = D.ID
	WHERE ih.categoryid=@CategoryID --AND H.TransactionDate between '2023-11-01' and '2023-11-30'
	and h.transactiontype='AA' 
	AND D.TXNTYPE ='P'
	and h.propertyid=@PropertyID





	update #TempStockBalanceCalculation
	set ReconcilationIN = @ReconcilationIN
	WHERE CategoryID=@CategoryID

	-----------Reconcilation IN END-----------


			---------Reconcilation out-----------
	SELECT DISTINCT @ReconcilationOut =ISNULL(sum(d.quantity* d.UnitPrice)-SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END )+ISNULL(sum(sx.TaxAmount),0),0)   
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = 1 -- AND IH.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	LEFT join stocktransactionwisetaxes sx on sx.StockTransactionDetailID = D.ID
	WHERE ih.categoryid=@CategoryID --AND H.TransactionDate between '2023-11-01' and '2023-11-30'
	and h.transactiontype='AA' 
	AND D.TXNTYPE ='M'
	and h.propertyid=@PropertyID





	update #TempStockBalanceCalculation
	set ReconcilationOut = @ReconcilationOut
	WHERE CategoryID=@CategoryID

	-----------Reconcilation IN END-----------

	---------Issue Return-----------
	SELECT DISTINCT @IssueReturn =ISNULL(sum(d.quantity* d.UnitPrice)-SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END )+ISNULL(sum(sx.TaxAmount),0),0)   
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = 1 -- AND IH.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	LEFT join stocktransactionwisetaxes sx on sx.StockTransactionDetailID = D.ID
	WHERE ih.categoryid=@CategoryID --AND H.TransactionDate between '2023-11-01' and '2023-11-30'
	and h.transactiontype='IR' 
	and h.propertyid=@PropertyID





	update #TempStockBalanceCalculation
	set IssueReturn = @IssueReturn
	WHERE CategoryID=@CategoryID

	-----------Issue Return END-----------

	---------Kitchen Issue-----------
	SELECT DISTINCT @KitchenIssue =ISNULL(sum(d.quantity* d.UnitPrice)-SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END )+ISNULL(sum(sx.TaxAmount),0),0)   
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = 1 -- AND IH.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	LEFT join stocktransactionwisetaxes sx on sx.StockTransactionDetailID = D.ID
	WHERE ih.categoryid=@CategoryID --AND H.TransactionDate between '2023-11-01' and '2023-11-30'
	and h.transactiontype='IF' 
	and h.propertyid=@PropertyID




	update #TempStockBalanceCalculation
	set KitchenIssue = @KitchenIssue
	WHERE CategoryID=@CategoryID

	-----------Kitchen Issue END-----------
	
	
	DELETE  TOP(1) FROM #TempItems
end


update #TempStockBalanceCalculation
	set balance = (GRN+ReconcilationIN+IssueReturn)-(IssueNote+SupplierReturn+ReconcilationOut+KitchenIssue)


SELECT * FROM #TempStockBalanceCalculation

drop table #TempStockBalanceCalculation

drop table #TempItems




END

GO

