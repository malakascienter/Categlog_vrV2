
CREATE PROCEDURE [dbo].[DayEnd_UpdateHotelDate]
@PropertyId INT
AS
BEGIN
	
	UPDATE POS_OutletWiseMenuItemPrice
	SET Price = NewPrice
	WHERE CONVERT(DATE,EffectiveDate,103) = CONVERT(DATE,GETDATE(),103)

	UPDATE M SET M.IsUpload=0 FROM MainMenu M INNER JOIN POS_OutletWiseMenuItemPrice T ON M.ItemCode = T.MenuItemCode
	WHERE CONVERT(DATE,T.EffectiveDate,103) = CONVERT(DATE,GETDATE(),103)

	UPDATE Companies
	SET CurrentDate = DATEADD(D,1,CurrentDate)
	WHERE CompanyID = @PropertyId

	DECLARE @CurrentDate DATE
	SELECT @CurrentDate = CurrentDate FROM Companies WHERE CompanyID = @PropertyId

	UPDATE Location_Ref
	SET CurrentDate = @CurrentDate
	WHERE PropertyId = @PropertyId
	
END

GO

