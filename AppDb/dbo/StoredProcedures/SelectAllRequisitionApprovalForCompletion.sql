
-- [dbo].[SelectAllRequisitionApprovalForCompletion] 1,0,1,5,1,0

CREATE PROCEDURE [dbo].[SelectAllRequisitionApprovalForCompletion] --SelectAllRequisitionApprovalForCompletion 4168,0,1,-999,11,0

	@UserProfileId	INT = -1,
	@LocationID		INT = 52,
	@PropertyID		INT = -1,
	@Departmentid   INT = -1,
	@TransactionID INT = -1,
	@IsLocationFilter bit = 0
AS
BEGIN
----------------------------------------TRY CATCH----------------------------------------------
BEGIN TRY 
---------------------------------------TRY---------------------------------------------------------
	SET @LocationID = 0
	SET NOCOUNT ON;

	DECLARE @Type CHAR(2), @IsCentralLogin BIT,@NewTransactionID INT

	IF(@UserProfileId = 0)
		BEGIN
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = CASE WHEN @PropertyID = -999 THEN 1 ELSE @PropertyID END

	CREATE TABLE #TempUserTable (Id INT, UserName NVARCHAR(250), IsActive BIT , CreatedUserId INT, Password NVARCHAR(300),
	FirstName NVARCHAR(300), LastName NVARCHAR(300))



	IF(@IsCentralLogin  = 1)
	BEGIN
		INSERT INTO #TempUserTable 
		SELECT Id,UserName,IsActive,CreatedUserId, Password, FullName, ''
		FROM [dbo].[CentralUsers]

		
	END	
	ELSE
	BEGIN
		INSERT INTO #TempUserTable 
		SELECT Id,UserName,IsActive,CreatedUserId , Password, FirstName, LastName
		FROM UserMasters
	END
	
	select	DISTINCT  0 ApprovalLogID,
				 0 SeqID,
				al.TransactionID,
				al.ApprovalLevelID,
				al.TransactionHeaderID,
		
				al.PropertyID,
				al.LocationID,
				al.ApprovalUserID,
				GETDATE() ApprovalDate,
				0 IsComplete,
				--al.DocStatus,
				--UserToApprove.UserProfileID,
				--UserToApprove.TransationTypeName,
				--UserToApprove.Location,
				 LO.NAME Location , --Modified by Nivesh 2024-05-06
				--UserToApprove.Code,
				--UserToApprove.ApprovalTypeID,
				RH.Id AS 'PIID',
				RH.RequestType,
				RH.DocumentNo,
				RH.RequestDate AS 'HeadersCreatedDate',
				RH.DocumentStatus AS Status,
				1 AS 'JobNo',
				RH.IsApproved,
				RH.Remarks,
				RH.DepartmentID AS 'DepartmentID',
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				1 AS 'TransactionTypeID', --txnTypeId
				userName,
				userName AS 'firstname',
				lastName,
				up.createdUserID,
				al.LastModUserID,
				RH.RequestDate AS 'CreatedDate',
				RH.RequestDate AS 'LastModDate',
				up.isActive,
				RH.SystemDate
		, RH.UserProfileID AS 'ReqUser'
		, up.firstName+' '+up.lastName AS 'ReqUserName'
		, (SELECT SUM(ISNULL(UnitPrice,0) * RequestedQuantity) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = al.TransactionHeaderID AND RH.Flag=0) AS 'ValueOfRequest' 
		 ,AT.ApprovalTypename
		 ,[dbo].[GET_LastApprovedUser](@TransactionID,al.TransactionHeaderID) AS LastApprovedUser,
		 (SELECT Name FROM Locations WHERE Id = RH.TransferLocation) AS 'TransferLocName'
		 ,C.Name 'CompanyName'
	from 
	RequestHeaders RH
	LEFT JOIN ApprovalLogs AL on AL.TransactionHeaderID = RH.Id
	INNER JOIN  #TempUserTable up ON up.Id = RH.UserProfileID
	LEFT JOIN LOCATIONS LO ON LO.ID = RH.LocationID
	INNER JOIN dbo.ApprovalTypes AT ON AT.Id = al.ApprovalLevelID
	INNER JOIN Companies C ON C.CompanyID = al.propertyId
	where RH.PropertyID = @PropertyID
	and RH.DocumentStatus ='P' and RH.IsApproved =1
	AND AL.TransactionID =1
	AND RH.DepartmentID = CASE WHEN @Departmentid = -999 THEN RH.DepartmentID ELSE @Departmentid END
	order by RH.SystemDate 
		
		
---------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------

    
END

GO

