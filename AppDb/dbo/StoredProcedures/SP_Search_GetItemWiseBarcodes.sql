-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023-12-06
-- Description:	Loading Item Wise BarCodes

-- [dbo].[SP_Search_GetItemWiseBarcodes] 1,1
-- =============================================
CREATE PROCEDURE [dbo].[SP_Search_GetItemWiseBarcodes]
	(
	@value INT,
	@propertyId int
)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT ID,CompanyID,ItemID,Barcode
	FROM  POS_ItemBarcode
	WHERE ItemID = @value and CompanyID = @propertyId
END

GO

