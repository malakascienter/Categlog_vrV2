
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReportRevPAR] 
	(
		@date varchar(20)
	)
	
AS

Declare @RoomCode varchar(4)
Declare @RoomType varchar(100)
Declare @RoomArea varchar(100)
DECLARE @DATE1 DATETIME

Declare @MTDRooms money 
Declare @MTDTotalRooms money
Declare @MTDRev money
Declare @MTDOOO money
Declare @MTDARR money
Declare @MTDRevPAR money
Declare @MTDOccu money


Declare @YTDRooms money
Declare @YTDTotalRooms money
Declare @YTDRev	money
Declare @YTDOOO money
Declare @YTDARR money
Declare @YTDRevPAR money
Declare @YTDOccu money

declare @TempRevPAR table
(
	RoomCode varchar(4),
	RoomType varchar(100),
	RoomAre varchar(100),
	
	MTDRooms money ,
	MTDRev money,
	MTDOOO money,
	MTDARR money,
	MTDRevPAR money,
	MTDOccu money,
	
	YTDRooms money,
	YTDRev	money,
	YTDOOO money,
	YTDARR money,
	YTDRevPAR money,
	YTDOccu money
)


Declare @temp Table 
(
   RoomCode varchar(5),
   Name  varchar(20),
   RoomArea varchar(20),
   RoomType varchar(20)
)

SET @DATE1 =CONVERT(DATETIME,@DATE ,103)	

BEGIN TRANSACTION


    insert into @temp 
	SELECT     RoomRef.RoomCode, RoomRef.Name, RoomArea.Description AS RoomArea, RoomCatRef.Description AS RoomType
			FROM RoomRef INNER JOIN RoomArea ON RoomRef.Area = RoomArea.Code INNER JOIN
                      RoomCatRef ON RoomRef.RoomCat = RoomCatRef.Code where roomref.Tem=0

	
	select top(1) @RoomCode  = RoomCode ,@RoomType=RoomType,@RoomArea =RoomArea from @temp 
	while @@ROWCOUNT >0 
	begin
			
		set	@MTDRooms =0
		set	@MTDRev =0
		set	@MTDOOO  =0
		set	@MTDARR =0
		set	@MTDRevPAR =0
		set	@MTDOccu =0
			
		set	@YTDRooms =0
		set	@YTDRev	=0
		set	@YTDOOO =0
		set	@YTDARR =0
		set	@YTDRevPAR =0
		set	@YTDOccu =0


        -- get no of day for monthtodate and yeartodate
        
        set @MTDTotalRooms =DATEDIFF(D,DATEADD(mm, DATEDIFF(mm,0,@DATE1), 0),@DATE1)+1
        set @YTDTotalRooms =DATEDIFF(D,DATEADD(yy, DATEDIFF(yy,0,@DATE1), 0),@DATE1)+1

		--today 
		        
		--MTD
		select @MTDRooms  =sum(C.Rooms) ,@MTDRev  =sum(C.Rev)  from (
		select rooms,dbo.GetBasisAllocation(resdate,mealplan,roomtype,rev1) as Rev from (
		SELECT COUNT(GuestHisRoomDetail.RoomCode) AS Rooms, SUM( (case when GuestHisRoomDetail.Comple=0 then GuestHisRoomDetail.RoomRate else 0 end ) * dbo.GetExRate(GuestHisRoomDetail.ResDate,GuestHisRoomDetail.ResNo,'RS',GuestHisRoomDetail.Curr)) AS Rev1,GuestHisRoomDetail.resdate,GuestHisRoomDetail.mealplan,GuestHisRoomDetail.roomtype  FROM   
		     	GuestHisRoomDetail inner join guesthisMaster on GuestHisRoomDetail.resno = guesthisMaster.resno
				where day(GuestHisRoomDetail.ResDate) <=day(CONVERT(DATETIME, @date, 103)) and month(GuestHisRoomDetail.ResDate) =month(CONVERT(DATETIME, @date, 103)) and year(GuestHisRoomDetail.ResDate) =year(CONVERT(DATETIME, @date, 103))
			    and  GuestHisRoomDetail.RoomCode =@RoomCode
		group by GuestHisRoomDetail.resdate,GuestHisRoomDetail.mealplan,GuestHisRoomDetail.roomtype) as c1
		union all
        select rooms,dbo.GetBasisAllocation(resdate,mealplan,roomtype,rev1) as Rev from (  
		SELECT COUNT(GuestRoomDetail.RoomCode) AS Rooms, SUM( (case when GuestRoomDetail.Comple=0 then GuestRoomDetail.RoomRate else 0 end ) * dbo.GetExRate(GuestRoomDetail.ResDate,GuestRoomDetail.ResNo,'RS',GuestRoomDetail.Curr)) AS Rev1, GuestRoomDetail.resdate,GuestRoomDetail.mealplan,GuestRoomDetail.roomtype FROM   
		            GuestRoomDetail inner join guestMaster on GuestRoomDetail.resno = guestMaster.resno
		            where day(GuestRoomDetail.ResDate) <=day(CONVERT(DATETIME, @date, 103)) and month(GuestRoomDetail.ResDate) =month(CONVERT(DATETIME, @date, 103)) and year(GuestRoomDetail.ResDate) =year(CONVERT(DATETIME, @date, 103))
		              and  GuestRoomDetail.RoomCode =@RoomCode
		group by GuestRoomDetail.resdate,GuestRoomDetail.mealplan,GuestRoomDetail.roomtype) c2) as C
		
		--YTD
		
     	select @YTDRooms  =sum(C.Rooms) ,@YTDRev  =sum(C.Rev)  from (

		select rooms,dbo.GetBasisAllocation(resdate,mealplan,roomtype,rev1) as Rev from (
		SELECT COUNT(GuestHisRoomDetail.RoomCode) AS Rooms, SUM( (case when GuestHisRoomDetail.Comple=0 then GuestHisRoomDetail.RoomRate else 0 end ) * dbo.GetExRate(GuestHisRoomDetail.ResDate,GuestHisRoomDetail.ResNo,'RS',GuestHisRoomDetail.Curr)) AS Rev1,GuestHisRoomDetail.resdate,GuestHisRoomDetail.mealplan,GuestHisRoomDetail.roomtype FROM   
		            GuestHisRoomDetail  inner join guesthisMaster on GuestHisRoomDetail.resno = guesthisMaster.resno
		            where day(GuestHisRoomDetail.ResDate) <=day(CONVERT(DATETIME, @date, 103)) and month(GuestHisRoomDetail.ResDate) <=month(CONVERT(DATETIME, @date, 103)) and year(GuestHisRoomDetail.ResDate) =year(CONVERT(DATETIME, @date, 103))
		              and  GuestHisRoomDetail.RoomCode =@RoomCode 
		group by GuestHisRoomDetail.resdate,GuestHisRoomDetail.mealplan,GuestHisRoomDetail.roomtype) as c3

        union all

        select rooms,dbo.GetBasisAllocation(resdate,mealplan,roomtype,rev1) as Rev from (		
		SELECT COUNT(GuestRoomDetail.RoomCode) AS Rooms, SUM( (case when GuestRoomDetail.Comple=0 then GuestRoomDetail.RoomRate else 0 end ) * dbo.GetExRate(GuestRoomDetail.ResDate,GuestRoomDetail.ResNo,'RS',GuestRoomDetail.Curr)) AS Rev1,GuestRoomDetail.resdate,GuestRoomDetail.mealplan,GuestRoomDetail.roomtype FROM   
		            GuestRoomDetail  inner join guestMaster on GuestRoomDetail.resno = guestMaster.resno
		            where day(GuestRoomDetail.ResDate) <=day(CONVERT(DATETIME, @date, 103)) and month(GuestRoomDetail.ResDate) <=month(CONVERT(DATETIME, @date, 103)) and year(GuestRoomDetail.ResDate) =year(CONVERT(DATETIME, @date, 103))
		              and  GuestRoomDetail.RoomCode =@RoomCode
		group by GuestRoomDetail.resdate,GuestRoomDetail.mealplan,GuestRoomDetail.roomtype) as c4
		) as C


        select @MTDOOO = count(RoomCode) from HousekeepingLog where  day(HousekeepingLog.Date) <=day(CONVERT(DATETIME, @date, 103)) and month(HousekeepingLog.Date) =month(CONVERT(DATETIME, @date, 103)) and year(HousekeepingLog.Date) =year(CONVERT(DATETIME, @date, 103)) and HousekeepingLog.Status='O' and HousekeepingLog.RoomCode =@RoomCode 
        select @YTDOOO  = count(RoomCode) from HousekeepingLog where  day(HousekeepingLog.Date) <=day(CONVERT(DATETIME, @date, 103)) and month(HousekeepingLog.Date) <=month(CONVERT(DATETIME, @date, 103)) and year(HousekeepingLog.Date) =year(CONVERT(DATETIME, @date, 103)) and HousekeepingLog.Status='O'  and HousekeepingLog.RoomCode =@RoomCode
		
		--HousekeepingLog
		
		
		-- get MTdate and Year to Date ARR
		set @MTDARR = (@MTDRev/@MTDRooms)
		set @YTDARR  = (@YTDRev /@YTDRooms) 
		
		-- get MTdate and Year to Date Occupancy
		set @MTDOccu = @MTDRooms /(@MTDTotalRooms-@MTDOOO)*100
		set @YTDOccu = @YTDRooms /(@YTDTotalRooms-@YTDOOO)*100
		
		-- get MTdate and Year to Date RevPAR
		
		set @MTDRevPAR = @MTDRev /(@MTDTotalRooms)
		set @YTDRevPAR = @YTDRev /(@YTDTotalRooms)
				
		insert into @TempRevPAR (RoomCode ,RoomType,RoomAre,MTDRooms ,MTDRev,MTDOOO ,MTDARR,MTDRevPAR,MTDOccu,YTDRooms,YTDRev,YTDOOO,YTDARR,YTDRevPAR,YTDOccu )
						  values(@RoomCode,@RoomType,@RoomArea,isnull(@MTDRooms,0),isnull(@MTDRev,0),isnull(@MTDOOO,0),isnull(@MTDARR,0),isnull(@MTDRevPAR,0),isnull(@MTDOccu,0),isnull(@YTDRooms,0),isnull(@YTDRev,0),isnull(@YTDOOO,0),isnull(@YTDARR,0),isnull(@YTDRevPAR,0),isnull(@YTDOccu,0))
		
		delete from @temp where RoomCode  =@RoomCode 
		select top(1) @RoomCode  = RoomCode ,@RoomType=RoomType,@RoomArea =RoomArea from @temp 
	end
COMMIT TRANSACTION

select * from @TempRevPAR 

--drop table @temp 

GO

