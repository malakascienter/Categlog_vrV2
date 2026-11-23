
CREATE PROCEDURE [dbo].[Update_MainMenu_PrevoiusCode_ByItemCode]     

	 @ItemCode   VARCHAR(10),     
	 @PrevItemCode   VARCHAR(10),     
	 @UserId INT,
	 @PropertyId INT


AS    
BEGIN  TRY
BEGIN TRANSACTION
  
	SET NOCOUNT ON; 

	DECLARE @Id INT,@Remark   NVARCHAR(250) ,@ItemName NVARCHAR(200)

	SELECT @Id = Id,@ItemName = FullName FROM MainMenu WHERE ItemCode = @ItemCode AND PropertyId = @PropertyId

	EXEC [dbo].[AuditTrail_InsertToHistory] 'MainMenu',@Id

	UPDATE MainMenu 
	SET PreviousMenuCode = @PrevItemCode,
	LastModifiedUserID = @UserId,
	LastModifiedDateTime = GETDATE()
	WHERE ItemCode = @ItemCode AND PropertyId = @PropertyId


	SET @Remark = 'MainMenu '+@ItemName+' updated.';
	EXEC [dbo].[AuditTrail_InsertTableChanges] 'MainMenu',@Id,@UserId,'U',@Remark

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

