-- =============================================
-- Author:		Nivesh
-- Create date: 2024-08-07
-- Description:	Get Items
-- =============================================
-- SP_GetItemsLocationwisePropertywise 4,1,-999,-999,-999
CREATE PROCEDURE SP_GetItemsLocationwisePropertywise 
	-- [dbo].[SP_GetPRFillData3] 1,1,2 Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT ,
    @Categoryid INT = -999,
	@SubCategoryid INT = -999,
	@SubCategory2id INT = -999
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT  DISTINCT SH.Id ,
					SH.Name,
					SH.IsExpiryDateApplicable,
					SD.QuantityInHand
                
					FROM    dbo.StockItemDetails SD
							INNER JOIN dbo.StockItemHeaders SH ON SD.StockItemHeaderID = SH.Id
							INNER JOIN Categories C ON C.Id = SH.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = SH.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = SH.SubCategory2ID 
					WHERE   ( SD.LocationID = @Locationid )
							AND ( SD.PropertyID = @Propertyid )
							AND ( SH.CategoryID =CASE WHEN @Categoryid = -999 THEN SH.CategoryID ELSE @Categoryid END) 
							AND ( SH.SubCategoryID =CASE WHEN @SubCategoryid = -999 THEN SH.SubCategoryID ELSE @SubCategoryid END  )
							AND ( SH.SubCategory2ID =CASE WHEN @SubCategory2id = -999 THEN SH.SubCategory2ID ELSE @SubCategory2id END  )
							AND SD.IsActive=1
					ORDER BY SH.Name
END

GO

