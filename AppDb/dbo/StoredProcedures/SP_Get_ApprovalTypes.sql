
CREATE PROCEDURE SP_Get_ApprovalTypes
AS
BEGIN

SELECT Id,ApprovalTypeName AS Name FROM dbo.ApprovalTypes

END

GO

