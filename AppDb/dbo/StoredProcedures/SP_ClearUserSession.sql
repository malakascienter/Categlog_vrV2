

--select * from Companies
--select * from UserMasters
--select * from Departments

--Verify_Location 1,'Venora International' , 3, 'asanga' , 1 , 'Tendering'

CREATE PROCEDURE [dbo].[SP_ClearUserSession] 
	@UserID VARCHAR(max)
	
AS

BEGIN


DELETE
FROM CentralAccessDB..Central_UserWiseModuleLogin 
WHERE UserId = CONVERT(BIGINT,@UserID)

SELECT 1


END

GO

