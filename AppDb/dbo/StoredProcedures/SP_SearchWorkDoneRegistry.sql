

CREATE PROCEDURE SP_SearchWorkDoneRegistry 
	@ProjectID int,
	@BOQID int,
	@MainWorkID int,
	@WorkID int

AS
BEGIN

SELECT        dbo.WorkDoneRegistries.*
FROM            dbo.WorkDoneRegistries
WHERE        (ProjectID = @ProjectID) AND (BOQID =@BOQID) AND (MainWorkID = @MainWorkID) AND (WorkID = @WorkID)

END

GO

