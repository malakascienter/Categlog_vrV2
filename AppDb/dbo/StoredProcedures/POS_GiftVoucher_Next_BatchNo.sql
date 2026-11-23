
CREATE PROCEDURE [dbo].[POS_GiftVoucher_Next_BatchNo] 
@PropertyId INT
AS
BEGIN
	
	SELECT ISNULL((MAX(BatchNo) + 1), 1) AS MaxBatchNo
	FROM POS_GiftVoucher
	WHERE PropertyId = @PropertyId
END

GO

