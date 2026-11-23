/*  One user's effective role on one property.

    A property-specific row beats a global one. That ordering is the point of
    having both: a global PUBLISHER who must be VIEWER on one sensitive property
    is expressed by adding the narrower row, and it takes effect rather than
    being ignored.

    Returns no row when the user has no grant at all - the caller applies the
    configured default rather than this procedure inventing one, so the default
    is visible in configuration instead of buried in SQL.                        */
CREATE PROCEDURE dbo.LTYC_UserRole_Select
    @UserId     int,
    @PropertyId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
           r.Role,
           IsGlobal = CASE WHEN r.PropertyId IS NULL THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END
    FROM   dbo.LTYC_UserRole AS r
    WHERE  r.UserId   = @UserId
      AND  r.IsActive = 1
      AND  (r.PropertyId = @PropertyId OR r.PropertyId IS NULL)
    ORDER BY CASE WHEN r.PropertyId IS NULL THEN 1 ELSE 0 END;
END

GO

