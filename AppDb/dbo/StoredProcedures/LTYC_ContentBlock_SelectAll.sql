/*  Reusable content blocks — a header, a footer, a voucher panel.

    Referenced from a template's BlocksJson. The composer itself is Phase 2; this
    is the store it will read, and it is useful now because a footer with the
    unsubscribe link belongs in one place rather than pasted into every email.    */
CREATE PROCEDURE dbo.LTYC_ContentBlock_SelectAll
    @PropertyId int,
    @IsActive   bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT b.BlockId, b.Code, b.Name, b.BlockType, b.BodyHtml, b.ParamsSchemaJson,
           b.IsActive, b.CreatedBy, b.CreatedDate, b.ModifiedBy, b.ModifiedDate
    FROM   dbo.LTYC_ContentBlock AS b
    WHERE  b.PropertyId = @PropertyId AND b.IsDeleted = 0
      AND  (@IsActive IS NULL OR b.IsActive = @IsActive)
    ORDER BY b.BlockType, b.Code;
END

GO

