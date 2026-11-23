
CREATE PROCEDURE [dbo].[POS_GiftVoucher_SaveVoucherReTransfer] 
	@TransferVoucherlistJSON	VARCHAR(MAX),
	@UserId						INT,
	@PropertyId		INT
AS
BEGIN TRY
	
	BEGIN TRANSACTION


	SELECT *
	INTO #TempTrasferVoucher
	FROM OPENJSON(@TransferVoucherlistJSON)
	WITH
	(
		ID	INT '$.ID',
		TransferNo	INT			'$.TransferNo',
		OutletCode	VARCHAR(10) '$.OutletCode'
	) 

	DECLARE @TransferNo		INT,
			@OutletCode		VARCHAR(10),
			@TransferUser	VARCHAR(50) = (SELECT Username FROM CentralAccessDB..Central_Users WHERE Id = @UserId) ,
			@ID INT

	WHILE EXISTS(SELECT TOP 1 1 FROM #TempTrasferVoucher)
	BEGIN
		
		SELECT TOP 1	@TransferNo = TransferNo,@OutletCode = OutletCode,@ID = ID
		FROM #TempTrasferVoucher
					  
		UPDATE  POS_GiftVoucher
		SET TransferNo = @TransferNo,
			TransferUser = ISNULL(@TransferUser,'scienter'),
			TransferDate = GETDATE(),
			TransferOutlet = @OutletCode
		WHERE ID = @ID AND PropertyId = @PropertyId
					 		
		DELETE TOP (1) FROM #TempTrasferVoucher
					 	
	END

	COMMIT TRANSACTION

END TRY
BEGIN CATCH

	INSERT INTO GEN_ErrTable(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, SysDate)
	VALUES(ERROR_NUMBER() , ERROR_SEVERITY() , ERROR_STATE(), ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), GETDATE())

END CATCH

GO

