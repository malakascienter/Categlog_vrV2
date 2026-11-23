
--POS_GiftVoucher_T_SelectNextUntransferedVoucherNo 'GV', '50'
CREATE PROCEDURE [dbo].[POS_GiftVoucher_T_SelectNextUntransferedVoucherNo]
	@ModeCode		VARCHAR(10),
	@TypePrefix		VARCHAR(10),
	@PropertyId		INT
AS
BEGIN

	SELECT MIN(VoucherNo) AS StartNo, COUNT(VoucherNo) AS Quantity
	FROM POS_GiftVoucher
	WHERE VoucherMode = @ModeCode AND TypePrefix = @TypePrefix AND TransferNo = 0 AND PropertyId = @PropertyId

END

GO

