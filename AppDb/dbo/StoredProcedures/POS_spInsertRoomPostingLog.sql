CREATE PROCEDURE [dbo].[POS_spInsertRoomPostingLog]
@UserId varchar(20),
@WaiterCode varchar(20),
@POSNo varchar(5),
@ComputerName varchar(100),
@OrderNo varchar(10),
@Outlet varchar(3),
@PropertyId int,
@PostingUserId int,
@RoomPostingDocNo varchar(10),
@JsonText text

AS
DECLARE @OrderDate datetime
SET @OrderDate = (SELECT CurrentDate FROM Companies WHERE CompanyID = @PropertyId)

INSERT INTO POS_RoomPostingLog
(UserId, WaiterCode, POSNo, ComputerName, OrderNo, OrderDate, Outlet, PropertyId, PostingUserId, JsonText, RoomPostingDocNo, sysDate)
VALUES
(@UserId,@WaiterCode,@POSNo,@ComputerName,@OrderNo,@OrderDate,@Outlet,@PropertyId,@PostingUserId,@JsonText,@RoomPostingDocNo,GETDATE())

GO

