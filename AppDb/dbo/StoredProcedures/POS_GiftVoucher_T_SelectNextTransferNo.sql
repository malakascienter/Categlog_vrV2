

CREATE PROCEDURE [dbo].[POS_GiftVoucher_T_SelectNextTransferNo] 
@PropertyId		INT
AS
BEGIN
	SELECT ISNULL((MAX(TransferNo) + 1), 1) AS TransferNo
	FROM POS_GiftVoucher WHERE PropertyId = @PropertyId
END

GO

