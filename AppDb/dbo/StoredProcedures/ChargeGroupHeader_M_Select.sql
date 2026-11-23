-- =============================================
-- Author:		Chiraj	
-- Create date: 2020-06-8
-- Description:	Select Charge Group Header
-- [dbo].[ChargeGroupHeader_M_Select] 1
-- =============================================
CREATE PROCEDURE [dbo].[ChargeGroupHeader_M_Select]
@PropertyId INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT * FROM [dbo].[Gen_ChargeGroupHeader] WHERE IsActive=1 AND  PropertyId=@PropertyId
END

GO

