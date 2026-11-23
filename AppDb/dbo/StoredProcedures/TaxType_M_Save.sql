
-- =============================================  
-- Author:  Banu  
-- Create date: 29/10/2018  
-- Description: Save & Update  
-- =============================================  
CREATE PROCEDURE [dbo].[TaxType_M_Save]
(
	@ChargeTypeID INT,
	@Name VARCHAR(30),
	@DisplayName VARCHAR(30),
	@DefaultPercentage Numeric(18,4),
    @Operation CHAR(1),
	@UserId int,
	@IsActive   int,
	@PropertyId INT,
	@FiscalNo INT
)
AS  
BEGIN  TRY 
 SET NOCOUNT OFF; 
	DECLARE @Remark NVARCHAR(250)
	IF(@Operation = 'I')
	BEGIN
			
		INSERT INTO Gen_ChargeType( Name, DisplayName, DefaultPercentage,IsActive, PropertyId,IsUpload,CreatedUserId, CreatedDateTime,FiscalNo)
		VALUES(@Name, @DisplayName, @DefaultPercentage,@IsActive,@PropertyId,0,@UserId ,GETDATE(),@FiscalNo)

		SELECT @ChargeTypeID = @ChargeTypeID FROM Gen_ChargeType WHERE PropertyId =@PropertyId AND Name =@Name AND DisplayName =@DisplayName AND DefaultPercentage =@DefaultPercentage
		
		-- audit trail	 
		EXEC [dbo].[AuditTrail_InsertToHistory] 'Gen_ChargeType',@ChargeTypeID
		-- end of audit trail

		-- audit trail				
		SET @Remark = 'Tax type '+CAST(@ChargeTypeID as Nvarchar(50))+', '+@Name+' created.';
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'Gen_ChargeType',@ChargeTypeID,@UserId,'I',@Remark
		-- end of audit trail
	END
	ELSE
	BEGIN
		
		SELECT @ChargeTypeID = @ChargeTypeID FROM Gen_ChargeType WHERE PropertyId =@PropertyId AND Name =@Name AND DisplayName =@DisplayName AND DefaultPercentage =@DefaultPercentage
		-- audit trail	 
		EXEC [dbo].[AuditTrail_InsertToHistory] 'Gen_ChargeType',@ChargeTypeID
		-- end of audit trail

		UPDATE Gen_ChargeType SET 
		Name = @Name, 
	    DisplayName = @DisplayName,
		DefaultPercentage = @DefaultPercentage,
	    IsActive = @IsActive,		
        UpdatedUserId = @UserId,
        UpdatedDateTime = GETDATE(),
		PropertyId=@PropertyId,
		IsUpload=0,
		FiscalNo = @FiscalNo
		WHERE 	ChargeTypeID = 	@ChargeTypeID


		
			IF EXISTS( SELECT * FROM Companies WHERE IsFiscalEnable = 1 AND CompanyID = @PropertyId )
			BEGIN

			EXEC Calculate_ResNetValFor_Fiscal @ChargeTypeID,@DefaultPercentage,@Name,@DisplayName,@FiscalNo,@PropertyId 

			END


		-- audit trail				
		SET @Remark = 'Tax type '+@Name+' updated.';
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'Gen_ChargeType',@ChargeTypeID,@UserId,'U',@Remark
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

