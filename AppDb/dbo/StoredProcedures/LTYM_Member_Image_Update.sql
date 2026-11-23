
CREATE   PROCEDURE [dbo].[LTYM_Member_Image_Update]
    @MemberId   INT,
    @ImagePath  NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.LTY_Member WHERE MemberId = @MemberId AND PropertyId = @PropertyId)
        THROW 52020, 'Member not found.', 1;

    IF EXISTS (SELECT 1 FROM dbo.LTYM_MemberProfileExt WHERE MemberId = @MemberId)
        UPDATE dbo.LTYM_MemberProfileExt
        SET    ImagePath = @ImagePath,
               UpdatedAt = SYSUTCDATETIME()
        WHERE  MemberId  = @MemberId;
    ELSE
        INSERT INTO dbo.LTYM_MemberProfileExt (MemberId, ImagePath)
        VALUES (@MemberId, @ImagePath);
END

GO

