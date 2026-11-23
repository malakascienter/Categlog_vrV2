
-- =============================================
-- Author:		Dilshan
-- Create date: 2025-10-14
-- Description:	SpeacialOrderRevamp
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_spDeleteOrderTypes]
	@id INT
AS
BEGIN

	SET NOCOUNT ON;
	IF [dbo].[FN_SPO_IsUsed]('OT', @Id) = 1
	BEGIN
		RAISERROR('This Order Type is already in use and cannot be deleted.', 16, 1);
		RETURN;
	END

	DELETE FROM SPO_OrderType WHERE Id = @id
END

GO

