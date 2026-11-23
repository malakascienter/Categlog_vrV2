
CREATE PROCEDURE dbo.App_AuditLog_Select
    @PropertyId INT,
    @EntityName VARCHAR(100)  = NULL,
    @RecordId   VARCHAR(50)   = NULL,
    @UserId     INT           = NULL,
    @FromDate   DATE          = NULL,
    @ToDate     DATE          = NULL,
    @SearchText NVARCHAR(200) = NULL,
    @PageNo     INT           = 1,
    @PageSize   INT           = 25
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNo   IS NULL OR @PageNo   < 1 SET @PageNo   = 1;
    IF @PageSize IS NULL OR @PageSize < 1 SET @PageSize = 25;

    -- Guard rail only. This is a page size, not a cap on what is retrievable -
    -- every row remains reachable by paging.
    IF @PageSize > 500 SET @PageSize = 500;

    IF @SearchText IS NOT NULL AND LTRIM(RTRIM(@SearchText)) = '' SET @SearchText = NULL;
    IF @EntityName IS NOT NULL AND LTRIM(RTRIM(@EntityName)) = '' SET @EntityName = NULL;
    IF @RecordId   IS NOT NULL AND LTRIM(RTRIM(@RecordId))   = '' SET @RecordId   = NULL;
    IF @UserId = 0 OR @UserId = -1 SET @UserId = NULL;

    ;WITH Filtered AS
    (
        SELECT h.*
        FROM   dbo.App_AuditLog h
        WHERE  h.PropertyId = @PropertyId
          AND (@EntityName IS NULL OR h.EntityName = @EntityName)
          AND (@RecordId   IS NULL OR h.RecordId   = @RecordId)
          AND (@UserId     IS NULL OR h.UserId     = @UserId)
          AND (@FromDate   IS NULL OR h.LoggedAt  >= CAST(@FromDate AS DATETIME2(0)))
          -- exclusive upper bound so the whole of @ToDate is included
          AND (@ToDate     IS NULL OR h.LoggedAt   < DATEADD(DAY, 1, CAST(@ToDate AS DATETIME2(0))))
          AND (@SearchText IS NULL
               OR h.Username    LIKE '%' + @SearchText + '%'
               OR h.RecordLabel LIKE '%' + @SearchText + '%'
               OR h.EntityName  LIKE '%' + @SearchText + '%'
               OR EXISTS (SELECT 1 FROM dbo.App_AuditLogDetail d
                          WHERE d.AuditLogId = h.Id
                            AND (d.FieldName LIKE '%' + @SearchText + '%'
                              OR d.OldValue  LIKE '%' + @SearchText + '%'
                              OR d.NewValue  LIKE '%' + @SearchText + '%')))
    )
    SELECT  f.Id,
            f.EntityName,
            f.RecordId,
            f.RecordLabel,
            f.Action,
            CASE f.Action WHEN 'I' THEN 'Created'
                          WHEN 'U' THEN 'Modified'
                          WHEN 'D' THEN 'Deleted'
                          ELSE f.Action END        AS ActionDescription,
            f.UserId,
            f.Username,
            f.LoggedAt,
            f.LoggedAtUtc,
            f.SourceScreen,
            (
                SELECT d.FieldName AS ColumnName,
                       d.OldValue  AS PreviousValue,
                       d.NewValue  AS NewValue
                FROM   dbo.App_AuditLogDetail d
                WHERE  d.AuditLogId = f.Id
                ORDER  BY d.Id
                FOR JSON PATH
            )                                       AS Changes,
            COUNT(*) OVER ()                        AS TotalRows
    FROM    Filtered f
    ORDER   BY f.Id DESC
    OFFSET  (@PageNo - 1) * @PageSize ROWS
    FETCH   NEXT @PageSize ROWS ONLY;
END

GO

