
CREATE PROCEDURE [dbo].[POS_spInsertCustomMessageLog]
    @ContactNumber NVARCHAR(20),
    @Message       NVARCHAR(MAX),
    @Type          NVARCHAR(20),
    @Outlet        NVARCHAR(20),
    @PropertyID    INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[POS_CustomMessageLog]
    (
        [ContactNumber],
        [Message],
        [Type],
        [Outlet],
        [PropertyID],
        [SysDateTime],
        [IsSent]
    )
    VALUES
    (
        @ContactNumber,
        @Message,
        @Type,
        @Outlet,
        @PropertyID,
        GETDATE(),
        0
    );
        SELECT CAST(SCOPE_IDENTITY() AS INT) AS [ID];
END

GO

