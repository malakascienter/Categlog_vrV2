-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023-06-05
-- Description:	select all additional charges for grn
-- [dbo].[rptPrintGRNAdditonalCharges] 7440,1
-- =============================================
CREATE PROCEDURE  [dbo].[rptPrintGRNAdditonalCharges] 
 (
      @StockTxnID INT,
	  @UserName varchar(50)
    )
AS
BEGIN
	SET NOCOUNT ON;

	SELECT isnull(sum(stc.ChargeAmount),0) AdditionalCost,ad.Name AdditionalCostName
	FROM StockTransactionHeaders st
	INNER JOIN StockTransactionwiseCharges stc on st.Id = stc.StockTransactionHeaderID
	INNER  JOIN AdditionalChargesDetails ad on ad.Id = stc.AdditionalChargeID
	WHERE st.Id=@StockTxnID
	GROUP by ad.Name


 
END

GO

