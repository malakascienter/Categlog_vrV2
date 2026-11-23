--EXEC [POS_GiftVoucher_T_Save_SpecialOrder] 1,'AA','GV',0,1,'1',1200,'A00071','102',500
CREATE PROCEDURE [dbo].[POS_GiftVoucher_T_Save_SpecialOrder] 
	@BatchNo		INT,
	@TypePrefix		VARCHAR(2),
	@VoucherMode	VARCHAR(2),
	@StartNo		INT,
	@Quantity		INT,
	@UserId			INT,
	@Amount			numeric(18, 0),
	@OrderNo        VARCHAR(10),
	@LocationCode	VARCHAR(5),
	@PerVoucherAmt			MONEY
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @Count		INT = 0,
			@VoucherNo	INT ,
			@User		VARCHAR(50) =  (SELECT Username FROM Users WHERE Id = @UserId),
			@NextVoucherNo INT,
			@LastTarnId BIGINT = 0


WHILE(@Amount > 0 )
BEGIN


IF( @Amount >= @PerVoucherAmt )
BEGIN

	
	SELECT @NextVoucherNo = NextVoucherNo FROM POS_GiftVoucherTypes WHERE VoucherMode = 'EC' AND TypePrefix = 'XX'
	SET @VoucherNo = ISNULL(@NextVoucherNo,0)

	INSERT INTO POS_GiftVoucher(BatchNo, TypePrefix, VoucherMode, VoucherNo, Amount, CreateUser, CreateDate,SaleOrderNo,SaleOutlet,TransferNo)
	VALUES(@BatchNo, 'XX', 'EC', @VoucherNo, @PerVoucherAmt, ISNULL(@User,0), GETDATE(),@OrderNo,@LocationCode,1)
	
	SELECT @LastTarnId =  SCOPE_IDENTITY()

	UPDATE POS_GiftVoucherTypes
	SET NextVoucherNo = NextVoucherNo + 1
	WHERE VoucherMode = 'EC' AND TypePrefix = 'XX'

	SET @Amount = @Amount - @PerVoucherAmt


END
ELSE
BEGIN

	--IF( @LastTarnId = 0 )
	--BEGIN

		
	
		SELECT @NextVoucherNo = NextVoucherNo FROM POS_GiftVoucherTypes WHERE VoucherMode = 'EC' AND TypePrefix = 'XX'
		SET @VoucherNo = ISNULL(@NextVoucherNo,0)

		INSERT INTO POS_GiftVoucher(BatchNo, TypePrefix, VoucherMode, VoucherNo, Amount, CreateUser, CreateDate,SaleOrderNo,SaleOutlet,TransferNo)
		VALUES(@BatchNo, 'XX', 'EC', @VoucherNo, @Amount, ISNULL(@User,0), GETDATE(),@OrderNo,@LocationCode,1)
	
		SELECT @LastTarnId =  SCOPE_IDENTITY()

		UPDATE POS_GiftVoucherTypes
		SET NextVoucherNo = NextVoucherNo + 1
		WHERE VoucherMode = 'EC' AND TypePrefix = 'XX'

		SET @Amount =0
		
	--END
	--ELSE
	--BEGIN
		
	--	UPDATE POS_GiftVoucher
	--	SET Amount = Amount + @Amount
	--	WHERE ID = @LastTarnId

		
	--	SET @Amount = 0

	--END

END



END


END

GO

