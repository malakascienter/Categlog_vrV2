
CREATE PROCEDURE [dbo].[SP_Save_ItemSchedule] 
	@ID		INT,
	@MenuCode	VARCHAR(10),
	@FromDate	DATE,
	@ToDate		DATE,
	@FromTime	DATETIME,
	@ToTime		DATETIME,
	@ScheduleItemDayJson NVARCHAR(MAX),
	@PropertyId INT
AS
BEGIN			

	DELETE FROM POS_MenuItemSchedule WHERE MenuCode = @MenuCode AND PropertyId = @PropertyId
	DELETE FROM POS_MenuItemScheduleDays WHERE MenuCode = @MenuCode AND PropertyId = @PropertyId

	INSERT INTO [dbo].[POS_MenuItemSchedule]
           ([MenuCode]
           ,[FromDate]
           ,[ToDate]
           ,[FromTime]
           ,[ToTime]
		   ,PropertyId)
     VALUES
           (@MenuCode
           ,@FromDate
           ,@ToDate
           ,@FromTime
           ,@ToTime
		   ,@PropertyId)

	INSERT INTO POS_MenuItemScheduleDays(MenuCode, DayName,PropertyId)
	--SELECT IDENT_CURRENT('POS_MenuItemSchedule'), @MenuCode, DayName
	SELECT   @MenuCode, DayName,@PropertyId
	FROM OPENJSON(@ScheduleItemDayJson)
	WITH
	(
		DayName	VARCHAR(50) '$.DayName'
	)

	UPDATE POS_MenuItemSchedule 
	SET IsUpload = 0
	WHERE MenuCode = @MenuCode AND PropertyId = @PropertyId

	 --TRANSFER FROM HO TO OUTLET SYNC
	INSERT INTO Sync_MasterDataTransferStatus
	SELECT @PropertyId,A.MenuItemCode, B.code, 'MenuItemSchedule', 1
	FROM (SELECT @MenuCode AS MenuItemCode) A
	CROSS JOIN Location_Ref B WHERE B.Active = 1 


	

END

GO

