CREATE PROCEDURE [dbo].[GetLoginUserDetils]
	@UserId int,
	@companyId INT
AS
BEGIN
------------------------------------------------------------
BEGIN TRY 
IF(@UserId = 0)
		BEGIN
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END
	DECLARE @ISCentralLogin BIT

	SELECT @ISCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = @companyId

	IF(@ISCentralLogin = 1)
	BEGIN
		SELECT u.Id AS userId, u.UserName, c.PropertyId, Com.IsBudgetPo, Com.Name AS 'ComapanyName',
		com.istenderboardapplicable, com.AllowIncreasePRqty, com.PRqtyThreshold,Com.CompanySeparator,Com.SessionTimeInMinutes,
		Com.IsSupplierForAllProperty, Com.IsApprovalForGRN, Com.IsApprovalForIssueReturn,CS.MenuType,CS.IsPOType,Com.IsGRNDocUpload,Com.AllowIncreasePRAmt
		FROM [dbo].[CentralUsers] AS u
		INNER JOIN [dbo].[CentralUserWiseProperties] AS c ON u.id = c.UserId   
		INNER JOIN dbo.Companies AS Com ON c.PropertyId = Com.CompanyID
		--INNER JOIN dbo.Employees AS e ON u.EmpNumber = e.Id 
		--INNER JOIN dbo.Departments AS d ON e.DepartmentID = d.Id 
		CROSS JOIN CommonSettings CS
		WHERE c.PropertyId = @companyId AND U.Id = @UserId
	END
	ELSE
	BEGIN
		SELECT d.Name AS 'DepartmentName', D.Id AS 'DepartmentID' ,u.Id AS userId, u.UserName, c.CompnayId,  Com.Name AS 'ComapanyName',
		com.istenderboardapplicable, com.AllowIncreasePRqty, com.PRqtyThreshold,Com.CompanySeparator,Com.SessionTimeInMinutes,
		Com.IsSupplierForAllProperty, Com.IsApprovalForGRN, Com.IsApprovalForIssueReturn,CS.MenuType,CS.IsPOType,Com.IsGRNDocUpload,Com.AllowIncreasePRAmt
		FROM dbo.UserMasters AS u
		INNER JOIN UserWiseCompanies AS c ON u.id = c.UserId   
		INNER JOIN dbo.Companies AS Com ON c.CompnayId = Com.CompanyID
		INNER JOIN dbo.Employees AS e ON u.EmployeeId = e.Id --AND e.CompanyID = c.CompnayId
		INNER JOIN dbo.Departments AS d ON e.DepartmentID = d.Id --AND d.PropertyID = c.CompnayId
		CROSS JOIN CommonSettings CS
		WHERE u.Id = @UserId and   c.CompnayId = @companyId
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
------------------------------------------------------------
END

GO

