/*  Soft delete, refused while members are still in the journey.

    Deleting under someone's feet would strand them mid-flow with no record of
    why they stopped receiving messages. Archive first - that exits everyone
    with a reason - then delete.                                                 */
CREATE PROCEDURE dbo.LTYJ_Journey_Delete
    @JourneyId  int,
    @PropertyId int,
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.LTYJ_Journey
                   WHERE JourneyId = @JourneyId AND PropertyId = @PropertyId AND IsDeleted = 0)
        THROW 50401, 'This journey no longer exists.', 1;

    DECLARE @live int = (SELECT COUNT(*) FROM dbo.LTYJ_Run
                         WHERE JourneyId = @JourneyId AND Status IN ('ACTIVE','WAITING'));

    IF (@live > 0)
        THROW 50413, 'Members are still in this journey. Archive it first.', 1;

    UPDATE dbo.LTYJ_Journey
    SET    IsDeleted = 1, Status = 'ARCHIVED',
           ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
    WHERE  JourneyId = @JourneyId;

    INSERT INTO dbo.LTYJ_AuditLog (PropertyId, EntityType, EntityId, Action, ActorUserId)
    VALUES (@PropertyId, 'JOURNEY', @JourneyId, 'DELETE', @ActionBy);

    SELECT @JourneyId AS JourneyId;
END

GO

