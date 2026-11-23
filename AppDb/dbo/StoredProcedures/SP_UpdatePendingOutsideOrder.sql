-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_UpdatePendingOutsideOrder
@Id BIGINT
	
AS
BEGIN

	SET NOCOUNT ON;

   UPDATE [OutsideOrder]
   SET IsUpload = 1
   WHERE Id = @Id


END

GO

