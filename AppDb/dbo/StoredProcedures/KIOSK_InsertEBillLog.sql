-- =============================================
-- Author:		Ravindu
-- Create date: 2026-07-10
-- Description:	Insert Kiosk EBill SMS log
-- =============================================
CREATE   PROCEDURE [KIOSK_InsertEBillLog]
(
  @OrderNo VARCHAR(MAX),
  @Outlet  VARCHAR(MAX),
  @JsonData NVARCHAR(MAX)
)
AS
BEGIN
	
	INSERT INTO KIOSK_SmsLog (OrderNo,Outlet,JsonData,SystemDate,IsSMSSend)
	VALUES (@OrderNo,@Outlet,@JsonData,GETDATE(),0)

	SELECT CAST(SCOPE_IDENTITY() AS INT) AS [ID];
END

GO

