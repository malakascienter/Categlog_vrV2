-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-02-12
-- Description:	Load Sales Assistant Records
-- [dbo].[SP_Select_SalesAssistant] -999,1
-- =============================================
CREATE PROCEDURE [dbo].[SP_Select_SalesAssistant]
@ID INT,
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, Name, Code, RefNo, IsActive, PropertyID,CreatedUserID
	FROM     Retail_SalesAssistant
	WHERE ID = CASE WHEN @ID = -999 THEN ID ELSE ID END
	AND PropertyID = @PropertyID


    
END

GO

