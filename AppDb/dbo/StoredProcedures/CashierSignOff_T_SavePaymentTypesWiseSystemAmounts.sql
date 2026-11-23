
CREATE PROCEDURE [dbo].[CashierSignOff_T_SavePaymentTypesWiseSystemAmounts] 
	@ShiftDate					DATETIME,
	@ShiftId					INT,
	@Outlet						VARCHAR(10),
	@PaymentTypeWiseAmountsJson	VARCHAR(MAX),
    @PropertyId			        INT
AS
BEGIN
	
	
	IF NOT EXISTS( select * from CashierSignOffPaymentTypesWiseSystemAmounts WHERE CONVERT(DATE,[ShiftDate]) = CONVERT(DATE,@ShiftDate) AND [ShiftId] =@ShiftId AND  [Outlet] = @Outlet AND PropertyId = @PropertyId )
	BEGIN

			INSERT INTO CashierSignOffPaymentTypesWiseSystemAmounts([PayCode], [SystemAmount], [ShiftId], [ShiftDate], [Outlet],PropertyId)
				SELECT PayCode, Total, @ShiftId, @ShiftDate, @Outlet,@PropertyId
				FROM OPENJSON(@PaymentTypeWiseAmountsJson)
				WITH
				(
					PayCode		VARCHAR(10)	'$.PayCode',
					Total		DECIMAL		'$.Total'
				) 

	END

END

GO

