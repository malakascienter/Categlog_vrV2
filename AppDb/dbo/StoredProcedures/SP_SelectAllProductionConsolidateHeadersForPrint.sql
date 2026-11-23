-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-19
-- Description: Loading Production Consolidate Documents
-- [dbo].[SP_SelectAllProductionConsolidateHeaders] -999,8,'2025-05-19'

-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectAllProductionConsolidateHeadersForPrint]
	@ID INT,
	@ProductionLocationID INT,
	@Date DATE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID,DocumentNo
	FROM ProductionConsolidateHeader
	WHERE ID = CASE WHEN @ID =-999 THEN ID ELSE @ID END
	AND LocationID = @ProductionLocationID
	AND CONVERT(DATE,RequestedDate) = CONVERT(DATE,@Date) --AND Status <> 'C'

   
END

GO

