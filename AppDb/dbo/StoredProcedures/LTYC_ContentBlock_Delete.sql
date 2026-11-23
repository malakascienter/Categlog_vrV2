/*  Soft delete. Refused while a template's BlocksJson still names the block —
    removing it would leave a published email rendering a gap where a footer used
    to be, and nothing would report it.                                          */
CREATE PROCEDURE dbo.LTYC_ContentBlock_Delete
    @PropertyId int,
    @BlockId    int,
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Code varchar(60) =
        (SELECT Code FROM dbo.LTYC_ContentBlock
         WHERE BlockId = @BlockId AND PropertyId = @PropertyId AND IsDeleted = 0);

    IF (@Code IS NULL)
        THROW 50726, 'That block no longer exists.', 1;

    /*  A LIKE on BlocksJson rather than an OPENJSON shred: the block reference
        may sit at any depth in a composed document, and a substring match that
        occasionally over-reports is the right way round for a delete guard.      */
    IF EXISTS (SELECT 1 FROM dbo.LTYC_Template
               WHERE PropertyId = @PropertyId AND IsDeleted = 0
                 AND BlocksJson IS NOT NULL
                 AND BlocksJson LIKE '%"' + @Code + '"%')
        THROW 50727, 'Templates still use this block. Remove it from them first.', 1;

    UPDATE dbo.LTYC_ContentBlock
    SET    IsDeleted = 1, IsActive = 0, ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
    WHERE  BlockId = @BlockId;

    SELECT Deleted = @@ROWCOUNT;
END

GO

