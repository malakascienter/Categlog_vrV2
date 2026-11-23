CREATE PROCEDURE [dbo].[SP_UpdateMRNItemRegistryQuantity]
	@ItemID INT,
	@BOQID INT,
	@ProjectID INT,
	@Qunatity Decimal,
	@LastModUserID int,
	@status[int] output,
	@message NVARCHAR(max) OUTPUT

	
AS
BEGIN
UPDATE MRNItemRegistries
SET BOQQuantity=@Qunatity,LastModUserID=@LastModUserID
where itemid=@ItemID and BOQId=@BOQID and ProjectID=@ProjectID



BEGIN TRY
	BEGIN TRANSACTION

	
			SET @status = 1;
COMMIT TRAN 
END TRY

BEGIN CATCH
SET @status = -1;
SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH

END

GO

