CREATE PROCEDURE [dbo].[POS_spUpdateGiftVoucherSale]
@SaleOrderNo VARCHAR(6),
@SaleDate DATETIME,
@SaleOutlet VARCHAR(3),
@VoucherType VARCHAR(2),
@VoucherNo BIGINT,
@VoucherMode VARCHAR(2)

AS 

DECLARE @NoOfGiftVoucherExpiryDays INT, @ExpiryDate DATETIME

SET @NoOfGiftVoucherExpiryDays = (SELECT TOP 1 GiftVoucherExpiryDays FROM Companies)
SET @ExpiryDate = DATEADD(DAY, @NoOfGiftVoucherExpiryDays, @SaleDate)

UPDATE	POS_GiftVoucher SET SaleOrderNo = @SaleOrderNo, SaleDate = @SaleDate, SaleOutlet = @SaleOutlet, ExpiryDate = @ExpiryDate
WHERE	TypePrefix = @VoucherType AND VoucherNo = @VoucherNo AND VoucherMode = @VoucherMode

GO

