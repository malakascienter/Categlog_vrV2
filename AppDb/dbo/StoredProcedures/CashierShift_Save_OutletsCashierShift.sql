
-- =============================================
-- Author:		Chamathka Sooriyapala
-- Create date: 2021-07-15
-- Description:	Save Outlet Cashier shift
-- =============================================
CREATE PROCEDURE [dbo].[CashierShift_Save_OutletsCashierShift] 
	@ShiftNo				INT,            
	@ShiftDate				DATETIME,      
	@WaiterCode				VARCHAR(10),
	@IsSignOff				BIT, 
	@CashFloat				DECIMAL(18,2),  
	@SignOffDate			DATETIME,
	@StationID				VARCHAR(200),      
	@Outlet					VARCHAR(20),      
	@IsManagedSignOff		BIT,
	@SignOnDate				DATETIME,
	@SignOffAuthorizedUser	VARCHAR(100),
    @PropertyId			        INT
AS
BEGIN
	
	
IF not exists( select * from [POS_CashierShift] where [ShiftNo] = @ShiftNo and convert(date,[ShiftDate]) = convert(date,@ShiftDate) and  [WaiterCode] = @WaiterCode and [Outlet] = @Outlet and [StationID] = @StationID AND PropertyId = @PropertyId)
BEGIN

	INSERT INTO [dbo].[POS_CashierShift]([ShiftNo], [ShiftDate], [WaiterCode], [IsSignOff], [CashFloat], [SignOffDate], [StationID], [Outlet], [IsManagerSignOff], [SignOnDate], [SignOnAuthorizedUser],PropertyId)
	VALUES(@ShiftNo, @ShiftDate, @WaiterCode, @IsSignOff, @CashFloat, @SignOffDate, @StationID, @Outlet, @IsManagedSignOff, @SignOnDate, @SignOffAuthorizedUser,@PropertyId) 

END


END

GO

