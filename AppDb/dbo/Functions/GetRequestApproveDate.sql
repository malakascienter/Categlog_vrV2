
CREATE FUNCTION [dbo].[GetRequestApproveDate](@TransactionHeaderID int)
Returns  VARCHAR(30)
AS
BEGIN
RETURN (
select CONVERT(VARCHAR, MAX(Isnull(ApprovalDate,CreatedDate))) from [dbo].[ApprovalLogs]
where TransactionHeaderID=@TransactionHeaderID
AND TransactionID=1)
END

GO

