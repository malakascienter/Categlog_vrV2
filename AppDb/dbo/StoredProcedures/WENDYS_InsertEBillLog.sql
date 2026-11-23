-- =============================================
-- Author:		Ravindu
-- Create date: 2026-10-27
-- Description:	Wendy's Whatsapp log
-- =============================================
CREATE   PROCEDURE [dbo].[WENDYS_InsertEBillLog]
    @OrderNo    NVARCHAR(100) = NULL,
    @Outlet     NVARCHAR(200) = NULL,
    @ContactNo  NVARCHAR(30)  = NULL,
    @JsonData   NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[WENDYS_EBillLog] ([OrderNo], [Outlet], [ContactNo], [JsonData], [IsWhatsAppSend], [CreatedDate])
    VALUES (@OrderNo, @Outlet, @ContactNo, @JsonData, 0, GETDATE());

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END

GO

