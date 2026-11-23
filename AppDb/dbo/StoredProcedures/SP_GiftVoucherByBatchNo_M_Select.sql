
CREATE PROCEDURE [dbo].[SP_GiftVoucherByBatchNo_M_Select] 
@PropertyId INT,
@BatchNo INT
AS
BEGIN
	
	SELECT *
	FROM POS_GiftVoucher
	WHERE PropertyId = @PropertyId AND BatchNo=@BatchNo


END

GO

