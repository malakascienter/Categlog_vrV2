
CREATE PROCEDURE [dbo].[CostingSetting_M_Delete]  
 @Id		INT,  
@UserId	INT,
@PropertyId INT
AS  
BEGIN  	
	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @Remark NVARCHAR(250) 
		
			-- audit trail	 
			--EXEC [dbo].[AuditTrail_InsertToHistory] 'CostingSetting_History',@Id
			-- end of audit trail	
			
			DELETE FROM CostingSetting  WHERE Id = @Id  AND PropertyId=@PropertyId

			-- audit trail				
			--SET @Remark = 'CostingSetting_History'+@Id+' deleted.';
			--EXEC [dbo].[AuditTrail_InsertTableChanges] 'CostingSetting_History',@Id,@UserId,'D',@Remark
			-- end of audit trail	
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH
END

GO

