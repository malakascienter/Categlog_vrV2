
CREATE PROCEDURE dbo.MaaluStoreStatus_M_Save
    @PropertyId            int,
    @OutletCode            varchar(5),
    @Status                varchar(20),
    @OfflineReason         varchar(255) = NULL,
    @PausedUntil           datetime     = NULL,
    @Reason                varchar(255) = NULL,
    @UpdatedBy             varchar(100) = NULL,
    @PreservePauseDetails  bit          = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StoreId varchar(200);

    SELECT TOP (1) @StoreId = Maalu_StoreId
    FROM dbo.Location_Ref
    WHERE code = @OutletCode AND PropertyId = @PropertyId;

    UPDATE dbo.POS_MaaluStoreStatus
       SET Maalu_StoreId = @StoreId,
           Status        = @Status,
           OfflineReason = @OfflineReason,
           PausedUntil   = CASE WHEN @PreservePauseDetails = 0 THEN @PausedUntil
                                WHEN @Status = 'PAUSED'        THEN PausedUntil
                                ELSE NULL END,
           Reason        = CASE WHEN @PreservePauseDetails = 0 THEN @Reason
                                WHEN @Status = 'PAUSED'        THEN Reason
                                ELSE NULL END,
           LastSyncedOn  = GETDATE(),
           UpdatedBy     = @UpdatedBy,
           UpdatedOn     = GETDATE()
     WHERE PropertyId = @PropertyId
       AND OutletCode = @OutletCode;

    IF @@ROWCOUNT = 0
        INSERT INTO dbo.POS_MaaluStoreStatus
            (PropertyId, OutletCode, Maalu_StoreId, Status, OfflineReason,
             PausedUntil, Reason, LastSyncedOn, UpdatedBy, UpdatedOn)
        VALUES
            (@PropertyId, @OutletCode, @StoreId, @Status, @OfflineReason,
             @PausedUntil, @Reason, GETDATE(), @UpdatedBy, GETDATE());
END

GO

