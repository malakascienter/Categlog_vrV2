
-- =============================================
-- Author:		Banu
-- Create date: 18/12/2018
-- Description:	select category for sync
-- =============================================
CREATE PROCEDURE [dbo].[Category_Select_For_Sync]
AS
BEGIN
	SELECT Code,Description,Acc, ID, Colour, Seq, CatType, IsUpload, Active 
	FROM Category
	WHERE IsUpload = 0
END

GO

