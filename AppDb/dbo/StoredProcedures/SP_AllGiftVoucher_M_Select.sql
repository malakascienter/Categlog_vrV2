--EXEC [SP_AllGiftVoucher_M_Select] 1,'4','-888','G1'
CREATE PROCEDURE [dbo].[SP_AllGiftVoucher_M_Select] 
@PropertyId INT,
@modeCode VARCHAR(50),
@outlet VARCHAR(5),
@voucherType VARCHAR(50)
AS
BEGIN
	
	
IF( @outlet = '-999' )
BEGIN

	SELECT gv.*,ISNULL(l.description,'N/A') AS OutletName,CONCAT(TypePrefix,'-',Amount) AS Description
	FROM POS_GiftVoucher gv left join Location_ref l on gv.TransferOutlet = l.code and gv.PropertyId = l.PropertyId
	WHERE gv.PropertyId = @PropertyId AND ISNULL(gv.SaleOrderNo,'') = ''
	AND gv.TypePrefix=@voucherType 
	--AND gv.TransferOutlet = @outlet  

END
ELSE IF( @outlet = '-888' )
BEGIN

	SELECT gv.*,ISNULL(l.description,'N/A') AS OutletName,CONCAT(TypePrefix,'-',Amount) AS Description
	FROM POS_GiftVoucher gv left join Location_ref l on gv.TransferOutlet = l.code and gv.PropertyId = l.PropertyId
	WHERE gv.PropertyId = @PropertyId  AND ISNULL(gv.TransferOutlet,'') = '' AND ISNULL(gv.SaleOrderNo,'') = ''
	AND gv.TypePrefix=@voucherType 
	--AND gv.TransferOutlet = @outlet  

END
ELSE
BEGIN

	SELECT gv.*,ISNULL(l.description,'N/A') AS OutletName,CONCAT(TypePrefix,'-',Amount) AS Description
	FROM POS_GiftVoucher gv left join Location_ref l on gv.TransferOutlet = l.code and gv.PropertyId = l.PropertyId
	WHERE gv.PropertyId = @PropertyId  AND ISNULL(gv.SaleOrderNo,'') = ''
	AND gv.TypePrefix=@voucherType 
	AND gv.TransferOutlet = @outlet  

END




END

GO

