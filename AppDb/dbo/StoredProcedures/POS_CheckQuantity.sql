CREATE PROCEDURE [dbo].[POS_CheckQuantity] 
    WITH RECOMPILE
AS
    BEGIN
		SELECT CheckQuantity FROM dbo.POS_Settings
    END

GO

