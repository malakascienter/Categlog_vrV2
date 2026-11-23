CREATE PROCEDURE[dbo].[SP_S_GetBOQAccessSecurityFindExsist]
 --DECLARE PARAMETERS

	
	@ProjectID int,
	@BOQID nvarchar(MAX),
	@UserID int,
	@Section int,
	@Work int,
	@Rate int
	
	

AS
	
BEGIN


	
	


	select * from BOQSecurityAcesses where ProjectID=@ProjectID and BOQID =@BOQID and  UserID = @UserID and Section = @Section and Work = @Work and Rate=@Rate 
	

		

		
	
	 --ACTION 2 ENDS
	

END--SP ENDS

GO

