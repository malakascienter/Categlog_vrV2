
--POS_Voucher_T_SelectNextStartNo 'GV', '05'
CREATE PROCEDURE [dbo].[POS_Voucher_T_SelectNextStartNo] 
	@VoucherMode	VARCHAR(2),
	@VoucherType	VARCHAR(2),
	@PropertyId		INT
AS
BEGIN
	SELECT ISNULL((MAX(VoucherNo) + 1), 1) AS VoucherNo
	FROM POS_GiftVoucher
	WHERE VoucherMode = @VoucherMode AND TypePrefix = @VoucherType AND PropertyId =  @PropertyId
END

GO

