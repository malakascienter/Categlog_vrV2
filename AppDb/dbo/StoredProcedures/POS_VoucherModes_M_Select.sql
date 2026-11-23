

CREATE PROCEDURE [dbo].[POS_VoucherModes_M_Select] 
@PropertyId INT
AS
BEGIN

	SELECT * 
	FROM POS_VoucherMode WHERE PropertyId = @PropertyId

END

GO

