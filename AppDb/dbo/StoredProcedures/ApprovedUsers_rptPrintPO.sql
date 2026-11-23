-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: 26 JULY 2023
-- Description: Load Approved users details
-- [dbo].[ApprovedUsers_rptPrintPO] 7055,1
-- =============================================
CREATE PROCEDURE [dbo].[ApprovedUsers_rptPrintPO]
	(
      @StockTxnID INT,
	  @UserName varchar(50)
    )
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CU.UserName AS ApprovedUserName
	FROM PoHeaders PH
	INNER JOIN ApprovalLogs AP ON PH.Id = AP.TransactionHeaderID
	INNER JOIN CentralUsers CU ON CU.Id =  AP.ApprovalUserID
	WHERE PH.Id = @StockTxnID
END

GO

