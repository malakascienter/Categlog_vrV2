
CREATE PROCEDURE [dbo].[POS_GiftVoucher_SaveVoucherTransfer] 
	@TransferVoucherlistJSON	VARCHAR(MAX),
	@UserId						INT,
	@PropertyId		INT
AS
BEGIN TRY
	
	BEGIN TRANSACTION

	DECLARE @TempTransferList TABLE
	(
		VoucherMode VARCHAR(10),
		TypePrefix	VARCHAR(10),
		TransferNo	INT,
		StartNo		INT, 
		Quantity	INT,
		OutletCode	VARCHAR(10)
	)

	SELECT *
	INTO #TempTrasferVoucher
	FROM OPENJSON(@TransferVoucherlistJSON)
	WITH
	(
		TypePrefix	VARCHAR(10) '$.TypePrefix',
		VoucherMode VARCHAR(10) '$.VoucherMode',
		TransferNo	INT			'$.TransferNo',
		StartNo		INT			'$.StartNo',
		Quantity	INT			'$.Quantity',
		OutletCode	VARCHAR(10) '$.OutletCode'
	) 

	DECLARE @Count			INT = 0,
			@TypePrefix		VARCHAR(10),
			@VocuherMode	VARCHAR(10),
			@TransferNo		INT,
			@StartNo		INT,
			@Quantity		INT,
			@OutletCode		VARCHAR(10),
			@TransferUser	VARCHAR(50) = (SELECT Username FROM [Users] WHERE Id = @UserId) 

	WHILE EXISTS(SELECT TOP 1 1 FROM #TempTrasferVoucher)
	BEGIN
		
		SELECT TOP 1	@TypePrefix = TypePrefix, @VocuherMode = VoucherMode, 
						@TransferNo = TransferNo,  @StartNo = StartNo, 
						@Quantity = Quantity, @OutletCode = OutletCode, @Count = 0
		FROM #TempTrasferVoucher
					  
		WHILE(@Count < @Quantity)
		BEGIN
			UPDATE  POS_GiftVoucher
			SET TransferNo = @TransferNo,
				TransferUser = ISNULL(@TransferUser,'scienter'),
				TransferDate = GETDATE(),
				TransferOutlet = @OutletCode
			WHERE VoucherMode = @VocuherMode AND TypePrefix = @TypePrefix AND VoucherNo = @StartNo AND PropertyId = @PropertyId

			SET @StartNo = @StartNo + 1
			SET @Count = @Count + 1
		END
					 		
		DELETE TOP (1) FROM #TempTrasferVoucher
					 	
	END

	COMMIT TRANSACTION

END TRY
BEGIN CATCH

	INSERT INTO GEN_ErrTable(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, SysDate)
	VALUES(ERROR_NUMBER() , ERROR_SEVERITY() , ERROR_STATE(), ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), GETDATE())

END CATCH

GO

