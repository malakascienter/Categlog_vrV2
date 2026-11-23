-- =============================================
-- Author:		Nivesh
-- Create date: 2024-10-15
-- Description:	Get Transaction Wise Email
-- =============================================
--  SP_GetTransactionWiseEmail 1,1,2

CREATE PROCEDURE [dbo].[SP_GetTransactionWiseEmail]
@LocationID INT = -999, @PropertyID INT  ,@TransactionID INT
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @UserData TABLE(
	Id INT,
	UserName NVARCHAR(200),
	EmployeeId NVARCHAR(MAX)
	)

	DECLARE @IsCentralLogin BIT;

	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = @PropertyID 
	IF(@IsCentralLogin = 1)
	BEGIN
		INSERT INTO @UserData
		SELECT Id, UserName, EmpNumber
		FROM [dbo].[CentralUsers]
		WHERE IsActive=1
	END
	ELSE
	BEGIN
		INSERT INTO @UserData
		SELECT Id, UserName,EmployeeId
		FROM UserMasters
	END

	SELECT TOP (1000) TW.[ID]
      ,TW.[PropertyID]
      ,TW.[LocationID]
	  ,LO.Name LocationName
      ,TW.[TransactionType]
	  ,TT.Name TransactionName
	  ,TT.Id TransactionTypeID
      ,TW.[UserID]
	  ,UD.UserName
      ,TW.[IsActive]
  FROM [Categlog_vrV2].[dbo].[TransactionWiseEmails] TW
  INNER JOIN Locations LO ON LO.Id = TW.LocationID AND LO.IsActive =1
  INNER JOIN TransactionTypes TT ON TT.Code = TW.TransactionType  AND TT.IsActive =1
  LEFT JOIN @UserData UD ON UD.Id = TW.UserID
  WHERE TW.PropertyID = @PropertyID AND TW.LocationID = CASE WHEN  @LocationID = -999 THEN TW.LocationID ELSE @LocationID END
  AND TT.Id = @TransactionID;

END

GO

