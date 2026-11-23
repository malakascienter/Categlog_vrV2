-- =============================================
-- Author:		Vinuki
-- Create date: 22.05.2024
-- Description:	ReturnLocationCode 
-- =============================================
--SP_ReturnLocationCode 20,1
CREATE PROCEDURE SP_ReturnLocationCode 
		@LocationID int ,
		--@LocationName Varchar(50),
		@PropertyID int
AS
BEGIN
	SET NOCOUNT ON;

	select Code from locations where ID = @LocationID and 
	--Name = @LocationName and
	CompanyID =  @PropertyID 
	
END

GO

