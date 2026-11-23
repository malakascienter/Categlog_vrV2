
-- POS_GiftVoucher_T_Save 15, '10', 'EV', 1, 10, 1
CREATE PROCEDURE [dbo].[POS_GiftVoucher_T_Save] 
	@BatchNo		INT,
	@TypePrefix		VARCHAR(2),
	@VoucherMode	VARCHAR(2),
	@StartNo		INT,
	@Quantity		INT,
	@UserId			INT,
	@PropertyId		INT
AS
BEGIN TRY
	BEGIN TRANSACTION

	DECLARE @Count		INT = 0,
			@VoucherNo	INT = @StartNo,
			@Amount		DECIMAL(18, 10) = (SELECT Amount FROM POS_GiftVoucherTypes WHERE TypePrefix = @TypePrefix AND VoucherMode = @VoucherMode AND PropertyId = @PropertyId),
			@User		VARCHAR(50) =  (SELECT Username FROM Users WHERE Id = @UserId)

	WHILE(@Count < @Quantity)
	BEGIN

	    DECLARE @Number INT = 0;
		DECLARE @FormattedNumber NVARCHAR(2);
		DECLARE @encodedChars NVARCHAR(10) = ''

		


		INSERT INTO POS_GiftVoucher(BatchNo, TypePrefix, VoucherMode, VoucherNo, Amount, CreateUser, CreateDate,PropertyId,RedeemVoucherNo)
		VALUES(@BatchNo, @TypePrefix, @VoucherMode, @VoucherNo, @Amount, ISNULL(@User,'scienter'), GETDATE(),@PropertyId,'')

		DECLARE @TxnId BIGINT
   	    SET @TxnId = SCOPE_IDENTITY()

		SET @encodedChars = dbo.EncodeVoucher(@TxnId)
		SELECT @Number = COUNT(*) FROM POS_GiftVoucher WHERE RedeemVoucherNo LIKE '' +@encodedChars + '%'	
		SET @Number = @Number + 1
		SET @FormattedNumber = RIGHT('0' + CAST(@Number AS NVARCHAR(2)), 2);

		UPDATE POS_GiftVoucher
		SET RedeemVoucherNo = CONCAT(@encodedChars,@FormattedNumber)
		WHERE ID = @TxnId


		SET @VoucherNo = @VoucherNo + 1

		SET @COUNT = @COUNT + 1
	END

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION

	INSERT INTO GEN_ErrTable(ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage, SysDate)
	VALUES(ERROR_NUMBER() , ERROR_SEVERITY() , ERROR_STATE(), ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), GETDATE())

END CATCH

GO

