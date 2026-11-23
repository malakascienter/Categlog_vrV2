
CREATE FUNCTION  [dbo].[GET_LastApprovedUser](@TransactionTypeID INT, @TransactionID INT)
RETURNS VARCHAR(200)
AS
BEGIN
	DECLARE @UserID INT, @UserName Varchar(200), @IsCEntralLogin BIT, @CompanyId INT

	SELECT @CompanyId = CompanyId FROM TransactionTypes WHERE Id = @TransactionTypeID

	SELECT @IsCEntralLogin = IsCEntralLogin FROM Companies WHERE CompanyID = @CompanyId

	SELECT TOP 1  @UserID= ApprovalUserID FROM ApprovalLogs A
	WHERE TransactionID=@TransactionTypeID AND TransactionHeaderID = @TransactionID and DocStatus = 'C'
	ORDER BY SEQID Desc 

	IF(@IsCEntralLogin = 1)
	BEGIN
		SELECT @UserName = UserName FROM [dbo].[CentralUsers]
		WHERE Id =@UserID
	END
	ELSE
	BEGIN
		SELECT @UserName = UserName FROM UserMasters
		WHERE Id =@UserID
	END
	
	

	RETURN @UserName

END

GO

