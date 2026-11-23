-- =============================================
-- Author:		Chiraj
-- Create date: 02-10-2020
-- Description:	Food cost report setting 
-- =============================================
CREATE PROCEDURE [dbo].[FoodCostingSetting_M_Save] 
	@CostingTypeId INT,
	@ChargeCodelstJson	 NVARCHAR(MAX),	
	@PaymentTypelstJson	 NVARCHAR(MAX),
	@OutletWiseItemcategorylstJson NVARCHAR(MAX),
	@DepartmentWiseItemcategorylstJson	 NVARCHAR(MAX),
	@LocationWiseItemcategorylstJson	 NVARCHAR(MAX),

	@UserId INT,
	@PropertyId INT,
	@Operation CHAR(1)
AS
BEGIN  TRY
BEGIN TRANSACTION
	SET NOCOUNT ON;

	DELETE FROM [CostingTypeWiseChargeCodes] WHERE PropertyId=@PropertyId and costingid = @CostingTypeId -- delete previous settings
	
	INSERT INTO [dbo].[CostingTypeWiseChargeCodes](CostingId, ChargeTypeId, [Description], [Active], [PropertyId], [CreatedUserId], [CreatedDateTime])
	SELECT @CostingTypeId,ChargeTypeId, [Description], Active,@PropertyId,@UserId,GETDATE()
	FROM OPENJSON(@ChargeCodelstJson)
	WITH
	(	ChargeTypeId INT '$.ChargeTypeId',
		[Description] VARCHAR(200) '$.Description',
		Active BIT '$.Active'
	)

	Delete from CostingTypeWisePaymentTypes WHERE PropertyId=@PropertyId and costingid = @CostingTypeId

	INSERT INTO[dbo].[CostingTypeWisePaymentTypes]([CostingId], [PaymentTypeId], [PayCode], [Description], [Active], [PropertyId], [CreatedUserId], [CreatedDateTime])
	SELECT @CostingTypeId,Id,PayCode,[Description],Active,@PropertyId,@UserId,GETDATE()
	FROM OPENJSON(@PaymentTypelstJson)
	WITH
	(	Id INT '$.Id',
		PayCode VARCHAR(4) '$.PayCode',	
		Description VARCHAR(150) '$.Description',
		Active BIT '$.Active'
	)

	Delete from CostingTypeWiseOutletWiseItemCategory WHERE PropertyId=@PropertyId and costingid = @CostingTypeId

	INSERT INTO[dbo].[CostingTypeWiseOutletWiseItemCategory]([CostingId], [Code], [Active], [PropertyId],ItemCategoryId,[CreatedUserId], [CreatedDateTime])
	SELECT @CostingTypeId,Code,Active,@PropertyId,ItemCategoryId,@UserId,GETDATE()
	FROM OPENJSON(@OutletWiseItemcategorylstJson)
	WITH
	(	
		Code VARCHAR(4) '$.OutletCode',	
		ItemCategoryId INT '$.ItemCategoryId',
		Active BIT '$.Active'
	)


	Delete from CostingTypeWiseStockLocationWiseItemCategory WHERE PropertyId=@PropertyId and costingid = @CostingTypeId

	INSERT INTO[dbo].[CostingTypeWiseStockLocationWiseItemCategory]([CostingId], [Code], [Name], [Active], [PropertyId],ItemCategoryId,[CreatedUserId], [CreatedDateTime])
	SELECT @CostingTypeId,Code,Name,Active,@PropertyId,ItemCategoryId,@UserId,GETDATE()
	FROM OPENJSON(@LocationWiseItemcategorylstJson)
	WITH(
		Code VARCHAR(MAX) '$.LocationCode',	
		ItemCategoryId INT '$.ItemCategoryId',
		Name VARCHAR(150) '$.Name',
		Active BIT '$.Active'
	)

	Delete from CostingTypeWiseDepartmentsWiseItemCategory WHERE PropertyId=@PropertyId and costingid = @CostingTypeId

	INSERT INTO [dbo].[CostingTypeWiseDepartmentsWiseItemCategory](CostingId,Code, [Name], [Active], [PropertyId],ItemCategoryId, [CreatedUserId], [CreatedDateTime])
	SELECT @CostingTypeId,Code,Name,Active,@PropertyId,ItemCategoryId,@UserId,GETDATE()
	FROM OPENJSON(@DepartmentWiseItemcategorylstJson)
	WITH
	(	
		Code VARCHAR(4) '$.DepartmentCode',
		ItemCategoryId INT '$.ItemCategoryId',
		Name VARCHAR(200) '$.Name',
		Active BIT '$.Active'
	)
    
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

