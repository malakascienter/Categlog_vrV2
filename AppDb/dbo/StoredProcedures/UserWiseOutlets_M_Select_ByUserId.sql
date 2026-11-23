-- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[UserWiseOutlets_M_Select_ByUserId] 1,1
CREATE PROCEDURE [dbo].[UserWiseOutlets_M_Select_ByUserId]
@UserId  INT,
@PropertyId INT
AS
BEGIN	
	SET NOCOUNT ON;

	IF exists(select 1 from Users where id=@UserId and IsGroupUser=1)
	BEGIN
		SELECT * from Location_Ref where PropertyId=@PropertyId
	END
	else
	BEGIN
		IF EXISTS( SELECT * FROM Companies WHERE CompanyID = @PropertyId AND  EnableAllOutletAccessToUser = 1 )
		BEGIN

				SELECT LR.code AS Code,LR.description,LR.Active AS IsActive,LR.OutletDatabase,LR.OutletServer,LR.OutletServerPassword,LR.OutletServerUsername,LR.CurrentDate
				FROM Location_Ref LR
				--Inner join UserWiseOutlet AS UWO On LR.code = UWO.OutletCode
				--INNER JOIN Users AS U ON U.Id=uwo.Id	AND U.PropertyId=uwo.PropertyId
				WHERE LR.Active = 1 AND LR.PropertyId=@PropertyId --OR u.IsGroupUser=1

		END
		ELSE
			BEGIN

				SELECT UWO.OutletCode AS Code,UWO.Id,LR.description,UWO.IsActive,LR.OutletDatabase,LR.OutletServer,LR.OutletServerPassword,LR.OutletServerUsername,LR.CurrentDate
				FROM Location_Ref LR
				Inner join UserWiseOutlet AS UWO On LR.code = UWO.OutletCode AND LR.PropertyId = UWO.PropertyId
				--INNER JOIN Users AS U ON U.Id=uwo.Id	AND U.PropertyId=uwo.PropertyId
				WHERE UWO.UserId = @UserId AND LR.Active = 1 AND LR.PropertyId=@PropertyId --OR u.IsGroupUser=1

		END
	END




END

GO

