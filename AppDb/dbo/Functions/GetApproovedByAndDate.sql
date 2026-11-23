

create function [dbo].[GetApproovedByAndDate](@RequestHeaderID int )
returns VARCHAR(100)
AS

BEGIN
RETURN ISNULL((
SELECT top 1 u.userName +' / '+ CONVERT(VARCHAR,s.ApprovalDate) FROM ApprovalLogs S
INNER JOIN [dbo].[CentralUsers] U On U.Id= s.ApprovalUserID
WHERE TransactionHeaderID = @RequestHeaderID

ORDER BY ApprovalDate desc 
),'N/A')
END

GO

