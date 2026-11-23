-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--SP_GetALLJobCompleteData 8,1,1,1
CREATE PROCEDURE [dbo].[SP_GetALLJobCompleteData]
	-- Add the parameters for the stored procedure here
   @JobheaderID INT,
   @LocationID INT,
   @Mode INT,
   @JobOutPutItemID INT,
   @Id INT   
AS
BEGIN
	IF(@Mode=1)
	BEGIN

	SELECT JOD.*,SH.Name,U.Id AS UnitID FROM dbo.JobOutputDetails JOD INNER JOIN 
	dbo.StockItemHeaders SH ON SH.Id=JOD.StockItemHeaderID INNER JOIN  
	dbo.JobHeaders JH ON JH.ID=JOD.JobHeaderID INNER JOIN 
	dbo.StockItemDetails SD ON sd.StockItemHeaderID=SH.Id AND 
	sd.LocationID=JH.LocationID INNER JOIN 
	dbo.Units U ON u.Id=SD.MasterUnitID WHERE JobHeaderID=@JobheaderID

	END 

	ELSE IF(@Mode=2)
	BEGIN

	SELECT JID.*,SH.Name FROM dbo.JobInputDetails JID INNER JOIN dbo.StockItemHeaders SH ON SH.Id=JID.StockItemHeaderID WHERE JobHeaderID=@JobheaderID AND JID.OutPutStockItemHeaderID=@JobOutPutItemID AND JID.JobOutPutHeadId=@Id

	END 

	--select * from JobInputDetails


END

GO

