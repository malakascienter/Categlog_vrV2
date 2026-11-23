



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Save_SummaryDetails]
  @ShiftNo						INT,
  @OutletCode					CHAR(3),
  @OpeningBalance				DECIMAL(18,2),
  @TotCashReceipts				DECIMAL(18,2),
  @Withrawals					DECIMAL(18,2),
  @CalculatedCashAmount			DECIMAL(18,2),
  @PhysicalAmount				DECIMAL(18,2),
  @TotCashSale					DECIMAL(18,2),
  @SystemDate					DATETIME,
  @Variance						DECIMAL(18,2),
  @CashierSignOnDateTime		DATETIME,
  @CashierSignOffAuthorizedUser	VARCHAR(20),
  @PropertyId			        INT
AS
BEGIN


IF NOT EXISTS( select * from [CashierSignOffSummaryDetails] WHERE [ShiftNo] = @ShiftNo AND [OutletCode] = @OutletCode AND CONVERT(DATE,[SystemDate]) = CONVERT(DATE,@SystemDate) AND PropertyId = @PropertyId )
BEGIN

 	INSERT INTO [dbo].[CashierSignOffSummaryDetails]([ShiftNo], [OutletCode], [OpeningBalance], [TotCashReceipts], [Withrawals], [CalculatedCashAmount], [PhysicalAmount], [TotCashSale], [SystemDate],[Variance], [CashierSignOnDateTime], [CashierSignOffAuthorizedUser],PropertyId)
	VALUES(@ShiftNo, @OutletCode, @OpeningBalance, @TotCashReceipts, @Withrawals, @CalculatedCashAmount, @PhysicalAmount, @TotCashSale, @SystemDate, @Variance, @CashierSignOnDateTime, @CashierSignOffAuthorizedUser,@PropertyId)


END


END

GO

