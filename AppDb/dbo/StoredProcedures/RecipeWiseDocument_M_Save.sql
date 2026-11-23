
CREATE  PROCEDURE [dbo].[RecipeWiseDocument_M_Save]  
    @RecipeCode VARCHAR(500),
	@DocumentName VARCHAR(500),
	@DocumentDisplayName VARCHAR(500),
	@UserId    INT,  
	@PropertyId INT
AS  
BEGIN  TRY
BEGIN TRANSACTION
	SET NOCOUNT ON;

	INSERT INTO [dbo].[RecipeWiseDocument]
           (RecipeCode
           ,[DocumentName]
           ,[IsActive]
           ,[SysDate]
           ,[CreatedUserId]
           ,[DocumentDisplayName]
		   ,PropertyId)
     VALUES
           (@RecipeCode
           ,@DocumentName
           ,1
           ,GETDATE()
           ,@UserId
           ,@DocumentDisplayName
		   ,@PropertyId)

COMMIT TRANSACTION		
END TRY 
BEGIN CATCH
ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

