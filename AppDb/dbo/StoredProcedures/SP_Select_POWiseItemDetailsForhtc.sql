
CREATE PROCEDURE [dbo].[SP_Select_POWiseItemDetailsForhtc] @PoHeaderID INT

AS
BEGIN

	EXEC [dbo].[SP_Select_POWiseItemDetails] @PoHeaderID

  
END

GO

