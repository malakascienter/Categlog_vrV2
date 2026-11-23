

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReportAgentsProduction] 
	(
		@date varchar(20)
	)
	
AS

Declare @AgentCode varchar(4)
Declare @AgentName varchar(100)
Declare @TdayRooms money
Declare @TodayRev money
Declare @MTDRooms money 
Declare @MTDRev money
Declare @YTDRooms money
Declare @YTDRev	money

declare @TempPro table
(
	AgentCode varchar(4),
	AgentName varchar(100),
	TDRooms money,
	TDRevenue	money,
	MTDRooms money,
	MTDRevenue money,
	YTDRooms money,
	YTDRevenue money
	
)


BEGIN TRANSACTION

	select Code,Name into #temp from AgentRef ORDER BY Name 
	
	select top(1) @AgentCode = Code,@AgentName=Name from #temp 
	while @@ROWCOUNT >0 
	begin
	     --SET @TdayRooms=0
	     --SET @TodayRev =0
	     --SET @MTDRooms=0
	     --SET @MTDRev =0
	     --SET @YTDRooms=0
	     --SET @YTDRev =0
	     

		--today 
		  select @TdayRooms =sum(A.Rooms) ,@TodayRev =sum(A.Rev)  from (
		  select SUM(Rooms) as rooms, sum(dbo.GetBasisAllocation(resdate,mealplan,roomtype,rev1)) as Rev  from (	
		  SELECT COUNT(GuestHisRoomDetail.RoomCode) AS Rooms, SUM(GuestHisRoomDetail.RoomRate * dbo.GetExRate(GuestHisRoomDetail.ResDate,GuestHisRoomDetail.ResNo,'RS',GuestHisRoomDetail.Curr)) AS Rev1,GuestHisRoomDetail.resdate,GuestHisRoomDetail.roomtype,GuestHisRoomDetail.mealplan FROM   
		            GuestHisRoomDetail INNER JOIN GuestHisMaster ON GuestHisRoomDetail.ResNo = GuestHisMaster.ResNo
		            where GuestHisRoomDetail.ResDate =CONVERT(DATETIME, @date, 103) and GuestHisRoomDetail.Comple =0 and GuestHisMaster.TourOP=@AgentCode 
					group by GuestHisRoomDetail.resdate,GuestHisRoomDetail.roomtype,GuestHisRoomDetail.mealplan) as a1
          union all
          
	      select SUM(Rooms) as rooms, sum(dbo.GetBasisAllocation(resdate,mealplan,roomtype,rev1)) as Rev  from (		
		  SELECT COUNT(GuestRoomDetail.RoomCode) AS Rooms, SUM(GuestRoomDetail.RoomRate * dbo.GetExRate(GuestRoomDetail.ResDate,GuestRoomDetail.ResNo,'RS',GuestRoomDetail.Curr)) AS Rev1,GuestRoomDetail.resdate,GuestRoomDetail.roomtype,GuestRoomDetail.mealplan FROM   
		            GuestRoomDetail INNER JOIN GuestMaster ON GuestRoomDetail.ResNo = GuestMaster.ResNo
		            where GuestRoomDetail.ResDate =CONVERT(DATETIME, @date, 103) and GuestRoomDetail.Comple =0 and  GuestMaster.TourOP=@AgentCode	            
		            group by GuestRoomDetail.resdate,GuestRoomDetail.roomtype,GuestRoomDetail.mealplan) as a2
		) as A	
		--MTD
		  select @MTDRooms  =sum(C.Rooms) ,@MTDRev  =sum(C.Rev)  from (
		  select SUM(Rooms) as rooms, sum(dbo.GetBasisAllocation(resdate,mealplan,roomtype,rev1)) as Rev  from (	
		  SELECT COUNT(GuestHisRoomDetail.RoomCode) AS Rooms, SUM(GuestHisRoomDetail.RoomRate * dbo.GetExRate(GuestHisRoomDetail.ResDate,GuestHisRoomDetail.ResNo,'RS',GuestHisRoomDetail.Curr)) AS Rev1,GuestHisRoomDetail.resdate,GuestHisRoomDetail.roomtype,GuestHisRoomDetail.mealplan FROM   
		            GuestHisRoomDetail INNER JOIN GuestHisMaster ON GuestHisRoomDetail.ResNo = GuestHisMaster.ResNo
		            where day(GuestHisRoomDetail.ResDate) <=day(CONVERT(DATETIME, @date, 103)) and month(GuestHisRoomDetail.ResDate) =month(CONVERT(DATETIME, @date, 103)) and year(GuestHisRoomDetail.ResDate) =year(CONVERT(DATETIME, @date, 103))
		             and GuestHisRoomDetail.Comple =0 and  GuestHisMaster.TourOP=@AgentCode
					group by GuestHisRoomDetail.resdate,GuestHisRoomDetail.roomtype,GuestHisRoomDetail.mealplan) as c1
          union all
          
		  select SUM(Rooms) as rooms, sum(dbo.GetBasisAllocation(resdate,mealplan,roomtype,rev1)) as Rev  from (	
		  SELECT COUNT(GuestRoomDetail.RoomCode) AS Rooms, SUM(GuestRoomDetail.RoomRate *  dbo.GetExRate(GuestRoomDetail.ResDate,GuestRoomDetail.ResNo,'RS',GuestRoomDetail.Curr)) AS Rev1,GuestRoomDetail.resdate,GuestRoomDetail.roomtype,GuestRoomDetail.mealplan FROM   
		            GuestRoomDetail INNER JOIN GuestMaster ON GuestRoomDetail.ResNo = GuestMaster.ResNo
		            where day(GuestRoomDetail.ResDate) <=day(CONVERT(DATETIME, @date, 103)) and month(GuestRoomDetail.ResDate) =month(CONVERT(DATETIME, @date, 103)) and year(GuestRoomDetail.ResDate) =year(CONVERT(DATETIME, @date, 103))
		             and GuestRoomDetail.Comple =0 and  GuestMaster.TourOP=@AgentCode
					group by GuestRoomDetail.resdate,GuestRoomDetail.roomtype,GuestRoomDetail.mealplan) as c2
		 ) as C
		
		--YTD
		select @YTDRooms  =sum(B.Rooms) ,@YTDRev  =sum(B.Rev)  from (
		select SUM(Rooms) as rooms, sum(dbo.GetBasisAllocation(resdate,mealplan,roomtype,rev1)) as Rev  from (
		SELECT COUNT(GuestHisRoomDetail.RoomCode) AS Rooms, SUM(GuestHisRoomDetail.RoomRate * dbo.GetExRate(GuestHisRoomDetail.ResDate,GuestHisRoomDetail.ResNo,'RS',GuestHisRoomDetail.Curr)) AS Rev1,GuestHisRoomDetail.resdate,GuestHisRoomDetail.roomtype,GuestHisRoomDetail.mealplan FROM   
		            GuestHisRoomDetail INNER JOIN GuestHisMaster ON GuestHisRoomDetail.ResNo = GuestHisMaster.ResNo
		            where year(GuestHisRoomDetail.ResDate) =year(CONVERT(DATETIME, @date, 103)) and GuestHisRoomDetail.Comple =0
		            and  GuestHisMaster.TourOP=@AgentCode
					group by GuestHisRoomDetail.resdate,GuestHisRoomDetail.roomtype,GuestHisRoomDetail.mealplan) as b1
		            
          union all
          
		  select SUM(Rooms) as rooms, sum(dbo.GetBasisAllocation(resdate,mealplan,roomtype,rev1)) as Rev  from (	
		  SELECT COUNT(GuestRoomDetail.RoomCode) AS Rooms, SUM(GuestRoomDetail.RoomRate *  dbo.GetExRate(GuestRoomDetail.ResDate,GuestRoomDetail.ResNo,'RS',GuestRoomDetail.Curr)) AS Rev1,GuestRoomDetail.resdate,GuestRoomDetail.roomtype,GuestRoomDetail.mealplan FROM   
		            GuestRoomDetail INNER JOIN GuestMaster ON GuestRoomDetail.ResNo = GuestMaster.ResNo
		            where year(GuestRoomDetail.ResDate) =year(CONVERT(DATETIME, @date, 103)) and GuestRoomDetail.Comple =0  and  GuestMaster.TourOP=@AgentCode
					group by GuestRoomDetail.resdate,GuestRoomDetail.roomtype,GuestRoomDetail.mealplan) b2
			) as B

		
		insert into @TempPro (AgentCode,AgentName,TDRooms,TDRevenue,MTDRooms,MTDRevenue,YTDRooms,YTDRevenue )
								values
							  (@AgentCode ,@AgentName,ISNULL (@TdayRooms,0),ISNULL(@TodayRev,0),ISNULL(@MTDRooms,0),ISNULL(@MTDRev,0),ISNULL(@YTDRooms,0),ISNULL(@YTDRev,0) ) 	
		
		delete from #temp where Code =@AgentCode
		select top(1) @AgentCode = Code,@AgentName=Name from #temp 
	end
COMMIT TRANSACTION

select * from @TempPro 
drop table #temp

GO

