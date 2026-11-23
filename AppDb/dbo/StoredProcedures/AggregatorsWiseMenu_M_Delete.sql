
CREATE PROCEDURE [dbo].[AggregatorsWiseMenu_M_Delete] 
@PropertyId INT,
@AggType INT,
@MenuCode VARCHAR(10),
@Outlet VARCHAR(5),
@BrandID INT
AS
BEGIN
	 
	SET NOCOUNT OFF;

DECLARE @IsEnableBrandWiseMenu BIT
SELECT TOP(1) @IsEnableBrandWiseMenu = IsEnableBrandWiseMenu FROM Companies WHERE CompanyID = 	@PropertyId

IF( @IsEnableBrandWiseMenu = 0 )
BEGIN

SET @BrandId = 0

END

	DELETE FROM [dbo].[AggregatorWiseMenuItem]
      WHERE MenuCode = @MenuCode AND AggregatorId = @AggType AND PropertyId =@PropertyId AND Outlet = @Outlet AND BrandID = @BrandId

END

GO

