/*  Every version of one code, with how many messages each actually sent.

    The send count is what makes a retired version worth keeping: it is the record
    of what a member was told, and the reason a published version is never edited
    in place.                                                                     */
CREATE PROCEDURE dbo.LTYC_Template_Versions
    @PropertyId int,
    @Code       varchar(60),
    @Channel    varchar(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT t.TemplateId, t.VersionNo, t.Status, t.Name, t.IsActive,
           t.CreatedBy, t.CreatedDate, t.ModifiedBy, t.ModifiedDate,
           SentCount = (SELECT COUNT(*) FROM dbo.LTYC_Dispatch AS d
                        WHERE d.TemplateId = t.TemplateId AND d.Status = 'SENT')
    FROM   dbo.LTYC_Template AS t
    WHERE  t.PropertyId = @PropertyId AND t.Code = @Code AND t.IsDeleted = 0
      AND  (@Channel IS NULL OR t.Channel = @Channel)
    ORDER BY t.VersionNo DESC;
END

GO

