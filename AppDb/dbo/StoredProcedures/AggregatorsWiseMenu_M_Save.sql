
CREATE PROCEDURE [dbo].[AggregatorsWiseMenu_M_Save] 
@PropertyId INT,
@MenuCode VARCHAR(10),
@AggregatorId INT,
@UserId INT,
@Outlet VARCHAR(5),
@BrandId INT
AS
BEGIN TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;

	
DECLARE @IsEnableBrandWiseMenu BIT
SELECT TOP(1) @IsEnableBrandWiseMenu = IsEnableBrandWiseMenu FROM Companies WHERE CompanyID = 	@PropertyId

IF( @IsEnableBrandWiseMenu = 0 )
BEGIN

	SET @BrandId = 0

END

	IF EXISTS(SELECT 1 FROM AggregatorWiseMenuItem WHERE MenuCode = @MenuCode AND AggregatorId = @AggregatorId AND PropertyId = @PropertyId AND Outlet= @Outlet AND BrandID = @BrandId)
	BEGIN
		RAISERROR('This Item for aggregator type is already added', 16, 1)
	END
	IF NOT EXISTS(SELECT 1 FROM POS_OutletWiseMenuItems WHERE MenuCode = @MenuCode AND OutletCode = @Outlet AND PropertyId = @PropertyId )
	BEGIN
		RAISERROR('This Item not assign to outlet', 16, 1)
	END
	ELSE
	BEGIN
		
		INSERT INTO AggregatorWiseMenuItem (MenuCode, AggregatorId, PropertyId,CreatedUserId,CreatedDateTime,Outlet,BrandID)
		VALUES( @MenuCode,@AggregatorId,@PropertyId,@UserId,GETDATE(),@Outlet,@BrandId)
		
	END

	

	
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	DECLARE @ErrorMsg VARCHAR(MAX) 
	SET @ErrorMsg = ERROR_MESSAGE()
	RAISERROR(@ErrorMsg,16,1)
END CATCH

GO

