-- =============================================
-- Author:		Nivesh
-- Create date: 2025-11-24
-- Description:	Get Data for dropdown in Reports
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_GetDropDownData] 
	@DropdownName NVARCHAR(300),
	@SPParam NVARCHAR(MAX) = '{}',
	@DropDownDataJson NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@SPParam IS NULL)
		SET @SPParam = '{}'

	DECLARE @UserID INT,
	@PropertyID INT
    -- Insert statements for procedure here
	IF(@DropdownName = 'LocationDropDown')
	BEGIN
		SET	@DropDownDataJson = (SELECT Id, [Name] AS [text] 
									FROM Locations 
									FOR JSON PATH)
	END
	ELSE IF(@DropdownName = 'OrderTypeDropDown')
	BEGIN
		SET	@DropDownDataJson = (SELECT Id, OrderTypeName AS [text] 
									FROM  [dbo].[SPO_OrderType]
									FOR JSON PATH)
	END
	ELSE IF(@DropdownName = 'PayTypeDropDown')
	BEGIN
		SET	@DropDownDataJson = (SELECT Id, [Description] AS [text] 
									FROM  [dbo].[PaymentTypes]
									FOR JSON PATH)
	END
	ELSE IF(@DropdownName = 'CustomerTypeDropDown')
	BEGIN
		SET	@DropDownDataJson = (SELECT Id, CustomerTypeName AS [text] 
									FROM  [dbo].[SPO_CustomerType]
									FOR JSON PATH)
	END
	ELSE IF(@DropdownName = 'UserNameDropDown')
	BEGIN
		SET	@DropDownDataJson = (SELECT Id, userName AS [text] 
									FROM  CentralUsers
									FOR JSON PATH)
	END
	ELSE IF(@DropdownName = 'CategoryDropDown')
	BEGIN
		SET	@DropDownDataJson = (SELECT Id, [name] AS [text] 
									FROM  categories
									FOR JSON PATH)
	END
	IF(@DropdownName = 'UserWiseLocationDropDown')
	BEGIN
		SET @UserID = JSON_VALUE(@SPParam, '$.UserID');
		SET @PropertyID = JSON_VALUE(@SPParam, '$.PropertyID');

		IF(@SPParam = '{}')
		BEGIN
			SET @UserID = 0;
			SET @PropertyID = 0;
		END
		SET	@DropDownDataJson = (SELECT DISTINCT
										LR.code AS id,
										LR.description AS text
									FROM [dbo].[UserWiseOutlet] UWO
									INNER JOIN Location_Ref LR ON LR.code = UWO.OutletCode
									WHERE LR.Active =1
									AND UWO.PropertyId = CASE WHEN @PropertyID =0 THEN  UWO.PropertyId ELSE @PropertyID END
									AND UWO.UserId = CASE WHEN @userID =0 THEN UWO.UserId ELSE @userID END
								FOR JSON PATH)
	END
END

GO

