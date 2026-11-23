/*  Pause, resume or archive.

    Pausing changes nothing on the run rows. LTYJ_Run_Claim joins the journey and
    only claims runs on an ACTIVE one, so a pause takes effect on the next tick
    and a resume needs no repair pass. Wait timers keep counting through a pause -
    a three-day pause does not push everyone's day 15 to day 18.

    Archiving is different: it exits every live run, because a journey nobody can
    resume should not leave members waiting on a step that will never come.       */
CREATE PROCEDURE dbo.LTYJ_Journey_SetStatus
    @JourneyId  int,
    @PropertyId int,
    @Status     varchar(20),
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF (@Status NOT IN ('ACTIVE','PAUSED','ARCHIVED'))
            THROW 50411, 'The status must be ACTIVE, PAUSED or ARCHIVED.', 1;

        DECLARE @old varchar(20) = (SELECT Status FROM dbo.LTYJ_Journey
                                    WHERE JourneyId = @JourneyId AND PropertyId = @PropertyId AND IsDeleted = 0);

        IF (@old IS NULL)
            THROW 50401, 'This journey no longer exists.', 1;

        IF (@Status = 'ACTIVE' AND NOT EXISTS (SELECT 1 FROM dbo.LTYJ_Journey
                                               WHERE JourneyId = @JourneyId AND CurrentVersionId IS NOT NULL))
            THROW 50412, 'Publish the journey before activating it.', 1;

        UPDATE dbo.LTYJ_Journey
        SET    Status = @Status, ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
        WHERE  JourneyId = @JourneyId;

        DECLARE @exited int = 0;

        IF (@Status = 'ARCHIVED')
        BEGIN
            UPDATE dbo.LTYJ_Run
            SET    Status = 'EXITED', ExitReason = 'JOURNEY_ARCHIVED',
                   EndedAt = SYSUTCDATETIME(), NextRunAt = NULL,
                   LockedBy = NULL, LockedUntil = NULL
            WHERE  JourneyId = @JourneyId AND Status IN ('ACTIVE','WAITING');

            SET @exited = @@ROWCOUNT;
        END

        INSERT INTO dbo.LTYJ_AuditLog (PropertyId, EntityType, EntityId, Action, ActorUserId, BeforeJson, AfterJson)
        VALUES (@PropertyId, 'JOURNEY', @JourneyId,
                CASE @Status WHEN 'PAUSED' THEN 'PAUSE' WHEN 'ACTIVE' THEN 'RESUME' ELSE 'ARCHIVE' END,
                @ActionBy,
                (SELECT @old AS status FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                (SELECT @Status AS status, @exited AS runsExited FOR JSON PATH, WITHOUT_ARRAY_WRAPPER));

        COMMIT TRANSACTION;

        SELECT @JourneyId AS JourneyId, @Status AS Status, @exited AS RunsExited;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

