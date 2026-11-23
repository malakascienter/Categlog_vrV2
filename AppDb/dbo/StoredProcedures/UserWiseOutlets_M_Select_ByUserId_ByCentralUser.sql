-- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[UserWiseOutlets_M_Select_ByUserId] 1,1
CREATE PROCEDURE [dbo].[UserWiseOutlets_M_Select_ByUserId_ByCentralUser]
@UserId  INT,
@PropertyId INT,
@UserJson       NVARCHAR(MAX)
AS
BEGIN	
	SET NOCOUNT ON;

	CREATE TABLE #TEMUSER (
		[Id] INT NOT NULL,
		[Username] NVARCHAR(100) NULL,
		[UserRoleId] INT NULL,
		[IsGroupUser] BIT
	)

	INSERT INTO #TEMUSER(Id,Username,UserRoleId,IsGroupUser)  
	SELECT Id,Username,UserRoleId,IsGroupUser
	FROM   
	OpenJson(@UserJson)  
	WITH  
	(  
	Id INT '$.Id',  
	Username NVARCHAR(100) '$.Username' ,
	UserRoleId NVARCHAR(100) '$.UserRoleId' ,
	IsGroupUser BIT '$.IsGroupUser' 
	)

	IF exists(select 1 from #TEMUSER where Id=@UserId and IsGroupUser=1)
	BEGIN
		SELECT * from Location_Ref where PropertyId=@PropertyId
	END
	else
	BEGIN
		
		IF EXISTS( SELECT * FROM Companies WHERE CompanyID = @PropertyId AND  EnableAllOutletAccessToUser = 1 )
		BEGIN

				SELECT LR.code AS Code,LR.description,LR.Active AS IsActive,LR.OutletDatabase,LR.OutletServer,LR.OutletServerPassword,LR.OutletServerUsername,LR.CurrentDate, CONVERT(varchar,LR.CurrentDate,103) AS CurrentDateStr
				FROM Location_Ref LR
				--Inner join UserWiseOutlet AS UWO On LR.code = UWO.OutletCode
				--INNER JOIN Users AS U ON U.Id=uwo.Id	AND U.PropertyId=uwo.PropertyId
				WHERE --LR.Active = 1 AND 
				LR.PropertyId=@PropertyId --OR u.IsGroupUser=1 

		END
		ELSE
			BEGIN

				SELECT UWO.OutletCode AS Code,UWO.Id,LR.description,UWO.IsActive,LR.OutletDatabase,LR.OutletServer,LR.OutletServerPassword,LR.OutletServerUsername,LR.CurrentDate, CONVERT(varchar,LR.CurrentDate,103) AS CurrentDateStr
				FROM Location_Ref LR
				Inner join UserWiseOutlet AS UWO On LR.code = UWO.OutletCode AND LR.PropertyId = UWO.PropertyId
				--INNER JOIN Users AS U ON U.Id=uwo.Id	AND U.PropertyId=uwo.PropertyId
				WHERE UWO.UserId = @UserId 
				--AND LR.Active = 1 
				AND LR.PropertyId=@PropertyId --OR u.IsGroupUser=1 

		END

	END


	DELETE FROM #TEMUSER

END

GO

