
create PROCEDURE [dbo].[POS_spUpdateEBillLogWhatsAppStatus]
    @ID             INT,
    @IsSuccess      BIT,
    @FailMessage    NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[POS_EBillLog]
    SET
        [IsWhatsAppSend]  = CASE WHEN @IsSuccess = 1 THEN 1 ELSE [IsWhatsAppSend] END,
        [IsWhatsappFail]  = CASE WHEN @IsSuccess = 1 THEN 0 ELSE 1 END,
        [FailMessage]     = CASE WHEN @IsSuccess = 1 THEN NULL ELSE @FailMessage END
    WHERE [ID] = @ID;
END

GO

