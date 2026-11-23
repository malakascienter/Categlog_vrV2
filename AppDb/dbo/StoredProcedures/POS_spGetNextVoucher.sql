CREATE PROCEDURE [dbo].[POS_spGetNextVoucher]
@Outlet VARCHAR(3),
@TypePrefix VARCHAR(2),
@VoucherMode VARCHAR(2),
@VoucherCount INT
AS 
SET NOCOUNT ON

IF @VoucherCount = 1
	BEGIN
		SELECT	TOP 1 VoucherNo
		FROM	POS_GiftVoucher
		WHERE	TypePrefix = @TypePrefix AND VoucherMode = @VoucherMode AND TransferOutlet = @Outlet AND TransferNo <> 0 AND SaleOrderNo = ''
		ORDER BY VoucherNo
	END
ELSE
	BEGIN
		SELECT	VoucherNo
		FROM	POS_GiftVoucher
		WHERE	TypePrefix = @TypePrefix AND VoucherMode = @VoucherMode AND TransferOutlet = @Outlet AND TransferNo <> 0 AND SaleOrderNo = ''
		ORDER BY VoucherNo
	END

GO

