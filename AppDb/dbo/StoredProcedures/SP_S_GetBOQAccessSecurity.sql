CREATE PROCEDURE [dbo].[SP_S_GetBOQAccessSecurity] 
    @UserID int
	
AS
BEGIN
	
	select * from BOQSecurityAcesses where UserID=@UserID
	

END

GO

