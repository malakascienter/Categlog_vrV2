-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--SP_GetBoqBundles 1,1
CREATE PROCEDURE [dbo].[SP_GetBoqBundles]
@BOQID INT ,	
@DepartmentID INT
AS
BEGIN
	SELECT DISTINCT SH.* FROM dbo.StockItemHeaders sh INNER JOIN dbo.BOQRateanalysisAllocationDetails BAD ON BAD.ItemID = sh.Id
	INNER JOIN BOQRateanalysisAllocationHeaders BRA ON BAD.BOQID=BRA.BOQID
	INNER JOIN BOQSubWorkAllocations BSA ON BRA.WorkID=BSA.Id
	WHERE sh.Isbundle=1 AND BAD.BOQID=@BOQID AND BSA.DepartmentID=@DepartmentID AND BAD.ItemType='I';
END

GO

