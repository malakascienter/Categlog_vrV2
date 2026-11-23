
-- =============================================
-- Author:		Chamathka
-- Create date: 2018-7-25
-- Description:	Select PosItemTypes
-- =============================================
CREATE  PROCEDURE [dbo].[KDSCategory_M_Select] 
@PropertyId INT
AS
BEGIN
	SELECT * 	FROM POSKDSCategory	WHERE PropertyId=@PropertyId ORDER BY Code Desc
END

GO

