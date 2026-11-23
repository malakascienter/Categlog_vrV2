CREATE Function [dbo].[GET_NetPendingApproval](@TransactionTypeID INT, @TransactionID INT)
RETURNS VARCHAR(200)
AS
BEGIN

	DECLARE @UserID INT, @ApprovalLevl Varchar(200), @IsCentralLogin BIT, @CompanyId INT

	SELECT @CompanyId = CompanyId FROM TransactionTypes WHERE Id = @TransactionTypeID

	SELECT @IsCEntralLogin = IsCEntralLogin FROM Companies WHERE CompanyID = @CompanyId

	SELECT TOP 1  @ApprovalLevl= t.ApprovalTypeName FROM ApprovalLogs A
	INNER JOIN approvaltypes t ON t.id = a.ApprovalLevelID  
	WHERE TransactionID=@TransactionTypeID AND TransactionHeaderID = @TransactionID and DocStatus = 'P'
	ORDER BY SEQID Desc 

	
	RETURN @ApprovalLevl

END

GO

