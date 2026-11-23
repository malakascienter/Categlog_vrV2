-- =============================================
-- Author:        Chiraj
-- Create date: 2017-07-24
-- Description:    Select active Outlet
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetDefault_Outlet]
@PropertyId INT = 1
AS
BEGIN
    
    SET NOCOUNT ON;  
    SELECT code AS Code ,IPAddress AS IPAddress ,description AS Description ,Active from  Location_Ref WHERE code!='HOF' AND Active = 1 and IsDefault = 1 AND PropertyId = @PropertyId AND IsForeignCurrency = 0
END

GO

