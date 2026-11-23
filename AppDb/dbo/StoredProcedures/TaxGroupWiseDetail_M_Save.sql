
-- =============================================  
-- Author:  Yasiru  
-- Create date: 29/10/2018  
-- Description: Save & Update  
-- =============================================  
CREATE PROCEDURE [dbo].[TaxGroupWiseDetail_M_Save]
(
	
	-- @ChargeTypeID Int,
	--@ActualPercentage decimal(18,2),
	-- @ChargeTypeSequence int,
	--@IsActive   int,
	@ChargeHeaderID Int,
	@UserId int ,	
    @Operation CHAR(1),	
	@TaxGroupWiseJson NVARCHAR(MAX),
	@PropertyId INT
)
AS  
BEGIN TRY  
 SET NOCOUNT ON; 
 SELECT * INTO #TmpTaxGroupDetails FROM OPENJSON (@TaxGroupWiseJson)WITH(	
	ChargeDetailID INT '$.ChargeDetailID',
	ChargeTypeID INT '$.ChargeTypeID',
	ActualPercentage NUMERIC(18,4) '$.ActualPercentage',
	ChargeTypeSequence INT '$.ChargeTypeSequence',
	IsActive BIT '$.IsActive'	
	)


	IF(@Operation = 'I')
	BEGIN		
		INSERT INTO Gen_ChargeGroupDetail(ChargeHeaderID, ChargeTypeID, ActualPercentage, ChargeTypeSequence, IsActive, PropertyId,IsUpload,CreatedUserId, CreatedDateTime)
		SELECT @ChargeHeaderID,ChargeTypeID, ActualPercentage, ChargeTypeSequence, IsActive,@PropertyId,0,@UserId ,GETDATE() FROM #TmpTaxGroupDetails

		--SELECT @ID = ChargeDetailID FROM Gen_ChargeGroupDetail WHERE Code = @Code
		---- audit trail	 
		--EXEC [dbo].[AuditTrail_InsertToHistory] 'TaxGroup_Details',@ID
		---- end of audit trail

		---- audit trail				
		--SET @Remark = 'Tax group details '+@Code+', '+@Description+' created.';
		--EXEC [dbo].[AuditTrail_InsertTableChanges] 'TaxGroup_Details',@ID,@UserId,'I',@Remark
		-- end of audit trail	

	END
	ELSE
	BEGIN


			delete from Gen_ChargeGroupDetail where ChargeHeaderID=@ChargeHeaderID AND PropertyId=@PropertyId
			
			INSERT INTO Gen_ChargeGroupDetail(ChargeHeaderID, ChargeTypeID, ActualPercentage, ChargeTypeSequence, IsActive,PropertyId,IsUpload, CreatedUserId, CreatedDateTime)
			SELECT @ChargeHeaderID,ChargeTypeID, ActualPercentage, ChargeTypeSequence, IsActive,@PropertyId,0,@UserId ,GETDATE() FROM #TmpTaxGroupDetails
		
		
		-- audit trail	 
		--EXEC [dbo].[AuditTrail_InsertToHistory] 'TaxGroup_Details',@ID
		-- end of audit trail

		--UPDATE Gen_ChargeGroupDetail
		--SET 
		--ChargeHeaderID = @ChargeHeaderID,	
		--ChargeTypeID = @ChargeTypeID, 
		--ActualPercentage = @ActualPercentage,
	 --   ChargeTypeSequence = @ChargeTypeSequence,		
	 -- --  IsActive = @IsActive,		
		-- ModifiedUserId = @UserId,
	     --ModifiedDate = GETDATE()		
		--WHERE 	ChargeDetailID =@ChargeDetailID

		-- audit trail				
		--SET @Remark = 'Tax group details '+@Code+', '+@Description+' updated.';
		--EXEC [dbo].[AuditTrail_InsertTableChanges] 'TaxGroup_Details',@ID,@UserId,'U',@Remark
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

