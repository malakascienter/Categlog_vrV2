CREATE PROCEDURE [dbo].[SP_CheckRate] 
	-- Add the parameters for the stored procedure here
	@RateID INT,@BOQID INT
AS
BEGIN
	select COUNT(*) from  BOQRateanalysisAllocationHeaders as p where p.BOQID=@BOQID and p.RateAnalysisID=@RateID  

END

GO

