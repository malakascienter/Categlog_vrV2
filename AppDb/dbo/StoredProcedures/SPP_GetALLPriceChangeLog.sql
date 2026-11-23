
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--SPP_GetALLPriceChangeLog 1,10,3
CREATE PROCEDURE SPP_GetALLPriceChangeLog
	-- Add the parameters for the stored procedure here
	--@SectionID INT = 0 ,
 --   @WorkID INT = 0 ,
 --   @RateID INT = 0,
	@BoqID INT = 0,
	@ItemID INT=0,
	@ProjectID INT=0
AS
    BEGIN
	
        SELECT BPC.ItemId,SH.Name,BPC.RevisionPrice,BPC.NewPrice,U.UserName,BPC.CreatedDate AS ModifiedDate FROM dbo.BoqPriceChangeLogs BPC INNER JOIN dbo.StockItemHeaders SH ON SH.Id=BPC.ItemId INNER JOIN
		dbo.UserMasters U ON U.Id=BPC.CreatedUserID  WHERE ProjectId=@ProjectID AND BoqId=@BoqID AND BPC.ItemId=@ItemID

    END

GO

