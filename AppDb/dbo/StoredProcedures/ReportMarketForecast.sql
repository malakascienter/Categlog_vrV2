
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReportMarketForecast] 
	(
		@tdate varchar(20),
		@mdate varchar(20)
	)
	
AS

--declare @tdate as varchar(20)
--declare @mdate as varchar(20)
--
--set @tdate = '01/03/2012'
--set @mdate = '30/03/2012'

SET              dateformat dmy

select sum(tCount) as tCount, sum(tRate1) as tRate, marketCode, market from (

SELECT     tCount, marketCode, market, dbo.GetBasisAllocation(resdate,Mealplan,roomtype,trate) as tRate1 FROM (
--SELECT     dbo.GetBasisAllocation(resdate,mealplan,roomtype,trate) as frate FROM (	
					  SELECT     SUM(ResRoomAllocation.NoOfRooms) AS tCount, SUM(dbo.GetRoomRate(ResRoomAllocation.ResNo, ResRoomAllocation.ResDate, 
                      ResMaster.TourOP, ResMaster.RateCode, ResMaster.MealPlan, ResRoomAllocation.RoomCatCode, ResRoomAllocation.RoomType)) AS tRate, 
                      ResMaster.MarketCode, RateCategory.Description AS market,ResRoomAllocation.resdate,ResMaster.MealPlan,ResRoomAllocation.RoomType
					  FROM         ResRoomAllocation INNER JOIN
                      ResMaster ON ResRoomAllocation.ResNo = ResMaster.ResNo INNER JOIN
                      RateCategory ON ResMaster.MarketCode = RateCategory.RateCode
				      WHERE (resroomallocation.resdate >= convert(datetime,@tdate,103) and resroomallocation.resdate <= convert(datetime,@mdate,103))
					  GROUP BY ResMaster.MarketCode, RateCategory.Description,ResRoomAllocation.resdate,ResMaster.MealPlan,ResRoomAllocation.RoomType

UNION ALL
					  SELECT     count(GuestRoomDetail.RoomCode) AS tCount, sum(GuestRoomDetail.RoomRate * dbo.getExrate(GuestRoomDetail.resdate, GuestRoomDetail.resno, 'RS', GuestRoomDetail.curr)) AS tRate, marketCode,RateCategory.Description AS market,
					  GuestRoomDetail.resdate,GuestRoomDetail.mealplan,GuestRoomDetail.roomtype	
					  FROM          GuestRoomDetail INNER JOIN GuestMaster ON GuestRoomDetail.ResNo = GuestMaster.ResNo INNER JOIN
				      RateCategory ON GuestMaster.MarketCode = RateCategory.RateCode
					  WHERE      (GuestRoomDetail.ResDate >= convert(datetime,@tDate,103)) and (GuestRoomDetail.ResDate <= convert(datetime,@mDate,103)) and substring(GuestRoomDetail.resno,1,1) <> 'R'
					  GROUP BY marketCode, RateCategory.Description,GuestRoomDetail.resdate,GuestRoomDetail.mealplan,GuestRoomDetail.roomtype

UNION ALL
					  SELECT     count(GuesthisRoomDetail.RoomCode) AS tCount,sum(GuesthisRoomDetail.RoomRate * dbo.getExrate(GuesthisRoomDetail.resdate, GuesthisRoomDetail.resno, 'RS', GuesthisRoomDetail.curr)) AS tRate, marketCode,RateCategory.Description AS market,
					  GuesthisRoomDetail.resdate,GuesthisRoomDetail.mealplan,GuesthisRoomDetail.roomtype
					  FROM         GuesthisRoomDetail INNER JOIN GuesthisMaster ON GuesthisRoomDetail.ResNo = GuesthisMaster.ResNo INNER JOIN
					  RateCategory ON GuesthisMaster.MarketCode = RateCategory.RateCode
					  WHERE     (GuesthisRoomDetail.ResDate >= convert(datetime,@tDate,103)) and (GuesthisRoomDetail.ResDate <= convert(datetime,@mDate,103))
					  GROUP BY marketCode, RateCategory.Description,GuesthisRoomDetail.resdate,GuesthisRoomDetail.mealplan,GuesthisRoomDetail.roomtype) AS t
) as a

group by marketCode, market




--UNION ALL
--SELECT     tCount, trate, tourop, 'MTD' AS id
--FROM         (SELECT     count(GuestRoomDetail.RoomCode) AS tCount, sum(GuestRoomDetail.RoomRate * dbo.getExrate(GuestRoomDetail.resdate, 
--                                              GuestRoomDetail.resno, 'RS', GuestRoomDetail.curr)) AS tRate, tourop
--                       FROM          GuestRoomDetail INNER JOIN
--                                              GuestMaster ON GuestRoomDetail.ResNo = GuestMaster.ResNo
--                       WHERE      (GuestRoomDetail.ResDate >= @mDate) AND (GuestRoomDetail.ResDate <= @tDate)
--                       GROUP BY tourop
--                       UNION ALL
--                       SELECT     count(GuesthisRoomDetail.RoomCode) AS tCount, sum(GuesthisRoomDetail.RoomRate * dbo.getExrate(GuesthisRoomDetail.resdate, 
--                                             GuesthisRoomDetail.resno, 'RS', GuesthisRoomDetail.curr)) AS tRate, tourop
--                       FROM         GuesthisRoomDetail INNER JOIN
--                                             GuesthisMaster ON GuesthisRoomDetail.ResNo = GuesthisMaster.ResNo
--                       WHERE     (GuesthisRoomDetail.ResDate >= @mDate) AND (GuesthisRoomDetail.ResDate <= @tDate)
--                       GROUP BY tourop) AS m
--UNION ALL
--SELECT     tCount, trate, tourop, 'YTD' AS id
--FROM         (SELECT     count(GuestRoomDetail.RoomCode) AS tCount, sum(GuestRoomDetail.RoomRate * dbo.getExrate(GuestRoomDetail.resdate, 
--                                              GuestRoomDetail.resno, 'RS', GuestRoomDetail.curr)) AS tRate, tourop
--                       FROM          GuestRoomDetail INNER JOIN
--                                              GuestMaster ON GuestRoomDetail.ResNo = GuestMaster.ResNo
--                       WHERE      (GuestRoomDetail.ResDate >= @yDate) AND (GuestRoomDetail.ResDate <= @tDate)
--                       GROUP BY tourop
--                       UNION ALL
--                       SELECT     count(GuesthisRoomDetail.RoomCode) AS tCount, sum(GuesthisRoomDetail.RoomRate * dbo.getExrate(GuesthisRoomDetail.resdate, 
--                                             GuesthisRoomDetail.resno, 'RS', GuesthisRoomDetail.curr)) AS tRate, tourop
--                       FROM         GuesthisRoomDetail INNER JOIN
--                                             GuesthisMaster ON GuesthisRoomDetail.ResNo = GuesthisMaster.ResNo
--                       WHERE     (GuesthisRoomDetail.ResDate >= @yDate) AND (GuesthisRoomDetail.ResDate <= @tDate)
--                       GROUP BY tourop) AS y

GO

