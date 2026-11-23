/*  Every grant on a property, plus the global ones, for an administration screen. */
CREATE PROCEDURE dbo.LTYC_UserRole_SelectAll
    @PropertyId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT r.UserRoleId, r.UserId, r.PropertyId, r.Role, r.Notes, r.IsActive,
           IsGlobal = CASE WHEN r.PropertyId IS NULL THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
           r.CreatedBy, r.CreatedDate, r.ModifiedBy, r.ModifiedDate
    FROM   dbo.LTYC_UserRole AS r
    WHERE  r.PropertyId = @PropertyId OR r.PropertyId IS NULL
    ORDER BY CASE WHEN r.PropertyId IS NULL THEN 1 ELSE 0 END, r.UserId;
END

GO

