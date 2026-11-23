
CREATE PROCEDURE [dbo].[Insert_Sync_MasterDataTransferStatus]
	@Type VARCHAR(50),
	@IsActive BIT,
	@Code VARCHAR(20),
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;


IF( (SELECT IsRestaurant FROM Companies WHERE CompanyID = @PropertyId) = 1 )
BEGIN

  --TRANSFER FROM HO TO OUTLET SYNC
	
	IF( @Type = 'MainMenu' )
	BEGIN

		--INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
		--SELECT @PropertyId,A.Code, B.code, @Type,@IsActive
		--FROM (SELECT @Code AS Code) A
		--CROSS JOIN Location_Ref B WHERE B.Active = 1 

		INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
		SELECT @PropertyId,@Code AS Code, OMP.OutletCode, @Type,@IsActive
		FROM POS_OutletWiseMenuItems OMP
		WHERE OMP.MenuCode = @Code AND OMP.PropertyId = @PropertyId

	END
	ELSE IF( @Type = 'Discount' )
	BEGIN
	     
		DECLARE @OutletListJson VARCHAR(MAX)
	    SELECT @OutletListJson = OutletListJson FROM DiscountHeader WHERE Code = @Code AND PropertyId = @PropertyId

		
		IF( ISNULL(@OutletListJson,'') != '' AND  @OutletListJson  != 'null' )
		BEGIN

				CREATE TABLE #TempDiscountLocation (
					Code VARCHAR(10)
				);

				INSERT INTO #TempDiscountLocation (Code)
				SELECT Code
				FROM OPENJSON(@OutletListJson)
				WITH (
					Code VARCHAR(10) '$.Code'
				);

				INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
				SELECT @PropertyId,A.Code, B.code, @Type,@IsActive
				FROM (SELECT @Code AS Code) A
				CROSS JOIN #TempDiscountLocation B


				INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
				SELECT @PropertyId,A.Code, B.code, @Type,0
				FROM (SELECT @Code AS Code) A
				CROSS JOIN Location_Ref B
				WHERE B.Code not in (select Code from #TempDiscountLocation)
 
				DROP TABLE #TempDiscountLocation

		END


	END
	ELSE IF( @Type = 'PaymentTypes' )
	BEGIN

		--INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
		--SELECT @PropertyId,A.Code, B.code, @Type,@IsActive
		--FROM (SELECT @Code AS Code) A
		--CROSS JOIN Location_Ref B WHERE B.Active = 1 

		
		IF EXISTS( select * from POS_OutletWisePaymentTypes OMP WHERE OMP.PayCode = @Code AND OMP.PropertyId = @PropertyId   )
		BEGIN

				INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
				SELECT @PropertyId,@Code AS Code, OMP.Outlet, @Type,CASE WHEN L.code IS NULL THEN 0 ELSE @IsActive END
				FROM POS_OutletWisePaymentTypes OMP LEFT JOIN Location_Ref L ON OMP.Outlet = L.code AND OMP.PropertyId = L.PropertyId 
				WHERE OMP.PayCode = @Code AND OMP.PropertyId = @PropertyId 

		END
		ELSE
		BEGIN

				INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
				SELECT @PropertyId,@Code AS Code, L.code, @Type,0
				FROM Location_Ref L
				WHERE L.PropertyId = @PropertyId 

		END


	END
	ELSE
	BEGIN

		INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
		SELECT @PropertyId,A.Code, B.code, @Type,@IsActive
		FROM (SELECT @Code AS Code) A
		CROSS JOIN Location_Ref B WHERE B.Active = 1 

	END

END


   


END

GO

