-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-08-026
-- Description: Loading Location Wise Budget selection
-- [dbo].[SP_SelectLocationWiseBudget] 4
-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectLocationWiseBudget]
	@LocationID INT
AS
BEGIN
	SET NOCOUNT ON;

   
		SELECT  ID, LocationID, Budget, Balance, UtilizeAmount
		FROM     BudgetAllocation
		WHERE  LocationID = @LocationID
END

GO

