
CREATE PROCEDURE [dbo].[Outlet_M_TagUberStoreId] 
@StoreId VARCHAR(MAX),
@Outlet VARCHAR(MAX),
@PropertyId INT
AS
BEGIN

SET NOCOUNT ON;   

DECLARE @IsEnableBrandWiseMenu BIT
SELECT TOP(1) @IsEnableBrandWiseMenu = IsEnableBrandWiseMenu FROM Companies WHERE CompanyID = 	@PropertyId

IF( @IsEnableBrandWiseMenu = 0 )
BEGIN

	--UPDATE Location_Ref
	--SET StoreID = ''
	--WHERE UberEat_StoreId = @StoreId

	UPDATE Location_Ref
	SET UberEat_StoreId = ''
	WHERE UberEat_StoreId = @StoreId


	UPDATE Location_Ref
	SET UberEat_StoreId = @StoreId
	WHERE code = @Outlet

END
ELSE
BEGIN


    UPDATE BrandWiseOutletMapping
	SET UberEat_StoreId = ''
	WHERE UberEat_StoreId = @StoreId

	UPDATE BrandWiseOutletMapping
	SET UberEat_StoreId = @StoreId
	WHERE convert(varchar(max),Id) = @Outlet

END	
	
END

GO

