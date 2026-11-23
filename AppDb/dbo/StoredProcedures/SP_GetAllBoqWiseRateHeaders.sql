
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_GetAllBoqWiseRateHeaders 
	-- Add the parameters for the stored procedure here
	@BoqID INT,
	@WorkID INT 
AS
BEGIN
	SELECT * FROM dbo.BOQRateanalysisAllocationHeaders WHERE BOQID=@BoqID AND WorkID=@WorkID
END

GO

