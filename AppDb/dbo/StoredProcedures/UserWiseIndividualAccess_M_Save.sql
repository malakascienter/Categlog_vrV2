-- =============================================  
-- Author:  Yasiru  
-- Create date: 2017-09-07  
-- Description: User Roles  
-- =============================================  
CREATE PROCEDURE [dbo].[UserWiseIndividualAccess_M_Save]  
(  
 @Operation CHAR(1),  
 @MainNavigationId INT,  
 @UserId     INT,  
 @UserWiseIndividualAccessJson  NVARCHAR(max),  
 @CreatedUserId Int , 
  @PropertyId INT
)  
  
AS  
BEGIN  
SET NOCOUNT ON;  
 IF(@Operation = 'I')  
  BEGIN  

  create table #TempIds
  (MainNavigationId int)
  
  Insert Into #TempIds
  Select MainNavigationId
  FROM 
  OPENJSON (@UserWiseIndividualAccessJson)
  WITH ( MainNavigationId INT '$.MainNavigationId' )

  DELETE FROM UserWiseIndividualAccess WHERE UserId = @UserId AND PropertyId=@PropertyId AND  MainNavigationId IN (SELECT MainNavigationId FROM #TempIds)
  
   INSERT INTO UserWiseIndividualAccess(UserId,PropertyId,MainNavigationId, PageId, IsAllowInsert, IsAllowUpdate, IsAllowDelete, IsAllowSelect, CreatedUserId, CreatedDateTime, LastUpdatedUserId, LastUpdatedDateTime)  
   Select @UserId,@PropertyId,MainNavigationId, PageId, IsAllowInsert, IsAllowUpdate, IsAllowDelete, IsAllowSelect,@CreatedUserId, GETDATE(), @CreatedUserId, GETDATE()  
   FROM   
    OPENJSON (@UserWiseIndividualAccessJson)  
      WITH (  
      PageId INT '$.PageId',
	  MainNavigationId INT '$.MainNavigationId',
      IsAllowInsert BIT '$.IsAllowInsert',  
      IsAllowUpdate BIT '$.IsAllowUpdate',  
      IsAllowDelete BIT '$.IsAllowDelete',  
      IsAllowSelect BIT '$.IsAllowSelect'  
      )  

	   If(OBJECT_ID('tempdb..#TempIds') Is Not Null)
		Begin
			Drop Table #TempIds
		End

    END  


  
END

GO

