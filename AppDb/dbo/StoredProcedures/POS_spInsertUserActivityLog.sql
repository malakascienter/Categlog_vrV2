



CREATE PROCEDURE [dbo].[POS_spInsertUserActivityLog]
@UserId varchar(20),
@WaiterCode varchar(20),
@Outlet varchar(3),
@TempOrderNo varchar(10),
@POSNo varchar(5),
@ComputerName varchar(15),
@AccessCode varchar(100),
@Remark varchar(250),
@ProductVersion varchar(50),
@CurrDate  DATETIME,
@PropertyId INT

AS



INSERT INTO [PB_UserActivityLog]
(UserId, WaiterCode, Outlet, OrderNo, TempOrderNo, OrderDate, POSNo, ComputerName, AccessCode, Remark, SysDate, ProductVersion,PropertyId)
VALUES
(@UserId, @WaiterCode, @Outlet, @TempOrderNo, @TempOrderNo, @CurrDate, @POSNo, @ComputerName, @AccessCode, @Remark, GETDATE(), @ProductVersion,@PropertyId)

GO

