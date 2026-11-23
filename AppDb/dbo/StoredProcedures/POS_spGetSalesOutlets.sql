



CREATE PROCEDURE [dbo].[POS_spGetSalesOutlets]
@PropertyID INT
AS 
SET NOCOUNT ON

BEGIN TRY
	BEGIN TRAN

		SELECT	Code AS OutletCode, Description AS OutletName
		FROM	Location_Ref
		WHERE	PropertyId = @PropertyId AND Active = 1
		ORDER BY Description

	COMMIT TRAN 
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @Msg NVARCHAR(200)
	SET @Msg = ERROR_MESSAGE()
	INSERT INTO POS_DatabaseErrorLog (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),@Msg)
	RAISERROR(@Msg,16,1)
END CATCH

GO

