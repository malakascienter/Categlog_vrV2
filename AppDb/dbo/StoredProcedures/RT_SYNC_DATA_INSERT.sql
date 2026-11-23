
CREATE PROCEDURE RT_SYNC_DATA_INSERT
	@PropertyId INT,
	@UniqueId BIGINT,
	@Code VARCHAR(50),
	@DatType VARCHAR(50),
	@IsActive BIT,
	@IsDelete BIT,
	@LocationJson VARCHAR(MAX)
AS
BEGIN
BEGIN  TRY
BEGIN TRANSACTION
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT * 
	INTO #TempLocation
	FROM OPENJSON(@LocationJson)  
	WITH 
	(
		LocationID				int '$.LocationID'
		
	)

DECLARE @IsRestaurant BIT

SELECT @IsRestaurant = IsRestaurant FROM Companies WHERE CompanyID = @PropertyId
IF( @IsRestaurant = 1 )
BEGIN

		 INSERT INTO [dbo].[RT_Sync_MasterDataTransferStatus]
				   ([PropertyId]
				   ,[UniqueId]
				   ,[Code]
				   ,[LocationId]
				   ,[DataType]
				   ,[Active]
				   ,[Delete])
			SELECT @PropertyId,
				   @UniqueId,
				   @Code,
				   T.LocationID,
				   @DatType,
				   @IsActive,
				   @IsDelete
			FROM #TempLocation T


END
ELSE 
BEGIN

 
		IF( @DatType NOT IN ('Currency','PaymentType','User','ItemBarcode') )
		BEGIN

				 INSERT INTO [dbo].[RT_Sync_MasterDataTransferStatus]
						   ([PropertyId]
						   ,[UniqueId]
						   ,[Code]
						   ,[LocationId]
						   ,[DataType]
						   ,[Active]
						   ,[Delete])
					SELECT @PropertyId,
						   @UniqueId,
						   @Code,
						   T.LocationID,
						   @DatType,
						   @IsActive,
						   @IsDelete
					FROM #TempLocation T
 

		END
		ELSE
		BEGIN

				 INSERT INTO [dbo].[RT_Sync_MasterDataTransferStatus]
						   ([PropertyId]
						   ,[UniqueId]
						   ,[Code]
						   ,[LocationId]
						   ,[DataType]
						   ,[Active]
						   ,[Delete])
					SELECT @PropertyId,
						   @UniqueId,
						   @Code,
						   -999,
						   @DatType,
						   @IsActive,
						   @IsDelete

 

		END

END



    COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH
END

GO

