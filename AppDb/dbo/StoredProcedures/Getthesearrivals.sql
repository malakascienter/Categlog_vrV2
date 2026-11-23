

--USE hotelresweb 
-- [dbo].[Getthesearrivals] '2022-05-31','2022-05-31',20,'Arrived'
create PROCEDURE [dbo].[Getthesearrivals] (
@FromDate DATE, 
@ToDate   DATE,
@PropertyId INT
--@Company int = 0, 
--@Guest int = 0, 
--@GroupReservationNo varchar(50) = '-',
--@ResStaus varchar(50) = '-' --(Expected or Inhoused)
,
@Type varchar(10)
) 
AS 

DECLARE @Company int = 0
DECLARE @AccommodationChargeCodeId int = 0
DECLARE @Guest int = 0
DECLARE @GroupReservationNo varchar(50) = '-'
DECLARE @ResStaus varchar(50) = '-' --(Expected or Inhoused)

select  @AccommodationChargeCodeId = AccommodationChargeCodeId from FOSettings where PropertyId =@PropertyId

DECLARE @DEFAULTARRIVALTIME DATETIME

SELECT @DEFAULTARRIVALTIME=DefaultArrivalTime FROM BookingSettings WHERE PropertyId=@PropertyId


select  H.Id, H.GroupReservationNo, H.ReservationNo, H.Arrival, H.Departure, H.AgentId, H.MealPlanId, H.BookingRemark, H.CountryID, H.SegmentId, 
H.MarketId, h.RateCodeHeaderId, H.NoOfAdults , H.NoOfKids , H.ExpectedArrivalTime, h.ResStatus  , PackageHeaderId, ArrivalTxnDateTime
into #tempResHeader 
from (
	select Id , GroupReservationNo, ReservationNo, Arrival, Departure, AgentId, MealPlanId, BookingRemark, CountryID, SegmentId, MarketId,  
	RateCodeHeaderId,  NoOfAdults , NoOfKids , ExpectedArrivalTime,StatusId, 'Expected' ResStatus    , PackageHeaderId, ArrivalTxnDateTime
	from ReservationHeaders
	where PropertyId=@PropertyId
	and Arrival between @FromDate and @ToDate
	union all
	select  Id , GroupReservationNo,ReservationNo, Arrival, Departure, AgentId, MealPlanId, BookingRemark, CountryID, SegmentId, MarketId,
	RateCodeHeaderId, NoOfAdults , NoOfKids , ExpectedArrivalTime,StatusId , 'Inhoused' ResStatus , PackageHeaderId, ArrivalTxnDateTime
	from InhouseReservationHeaders 
	where PropertyId=@PropertyId
	and Arrival between @FromDate and @ToDate
	union all
	select Id , GroupReservationNo,ReservationNo, Arrival, Departure, AgentId, MealPlanId, BookingRemark, CountryID, SegmentId, MarketId, 
	RateCodeHeaderId, NoOfAdults , NoOfKids , ExpectedArrivalTime,StatusId, 'Checked Out' ResStatus , PackageHeaderId, ArrivalTxnDateTime
	from CheckedOutReservationHeaders 
	where PropertyId=@PropertyId
	and Arrival between @FromDate and @ToDate
)  H 
inner join ReservationStatus  RS on h.statusid = rs.Id 

--and rs.isapplicabletooccupancy = 1 
and rs.id IN (select Id from ReservationStatus where IsApplicableToOccupancy = 1 and IsActive = 1)
--and (@Type = 'All'  or ResStatus = @Type)

IF @Type = 'Expected'
BEGIN
	delete from #tempResHeader where ResStatus IN ('Inhoused','Checked Out')
END

IF @Type = 'Inhoused'
BEGIN
	delete from #tempResHeader where ResStatus IN ('Expected')
END

IF @Type = 'Checked Out'
BEGIN
	delete from #tempResHeader where ResStatus IN ('Expected','Inhoused')
END

--select * from #tempResHeader

select count(*) NoOfRoomsSum ,sum(NoOfAdults) NoOfAdultsSum , sum(NoOfKids) NoOfKidsSum  
into #tempResHeaderSum 
from #tempResHeader
select ReservationHeaderId,  SL.NAME + ' ' + GP.firstname + ' ' + GP.lastname AS GuestName,GuestProfileTypeId into #tempGP  from (
	select ReservationHeaderId, GuestProfileId,GuestProfileTypeId  from ReservationProfiles 
	where PropertyId=@PropertyId
	union all
	select ReservationHeaderId, GuestProfileId,GuestProfileTypeId from InHouseReservationProfiles
	where PropertyId=@PropertyId
	union all
select ReservationHeaderId, GuestProfileId,GuestProfileTypeId from CheckedOutReservationProfiles
where PropertyId=@PropertyId
) RGP 
inner join GuestProfiles GP on rgp.GuestProfileId = gp.Id 
INNEr join Salutations SL on gp.SalutationId = SL.Id 
inner join GuestProfileTypes gpt on gpt.id=rgp.GuestProfileTypeId
where gpt.IsMainGuest =1

--select * from #tempResHeaderSum


select t1.Id , t1.GroupReservationNo, t1.ReservationNo, t1.Arrival, t1.Departure, t1.AgentId, t1.MealPlanId, gp.GuestName ,
t1.BookingRemark, t1.CountryID,
t1.SegmentId, t1.MarketId, t1.RateCodeHeaderId,t1.NoOfAdults , t1.NoOfKids , 
t1.ExpectedArrivalTime,t1.ResStatus ,t2.NoOfAdultsSum ,
t2.NoOfKidsSum,t2.NoOfRoomsSum , PackageHeaderId, ArrivalTxnDateTime
into #t3
from #tempResHeader t1 inner join #tempGP gp on t1.id =  gp.ReservationHeaderId  
cross join #tempResHeaderSum t2

--select * from #t3

select RD1.RoomCategoryId, MealPlanId, RD1.RoomTypeId,reservationdate,ReservationHeaderId , rom.Name,CurrencyCode,RoomRate 
into #tempRoomDetails 
from (
	select RD.RoomCategoryId, rd.MealPlanId, rd.RoomTypeId,rd.ReservationHeaderId, rd.RoomId,CurrencyCode,RoomRate,rd.reservationdate 
	from (
		select RoomCategoryId, B.MealPlanId, RoomTypeId, reservationdate,ReservationHeaderId , RoomId,CurrencyCode,(case when IsComplimentary=1 then 0 else RoomRate end) as RoomRate 
		from ReservationDetails A
		inner join #tempResHeader B ON A.ReservationHeaderId = B.Id
		union all
		select RoomCategoryId, A.MealPlanId, RoomTypeId,reservationdate,ReservationHeaderId , RoomId,CurrencyCode,(case when IsComplimentary=1 then 0 else RoomRate end) as RoomRate 
		from InHouseReservationDetails A
		inner join #tempResHeader B ON A.ReservationHeaderId = B.Id
		union all
		select RoomCategoryId, A.MealPlanId, RoomTypeId,reservationdate,ReservationHeaderId , RoomId,CurrencyCode,(case when IsComplimentary=1 then 0 else RoomRate end) as RoomRate
		from CheckedOutReservationDetails A
		inner join #tempResHeader B ON A.ReservationHeaderId = B.Id
	) RD
	group by RoomCategoryId, MealPlanId, RoomTypeId,reservationdate,ReservationHeaderId,RoomId,CurrencyCode,RoomRate 
) RD1 
left join RoomDetails ROM on rd1.roomid = rom.Id 


--select * from #tempRoomDetails


select 
t3.GroupReservationNo,
t3.ReservationNo, 
t3.Arrival, 
t3.Departure, 
cm.Name  AS Company ,
mp.Prefix AS MealPlan ,
t3.GuestName  ,
t3.BookingRemark, 
ct.Name AS Country ,
sg.Name AS Segment,
mk.Name AS Market,
rch.Name AS RATECODE,
trd.Name  AS ROOM,
t3.NoOfAdults , 
t3.NoOfKids , 
(CASE WHEN CONVERT(NVARCHAR(10),ISNULL(t3.ExpectedArrivalTime,@DEFAULTARRIVALTIME),108) = '00:00:00' THEN  CONVERT(NVARCHAR(10),@DEFAULTARRIVALTIME,108) ELSE CONVERT(NVARCHAR(10),t3.ExpectedArrivalTime,108) END) AS ExpectedArrivalTime,
ISNULL(CONVERT(NVARCHAR(10),ArrivalTxnDateTime,108),'-') As ArrivalTxnDateTime,
t3.ResStatus ,
t3.NoOfAdultsSum ,
t3.NoOfKidsSum,
t3.NoOfRoomsSum, 
(
		SELECt TOp 1  RoomRate 
		FROM RoomRates RR 
		WHERE RR.RateCodeHeaderId = t3.RateCodeHeaderId 
		AND RR.RoomCategoryId =  trd.RoomCategoryId
		AND RR.MealPlanId = trd.MealPlanId 
		AND RR.RoomTypeId = trd.RoomTypeId  
		AND ReservationDate = trd.ReservationDate
		AND RR.PackageHeaderId = t3.PackageHeaderId
		AND RR.PropertyId=@PropertyId

) AS 'ContractedRate',
(
	select top 1 (B.ChargeAmount + C.Amount )
	from FolioHeaderHistory A
	INNER JOIN FolioDetailsHistory B ON A.FolioHeaderID = B.FolioHeaderID
	INNER JOIN FoliowiseTaxDetailsHistory C ON C.FolioDetailID = B.FolioDetailID
	WHERE B.ChargeDate = t3.Arrival 
	AND A.ReservationHeaderID = t3.Id
	AND B.ChargeCodeID = @AccommodationChargeCodeId
	AND A.PropertyID=@PropertyId
	UNION
	select top 1 (B.ChargeAmount + C.Amount) 
	from FolioHeader A
	INNER JOIN FolioDetails B ON A.FolioHeaderID = B.FolioHeaderID
	INNER JOIN FoliowiseTaxDetails C ON C.FolioDetailID = B.FolioDetailID
	WHERE B.ChargeDate = t3.Arrival 
	AND A.ReservationHeaderID = t3.Id
	AND B.ChargeCodeID = @AccommodationChargeCodeId
	AND A.PropertyID=@PropertyId
) AS 'RoomRate',
C.ISOCode AS 'Currency'
from  #t3 t3
inner join Companies CM ON t3.AgentId = cm.Id 
inner join Countries CT on t3.CountryID = ct.id 
inner join Segments SG on t3.SegmentId =sg.id 
inner join Markets MK on t3.MarketId = mk.Id 
inner join RateCodeHeaders rch on t3.RateCodeHeaderId = rch.Id 
inner join #tempRoomDetails trd on t3.id = trd.ReservationHeaderId 
inner join MealPlans MP on trd.MealPlanId = mp.Id 
inner join Currencies C ON C.Id = rch.CurrencyId
where (t3.Arrival between @FromDate and @ToDate)
and trd.ReservationDate=t3.arrival
order by t3.ReservationNo

GO

