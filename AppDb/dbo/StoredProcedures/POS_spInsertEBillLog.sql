
CREATE PROCEDURE [dbo].[POS_spInsertEBillLog]
    @JsonData    NVARCHAR(MAX),
    @Outlet      NVARCHAR(20),
    @PropertyID  INT,
    @ContactNo   NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[POS_EBillLog]
    (
        [JsonData],
        [Outlet],
        [PropertyID],
        [ContactNo],
        [SysDateTime],
        [IsWhatsAppSend]
    )
    VALUES
    (
        @JsonData,
        @Outlet,
        @PropertyID,
        @ContactNo,
        GETDATE(),
        0
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS [ID];
END

GO

