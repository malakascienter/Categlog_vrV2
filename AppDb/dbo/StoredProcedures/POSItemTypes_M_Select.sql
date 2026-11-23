
-- =============================================
-- Author:		Chiraj
-- Create date: 2018-7-25
-- Description:	Select PosItemTypes
-- =============================================
CREATE  PROCEDURE [dbo].[POSItemTypes_M_Select]
@PropertyId INT
AS
BEGIN	
	SET NOCOUNT ON;
    SELECT Code,Name,IsActive FROM POSItemTypes where PropertyId=@PropertyId
END

GO

