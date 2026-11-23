
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AgentwiseInHouseList] 
	(
		@pDate varchar(20),
		@Agent varchar(6)
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
 
 --set @pDate ='20/03/2012'
 
SELECT DISTINCT 
                      GuestRoomDetail.RoomCode, GuestRoomDetail.ResNo, GuestRoomDetail.MealPlan, 
                      CASE WHEN GuestRoomDetail.RoomType = 0 THEN 'Single' WHEN GuestRoomDetail.RoomType = 1 THEN 'Double' WHEN GuestRoomDetail.RoomType = 3 THEN 'Triple'
                       END AS Expr1, CASE WHEN GuestRoomDetail.FreeOffer = 0 AND GuestRoomDetail.Comple = 1 THEN 'Complimentory' ELSE '' END AS Status, 
                      AgentRef.Name AS AGENT, CountryRef.Name AS Country, RateCategory.Description AS Market, RoomCatRef.Description AS RoomCategory, 
                      ResDetail.Title + ' ' + ResDetail.FirstName + ' ' + ResDetail.LastName AS Guest, ResDetail.ResFrom, ResDetail.ResTo + 1 AS resto
FROM         AgentRef INNER JOIN
                      CountryRef INNER JOIN
                      GuestRoomDetail INNER JOIN
                      GuestMaster ON GuestRoomDetail.ResNo = GuestMaster.ResNo ON CountryRef.Code = GuestMaster.Country ON AgentRef.Code = GuestMaster.TourOP INNER JOIN
                      RateCategory ON GuestMaster.MarketCode = RateCategory.RateCode INNER JOIN
                      RoomRef ON GuestRoomDetail.RoomCode = RoomRef.RoomCode AND GuestRoomDetail.ResNo = GuestMaster.ResNo INNER JOIN
                      RoomCatRef ON RoomRef.RoomCat = RoomCatRef.Code INNER JOIN
                      ResDetail ON GuestMaster.ResNo = ResDetail.ResNo AND GuestRoomDetail.RoomCode = ResDetail.RoomCode
                      where  SUBSTRING(GuestMaster.ResNo,1,1) <>'R' and GuestRoomDetail.ResDate = CONVERT(datetime,@pDate,103)
                      and GuestMaster.TourOP = case when @Agent ='' then GuestMaster.TourOP else @Agent end
Union All
SELECT DISTINCT 
                      GuestHisRoomDetail.RoomCode, GuestHisRoomDetail.ResNo, GuestHisRoomDetail.MealPlan, 
                      CASE WHEN GuestHisRoomDetail.RoomType = 0 THEN 'Single' WHEN GuestHisRoomDetail.RoomType = 1 THEN 'Double' WHEN GuestHisRoomDetail.RoomType = 3
                       THEN 'Triple' END AS Expr1, CASE WHEN GuestHisRoomDetail.FreeOffer = 0 AND GuestHisRoomDetail.Comple = 1 THEN 'Complimentory' ELSE '' END AS status, 
                      AgentRef.Name AS AGENT, CountryRef.Name AS Country, RateCategory.Description AS Market, RoomCatRef.Description AS RoomCategory, 
                      GuestHistDetail.Title + ' ' + GuestHistDetail.FirstName + ' ' + GuestHistDetail.LastName AS Guest, GuestHistDetail.ResFrom, GuestHistDetail.ResTo + 1 AS resto
FROM         AgentRef INNER JOIN
                      CountryRef INNER JOIN
                      GuestHisRoomDetail INNER JOIN
                      GuestHisMaster ON GuestHisRoomDetail.ResNo = GuestHisMaster.ResNo ON CountryRef.Code = GuestHisMaster.Country ON 
                      AgentRef.Code = GuestHisMaster.TourOP INNER JOIN
                      RateCategory ON GuestHisMaster.MarketCode = RateCategory.RateCode INNER JOIN
                      RoomRef ON GuestHisRoomDetail.RoomCode = RoomRef.RoomCode INNER JOIN
                      RoomCatRef ON RoomRef.RoomCat = RoomCatRef.Code INNER JOIN
                      GuestHistDetail ON RoomRef.RoomCode = GuestHistDetail.RoomCode AND GuestHisMaster.ResNo = GuestHistDetail.ResNo AND 
                      GuestHisRoomDetail.RoomCode = GuestHistDetail.RoomCode
                      where  SUBSTRING(GuestHisMaster.ResNo,1,1) <>'R' and GuestHisRoomDetail.ResDate = CONVERT(datetime,@pDate,103) 
                      and GuestHisMaster.TourOP = case when @Agent ='' then GuestHisMaster.TourOP else @Agent end                  
                      
END

GO

