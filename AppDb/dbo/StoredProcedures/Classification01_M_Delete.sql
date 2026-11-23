

-- =============================================
-- Author:		Chiraj
-- Create date: 2018-07-23
-- Description:	Category_M_Delete
-- =============================================
CREATE  PROCEDURE [dbo].[Classification01_M_Delete]
@Id		INT,
@UserId	INT,
@PropertyId INT
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

		DELETE FROM POS_Classification01 WHERE Id = @Id AND PropertyId=@PropertyId

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH	
		ROLLBACK TRANSACTION
		DECLARE @Error NVARCHAR(MAX)
		SET @Error=ERROR_MESSAGE()
		RAISERROR(@Error,16,1)	
	END CATCH
    
END

GO

