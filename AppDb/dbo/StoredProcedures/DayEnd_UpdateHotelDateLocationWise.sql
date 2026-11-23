
CREATE PROCEDURE [dbo].[DayEnd_UpdateHotelDateLocationWise]
@OutletCode VARCHAR(5),
@PropertyId INT
AS
BEGIN


	DECLARE @NewCurrentDate DATE

	SELECT @NewCurrentDate =   DATEADD(D,1,CurrentDate)
	FROM Location_Ref
	WHERE code = @OutletCode and PropertyId = @PropertyId

	
	UPDATE POS_OutletWiseMenuItemPrice
	SET Price = NewPrice
	WHERE CONVERT(DATE,EffectiveDate,103) = CONVERT(DATE,@NewCurrentDate,103) AND OutletCode = @OutletCode AND PropertyId = @PropertyId

	UPDATE M SET M.IsUpload=0 FROM MainMenu M INNER JOIN POS_OutletWiseMenuItemPrice T ON M.ItemCode = T.MenuItemCode
	WHERE CONVERT(DATE,T.EffectiveDate,103) = CONVERT(DATE,@NewCurrentDate,103) AND T.OutletCode = @OutletCode AND T.PropertyId = @PropertyId
	AND M.PropertyId = @PropertyId

	UPDATE Location_Ref
	SET CurrentDate = DATEADD(D,1,CurrentDate)
	WHERE code = @OutletCode and PropertyId = @PropertyId

	
END

GO

