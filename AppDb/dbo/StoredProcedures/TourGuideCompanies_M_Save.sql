
CREATE  PROCEDURE [dbo].[TourGuideCompanies_M_Save]  
    @Id   BIGINT,  
	@Code   VARCHAR(20),  
	@Description VARCHAR(25), 
	@CommissionPercentage MONEY,
	@ContactNo  VARCHAR(15),  
	@Email VARCHAR(50),
	@IsActive BIT,  
	@Operation CHAR(1),  
	@UserId    INT,  
	@PropertyId INT
AS  
BEGIN  TRY
	SET NOCOUNT ON;
	DECLARE @Remark NVARCHAR(250)
	DECLARE @NextCatgId INT	 
	IF @Operation ='I'  
	BEGIN 
		IF EXISTS (SELECT 1 FROm TourGuideCompanies where PropertyId=@PropertyId AND (code=@Code OR Description=@Description))         
		BEGIN  
			RAISERROR('Tour Guide Companies Code OR Description already exists',16,1)  
		END  
		ELSE 
		BEGIN 	
			

			INSERT INTO TourGuideCompanies(Code,Description,CommissionPercentage,ContactNo,Email,IsActive,PropertyId,IsUpload,CreatedUserId,CreatedDateTime)
			values (@Code,@Description,@CommissionPercentage,@ContactNo,@Email,@IsActive,@PropertyId,0,@UserId,GETDATE())  
			
			
		END     
	END    
	ELSE IF @Operation ='U'  
	BEGIN  
		
		
		UPDATE TourGuideCompanies  
			SET    
			Description = @Description,  
			CommissionPercentage=@CommissionPercentage,
			ContactNo =@ContactNo,  
			Email=@Email,
			IsActive=@IsActive,
			PropertyId = @PropertyId,
			LastModifiedUserID=@UserId,
			LastModifiedDateTime=GETDATE(),
			IsUpload=0
			WHERE Id = @Id AND PropertyId=@PropertyId


	END 
		
	--EXEC Insert_Sync_MasterDataTransferStatus 'Category',@Active,@Code,@PropertyId
		
	END TRY 
BEGIN CATCH
ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

