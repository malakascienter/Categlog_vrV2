-- =============================================
-- Author:		Ravindu
-- Create date: 2026-07-13
-- Description:	Update SMS Status
-- =============================================
CREATE   PROCEDURE [dbo].[KIOSK_spUpdateEBillLogSmsStatus]
    @ID INT,
    @IsSMSSend BIT,
    @StatusDetail NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE KIOSK_SmsLog   
    SET IsSMSSend = @IsSMSSend
    WHERE ID = @ID;
END

GO

