

-- =============================================
-- Author:		Chiraj
-- Create date: 2020-6-22
-- Description:	Get report category for report view in backend
-- =============================================
CREATE PROCEDURE Report_ViewCategory_For_Backend 
@PropertyId INT
AS
BEGIN

SET NOCOUNT ON;  
	SELECT * FROM ReportsViewCategory
	WHERE PropertyId=@PropertyId AND Active=1
END

GO

