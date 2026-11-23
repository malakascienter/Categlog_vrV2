-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-06-05
-- Description:	Loading Transaction Wise Item Templates

-- EXEC [dbo].[SelectTransactionWiseTemplteHeaderList] 1,'AA',1,0

-- =============================================
create PROCEDURE [dbo].[SelectTransactionWiseTemplteHeaderList] 
@PropertyID INT,
@TransactionTypeCode CHAR(3),
@LocationID INT,
@ToLocationID INT

AS
BEGIN
	SET NOCOUNT ON;

	    SELECT 
        TemplateHeaderID,
        Name AS TemplateName,
        IsActive
    FROM RequestTemplateHeader
    WHERE PropertyId = @PropertyID
      AND IsActive = 1
      AND EXISTS (
            SELECT 1 
            FROM STRING_SPLIT(TransactionTypeCode, ',') AS tt
            WHERE tt.value = @TransactionTypeCode
      )
      AND EXISTS (
            SELECT 1 
            FROM STRING_SPLIT(LocationList, ',') AS loc
            WHERE TRY_CAST(loc.value AS INT) = @LocationID
      )
    ORDER BY Name


    
END

GO

