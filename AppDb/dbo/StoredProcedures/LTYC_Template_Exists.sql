/*  Which of these template codes can actually be sent.

    Takes the codes a journey references as a JSON array of {code, channel} pairs
    and returns a verdict for each. Channel matters: a code that exists for EMAIL
    is not a template a PUSH step can send, and the queue's own lookup matches on
    both - so a check that ignored the channel would pass a journey the dispatcher
    will still fail.

    Returns a row per INPUT pair, including the ones that matched nothing, so the
    caller can name the missing code rather than reporting a count.              */
CREATE PROCEDURE dbo.LTYC_Template_Exists
    @PropertyId int,
    @CodesJson  nvarchar(max)
AS
BEGIN
    SET NOCOUNT ON;

    IF (NULLIF(LTRIM(RTRIM(ISNULL(@CodesJson, ''))), '') IS NULL OR ISJSON(@CodesJson) = 0)
    BEGIN
        SELECT Code = CAST(NULL AS varchar(60)), Channel = CAST(NULL AS varchar(20)),
               Found = CAST(0 AS bit), IsPublished = CAST(0 AS bit)
        WHERE  1 = 0;

        RETURN;
    END

    SELECT wanted.Code,
           wanted.Channel,
           -- Found but not published is a different problem from not found at
           -- all, and needs a different message, so both are reported.
           Found       = CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.LTYC_Template t
                                                WHERE t.PropertyId = @PropertyId
                                                  AND t.Code    = wanted.Code
                                                  AND t.Channel = wanted.Channel
                                                  AND t.IsDeleted = 0)
                                   THEN 1 ELSE 0 END AS bit),
           IsPublished = CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.LTYC_Template t
                                                WHERE t.PropertyId = @PropertyId
                                                  AND t.Code    = wanted.Code
                                                  AND t.Channel = wanted.Channel
                                                  AND t.Status  = 'PUBLISHED'
                                                  AND t.IsActive = 1
                                                  AND t.IsDeleted = 0)
                                   THEN 1 ELSE 0 END AS bit)
    FROM   OPENJSON(@CodesJson)
           WITH (Code varchar(60) '$.code', Channel varchar(20) '$.channel') AS wanted
    WHERE  wanted.Code IS NOT NULL;
END

GO

