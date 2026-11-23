
-- =============================================  
-- Author:  Banu  
-- Create date: 29/10/2018  
-- Description: Save & Update  
-- =============================================  
CREATE PROCEDURE [dbo].[TaxGroup_M_Save]
(	@ChargeHeaderID INT,
	@Name nvarchar(30),
	@ResNetVal numeric(18,4),
    @Operation CHAR(1),
	@UserId INT,
	@IsActive int,
	@TaxGroupWiseJson NVARCHAR(MAX),
	@PropertyId INT,
	@FiscalNo INT = 0
	)
AS  
BEGIN   TRY
	SET NOCOUNT OFF; 
	DECLARE @Remark NVARCHAR(250)
	
	IF(@Operation = 'I')
	BEGIN		
		INSERT INTO Gen_ChargeGroupHeader(Name, ResNetVal,IsActive,IsUpload,PropertyId,CreatedUserId,CreatedDateTime,FiscalNo)
		VALUES(@Name, @ResNetVal,@IsActive,0,@PropertyId,@UserId,GETDATE(),ISNULL(@FiscalNo,0))
		SET @ChargeHeaderID = SCOPE_IDENTITY()


		exec TaxGroupWiseDetail_M_Save @ChargeHeaderID,@UserId,@Operation,@TaxGroupWiseJson,@PropertyId

		-- audit trail	 
		EXEC [dbo].[AuditTrail_InsertToHistory] 'Gen_ChargeGroupHeader',@ChargeHeaderID
		-- end of audit trail

		-- audit trail				
		SET @Remark = 'Tax group '+@Name+', '+CAST(@ResNetVal as nvarchar(20))+' created.';
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'Gen_ChargeGroupHeader',@ChargeHeaderID,@UserId,'I',@Remark
		-- end of audit trail
	END
	ELSE
	BEGIN
		-- audit trail	 
		EXEC [dbo].[AuditTrail_InsertToHistory] 'Gen_ChargeGroupHeader',@ChargeHeaderID
		-- end of audit trail

		IF EXISTS( SELECT * FROM BillHeader WHERE CONVERT(DATE,OrderDate) = CONVERT(DATE,GETDATE()) AND PropertyId=@PropertyId)  
		BEGIN
			RAISERROR ('Tax group details cannot change because transactions found!',16,1)   
		END

		UPDATE Gen_ChargeGroupHeader SET 
		Name = @Name, 
	    ResNetVal = @ResNetVal,	
	    IsActive = @IsActive,
		PropertyId=@PropertyId,
        UpdatedUserId = @UserId,
        UpdatedDateTime = GETDATE()	,
		IsUpload=0,
		FiscalNo = ISNULL(@FiscalNo,0)
		WHERE 	ChargeHeaderID =@ChargeHeaderID AND PropertyId=@PropertyId

		exec TaxGroupWiseDetail_M_Save @ChargeHeaderID,@UserId,@Operation,@TaxGroupWiseJson,@PropertyId


		-- audit trail				
		SET @Remark = 'Tax group '+@Name+', '+CAST(@ResNetVal as nvarchar(20))+' updated.';
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'Gen_ChargeGroupHeader',@ChargeHeaderID,@UserId,'U',@Remark
		-- end of audit trail
	END
END TRY 
BEGIN CATCH
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

