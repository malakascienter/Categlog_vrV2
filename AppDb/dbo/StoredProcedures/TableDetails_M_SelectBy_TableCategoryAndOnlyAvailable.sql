-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--TableDetails_M_SelectBy_TableCategory 3,2
CREATE PROCEDURE [dbo].[TableDetails_M_SelectBy_TableCategoryAndOnlyAvailable]
@TableCategoryId INT,
@resId INT,
@PropertyId INT
AS
BEGIN

   DECLARE @ResDate DATE,@TimeSlotId INT ,@Outlet varchar(3)
   SELECT @ResDate = ReservationDate,@TimeSlotId = TimeSlotID ,@Outlet = Outlet FROM Reservation WHERE ReservationNo = @resId AND PropertyId = @PropertyId 


	
   SET NOCOUNT ON;
   SELECT TL.*,TCL.TableCategoryName FROM  [dbo].[POS_TableList] TL INNER JOIN POS_TableCategories TCL ON TL.TableCategoryID = TCL.TableCategoryID
   WHERE TL.PropertyId=@PropertyId 
   AND @TableCategoryId=TL.TableCategoryID
   AND TL.MarkAsDelete=0 AND TableID NOT IN (SELECT RWT.TableID FROM Reservation R INNER JOIN ReservationWiseTable RWT ON R.ReservationNo = RWT.ReservationNo WHERE R.ReservationDate = @ResDate AND R.TimeSlotID = @TimeSlotId AND R.Outlet = @Outlet)
END

GO

