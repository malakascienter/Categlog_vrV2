-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: 2025-8-04
-- Description:	Save Tour guide Companies

-- [dbo].[INV_TourGuideCompanies_M_Save] 6,'001','360 Tours Lanka',50,'0786157134','4545@gmail.com',1,'U',4168,1,'I'

-- =============================================
CREATE PROCEDURE [dbo].[INV_TourGuideCompanies_M_Save] 
(
    @Id   BIGINT,  
	@Code   VARCHAR(20),  
	@Description VARCHAR(25), 
	@CommissionPercentage MONEY,
	@ContactNo  VARCHAR(15),  
	@Email VARCHAR(50),
	@IsActive BIT,  
	@Operation CHAR(1),  
	@UserId    INT,  
	@PropertyId INT,
	@Module VARCHAR(2),
	@BankName NVARCHAR(MAX),
	@BranchName NVARCHAR(MAX),
	@AccountNo NVARCHAR(MAX),
	@CompanyRegistrationNo NVARCHAR(MAX)
)
AS
BEGIN  TRY
	SET NOCOUNT ON;
	 BEGIN TRANSACTION 
	DECLARE @Remark NVARCHAR(250)
	DECLARE @NextCatgId INT	 , @RequestHeaderID INT,@IsApproved BIT
	IF @Operation ='I'  
	BEGIN 
		IF EXISTS (SELECT 1 FROm TourGuideCompanies where PropertyId=@PropertyId AND IsDelete =0 AND Module = @Module AND (code=@Code OR Description=@Description))         
		BEGIN  
			RAISERROR('Tour Guide Companies Code OR Description already exists',16,1)  
		END  
		ELSE 
		BEGIN 	
			
		IF EXISTS(SELECT 1 FROM TransactionWiseApprovalTypes WHERE TransactionID = 81 AND PropertyID = @PropertyId)
		BEGIN
			SET @IsApproved = 0
		END
		ELSE
		BEGIN
			SET @IsApproved = 1
		END
		
			INSERT INTO TourGuideCompanies(Code,Description,CommissionPercentage,ContactNo,Email,IsActive,PropertyId,IsUpload,CreatedUserId,CreatedDateTime,Module
			,BankName,BranchName,AccountNo,CompanyRegistrationNo,IsApproved)
			values (@Code,@Description,@CommissionPercentage,@ContactNo,@Email,@IsActive,@PropertyId,0,@UserId,GETDATE(),@Module
			,@BankName,@BranchName,@AccountNo,@CompanyRegistrationNo,@IsApproved)
			

			--Added by Isuru 2025-09-29 to call approval

			SELECT  @RequestHeaderID = SCOPE_IDENTITY();
			EXEC SP_InsertApprovalLevelForRequest @PropertyId,-999,81,@RequestHeaderID
			--End
			
			
		END     
	END    
	ELSE IF @Operation ='U'  
	BEGIN  
		PRINT 2
		SELECT @CommissionPercentage CommissionPercentage, @Id Id, @PropertyId PropertyId

		IF EXISTS(SELECT 1 FROM TourGuideCompanies WHERE Description = @Description AND ID <> @Id AND PropertyId = @PropertyId AND Module = @Module)
		BEGIN
		RAISERROR('Tour Guide Companies Code OR Description already exists',16,1)  
		END

		UPDATE TourGuideCompanies  
			SET    
			Description = @Description,  
			CommissionPercentage=@CommissionPercentage,
			ContactNo =@ContactNo,  
			Email=@Email,
			IsActive=@IsActive,
			LastModifiedUserID=@UserId,
			LastModifiedDateTime=GETDATE(),
			IsUpload=0,
			BankName = @BankName,
			BranchName = @BranchName,
			AccountNo = @AccountNo,
			CompanyRegistrationNo = @CompanyRegistrationNo

			WHERE Id = @Id AND PropertyId=@PropertyId


	END 
	ELSE IF @Operation ='D'  
	BEGIN  
		
		SELECT @CommissionPercentage CommissionPercentage, @Id Id, @PropertyId PropertyId
		--UPDATE TourGuideCompanies  
		--	SET    
		--	Description = @Description,  
		--	CommissionPercentage=@CommissionPercentage,
		--	ContactNo =@ContactNo,  
		--	Email=@Email,
		--	IsActive=@IsActive,
		--	PropertyId = @PropertyId,
		--	LastModifiedUserID=@UserId,
		--	LastModifiedDateTime=GETDATE(),
		--	IsUpload=0
		--	WHERE Id = @Id AND PropertyId=@PropertyId


	END 
		
	--EXEC Insert_Sync_MasterDataTransferStatus 'Category',@Active,@Code,@PropertyId
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

