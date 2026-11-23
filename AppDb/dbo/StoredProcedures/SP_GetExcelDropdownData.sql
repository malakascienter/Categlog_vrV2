-- =============================================
-- Author:		Nivesh
-- Create date: 2025-02-08
-- Description:	Getting the excel dropdown data
-- =============================================
-- SP_GetExcelDropdownData '{"Name":"Location","Value":[],"Active":true,"Parameters":"{\"userID\":4168,\"comanyid\":1}","SelectedID":1,"SelectedName":"All","SPName":"SP_GetExcelDropdownData"}'

CREATE PROCEDURE [dbo].[SP_GetExcelDropdownData] 
	@JsonData NVARCHAR(MAX),
	@TranType VARCHAR(5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @parametersValue NVARCHAR(MAX),@Name VARCHAR(50);

   	SELECT 
		@Name= JSON_VALUE(@JsonData, '$.Name'),
		@parametersValue= JSON_VALUE(@JsonData, '$.Parameters');
	
	IF(@TranType ='PR')
	BEGIN
		IF(@Name ='Location')
		BEGIN
		
			DECLARE @isProduction BIT =0,@userID INT, @comanyid INT

			SET @userID = JSON_VALUE(@parametersValue, '$.userID')
			SET @comanyid = JSON_VALUE(@parametersValue, '$.comanyid')

			SELECT DISTINCT UL.LocationID AS 'id', L.name AS 'text', L.IsMainStore
			,L.DefaultLocation
			FROM UserWise_Location AS UL
			INNER JOIN Locations AS L ON UL.LocationID = L.Id
			WHERE UL.UserID= CASE WHEN @userID = -999 THEN UL.UserID ELSE @userID END 
			AND UL.CompanyId =  CASE WHEN @comanyid = -999 THEN  UL.CompanyId ELSE @comanyid END
			AND L.IsActive = 1 AND L.IsProductionLocation = case when @isProduction=0 Then L.IsProductionLocation  ELSE @isProduction END 
			ORDER BY L.Name

		END
		ELSE
		BEGIN
			SELECT '' AS 'id','' AS 'text'
		end
	END
	ELSE
	BEGIN
		SELECT '' AS 'id','' AS 'text'
	END
END

GO

