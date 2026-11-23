
-- =============================================
-- Author:		Dilshan
-- Create date: 2025-10-14
-- Description:	SpeacialOrderRevamp
-- =============================================
CREATE PROCEDURE [dbo].[SPO_spDeleteCustomerTypes]
	@id INT
AS
BEGIN

	SET NOCOUNT ON;

	IF [dbo].[FN_SPO_IsUsed]('CT', @Id) = 1
	BEGIN
		RAISERROR('This Customer Type is already in use and cannot be deleted.', 16, 1);
		RETURN;
	END

	DELETE FROM SPO_CustomerType WHERE Id = @id

    
END

GO

