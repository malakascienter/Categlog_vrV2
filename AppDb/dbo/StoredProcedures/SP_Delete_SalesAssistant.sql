-- =============================================
-- Author:		Thisen Dewnim
-- Create date: 2026-02-13
-- Description:Delete from Retail_SalesAssistant
-- =============================================
CREATE PROCEDURE [dbo].[SP_Delete_SalesAssistant]
(
    @Action CHAR(1),       
    @ID INT
)
AS
BEGIN
    
    DECLARE @PropertyID INT,@Code NVARCHAR(200)
    IF (@Action = 'D')
    BEGIN
        SELECT @PropertyID  = PropertyID,@Code = Code
        FROM  dbo.Retail_SalesAssistant
        WHERE ID = @ID

        DELETE FROM dbo.Retail_SalesAssistant
        WHERE ID = @ID;

        Declare @LocationJson VARCHAR(MAX)
        SET @LocationJson = (SELECT  Id AS LocationID FROM Locations WHERE IsActive = 1 AND CompanyID = @PropertyID  AND IsSalesLocation=1 FOR JSON PATH,INCLUDE_NULL_VALUES)
        EXEC RT_SYNC_DATA_INSERT @PropertyID,@ID,@Code,'SalesAssistant',1,1,@LocationJson

        IF (@@ROWCOUNT > 0)
            RETURN 1;
        ELSE
            RETURN 0;
    END
    RETURN 0;
END

GO

