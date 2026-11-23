
-- =============================================
-- Author:		Banu
-- Create date: 16/01/2019
-- Description:	Select Menu Items for outletwise price update
-- =============================================
CREATE PROCEDURE [dbo].[OutletwiseMainMenuPrice_M_Select]
AS
BEGIN
	SELECT *,discountNotApplicable AS 'DiscountNotApplicable' FROM MainMenu
	WHERE IsMainPage = 0 
		--AND Active = 1
END

GO

