/*  Templates a journey step can choose, newest version per code.

    Reissued from 188 with one fix: it computed Status as MAX(t.Status), which is
    alphabetical. 'RETIRED' sorts above 'PUBLISHED', so a code with a retired
    version reported RETIRED and the builder would have shown a sendable template
    as unavailable. Harmless while @IncludeDraft was off, because the filter
    excluded everything but PUBLISHED — and wrong the moment it was turned on.    */
CREATE PROCEDURE dbo.LTYC_Template_SelectList
    @PropertyId   int,
    @Channel      varchar(20) = NULL,
    @IncludeDraft bit         = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT t.Code,
           t.Channel,
           Name       = MAX(CASE WHEN t.VersionNo = mx.MaxVersion THEN t.Name END),
           VersionNo  = mx.MaxVersion,
           TemplateId = MAX(CASE WHEN t.VersionNo = mx.MaxVersion THEN t.TemplateId END),
           -- PUBLISHED when any version of this code is publishable, whatever
           -- else exists alongside it. Precedence, not alphabetical order.
           Status     = CASE WHEN MAX(CASE WHEN t.Status = 'PUBLISHED' AND t.IsActive = 1 THEN 1 ELSE 0 END) = 1
                             THEN 'PUBLISHED'
                             WHEN MAX(CASE WHEN t.Status = 'DRAFT' THEN 1 ELSE 0 END) = 1
                             THEN 'DRAFT'
                             ELSE 'RETIRED' END,
           HasSubject = CAST(MAX(CASE WHEN t.VersionNo = mx.MaxVersion
                                       AND NULLIF(LTRIM(RTRIM(t.Subject)), N'') IS NOT NULL
                                      THEN 1 ELSE 0 END) AS bit)
    FROM   dbo.LTYC_Template AS t
    CROSS APPLY (SELECT MAX(t2.VersionNo) AS MaxVersion
                 FROM   dbo.LTYC_Template AS t2
                 WHERE  t2.PropertyId = t.PropertyId AND t2.Code = t.Code
                   AND  t2.Channel = t.Channel AND t2.IsDeleted = 0
                   AND  (@IncludeDraft = 1 OR t2.Status = 'PUBLISHED')) AS mx
    WHERE  t.PropertyId = @PropertyId
      AND  t.IsDeleted  = 0
      AND  t.IsActive   = 1
      AND  (@Channel IS NULL OR t.Channel = @Channel)
      AND  (@IncludeDraft = 1 OR t.Status = 'PUBLISHED')
    GROUP BY t.Code, t.Channel, mx.MaxVersion
    ORDER BY t.Channel, t.Code;
END

GO

