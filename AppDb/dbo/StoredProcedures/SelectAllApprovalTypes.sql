-- =============================================
-- Author:		Nivesh
-- Create date: 2023.11.15
-- Description:	Get all Approval Types
-- =============================================
CREATE PROCEDURE SelectAllApprovalTypes
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
		[Id],
		[ApprovalTypeCode],
		[ApprovalTypeName],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
	FROM
	ApprovalTypes;

END

GO

