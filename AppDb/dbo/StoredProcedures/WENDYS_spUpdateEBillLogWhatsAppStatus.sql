-- =============================================
-- Author:		Ravindu
-- Create date: 2026-10-27
-- Description:	Wendy's whatsapp send update
-- =============================================
CREATE   PROCEDURE [dbo].[WENDYS_spUpdateEBillLogWhatsAppStatus]
    @ID              INT,
    @IsWhatsAppSend  BIT,
    @MessageId       NVARCHAR(200) = NULL,
    @StatusDetail    NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[WENDYS_EBillLog]
    SET [IsWhatsAppSend] = @IsWhatsAppSend,
        [MessageId]      = @MessageId,
        [StatusDetail]   = @StatusDetail,
        [SentDate]       = CASE WHEN @IsWhatsAppSend = 1 THEN GETDATE() ELSE [SentDate] END
    WHERE [ID] = @ID;
END

GO

