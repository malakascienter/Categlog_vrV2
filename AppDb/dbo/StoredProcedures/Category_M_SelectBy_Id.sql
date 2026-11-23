
-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Category_M_SelectBy_Id
	@Code VARCHAR(3),
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   SELECT * FROM Category WHERE   PropertyId=@PropertyId AND Code=@Code
END

GO

