-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023 August 31
-- Description:	Load Account Code 
-- [dbo].[SP_GetAccCodeName]1
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetAccCodeName]
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT -999 ACCID,'--All--' SubAccountName
	UNION ALL
	SELECT DISTINCT SA.ACCID,SA.SubAccountName
	FROM [Categlog_vrV2].DBO.StockTransactionHeaders SH
	INNER JOIN [Categlog_vrV2].DBO.StockTransactionDetails SD ON SH.ID = SD.StockTransactionHeaderID 
	INNER JOIN [eFinancials_Accounting].DBO.accSubAccountRef SA ON SD.CostTransactionAccountID = SA.AccID
	WHERE SH.TransactionType = 'IN' AND SH.PropertyID = @PROPERTYID
END

GO

