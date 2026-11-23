
--POS_VoucherModeWiseVoucherTypes_M_Select 'GV'
CREATE PROCEDURE [dbo].[POS_VoucherModeWiseVoucherTypes_M_Select] 
	@VoucherModeCode VARCHAR(2),
	@PropertyId INT
AS
BEGIN
	
	SELECT TypeId AS Id, VoucherMode, TypePrefix, Amount
	FROM POS_GiftVoucherTypes
	WHERE VoucherMode = @VoucherModeCode AND PropertyId = @PropertyId

END

GO

