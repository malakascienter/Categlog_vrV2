CREATE PROCEDURE [dbo].[SP_ReCallGrnSuppIssueApprovalHeader] (@headerID INT)
AS
BEGIN
DECLARE @IsCentralLogin BIT, @CompanyId INT



	DECLARE @LocationId INT, @DocNo VARCHAR(20), @CreatedDate Date,@TxnType CHAR(3), @ReqUser VARCHAR(300)

		SELECT @LocationId = LocationId, @DocNo = ApprovalDocNo,@CreatedDate = CreatedDate, 
		@TxnType = TransactionType, @ReqUser = CreatedUserId, @CompanyId= CompanyId
		FROM  GRNApprovalLog 
		WHERE Id = @headerID


	DECLARE @UserTempTable TABLE(
	Id INT,
	FirstName NVARCHAR(300),
	LastName NVARCHAR(300)
	)
	
	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = CASE WHEN @CompanyId = -999 THEN CompanyID ELSE @CompanyId END 

	IF(@IsCentralLogin = 1)
	BEGIN
		INSERT INTO @UserTempTable
		SELECT Id,FullName,''
		FROM [dbo].[CentralUsers]
	END
	ELSE
	BEGIN
		INSERT INTO @UserTempTable
		SELECT Id, FirstName, LastName 
		FROM UserMasters
	END

		SELECT L.Name AS LocationName, '' AS DepartmentName, '' AS TransferLocationName, @DocNo AS DocumentNo,@CreatedDate AS RequestDate ,@headerID AS Id,
		@TxnType AS RequestType, UM.FirstName AS RequestedUser, 'Doc Number' AS DocumentType
		FROM GRNApprovalLog TD
		INNER JOIN Locations L On L.Id = @LocationId
		INNER JOIN @UserTempTable UM ON UM.Id = @ReqUser
		WHERE TD.Id = @headerID
END

GO

