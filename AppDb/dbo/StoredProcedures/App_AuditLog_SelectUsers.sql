
CREATE PROCEDURE dbo.App_AuditLog_SelectUsers
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT   h.UserId, MAX(h.Username) AS Username
    FROM     dbo.App_AuditLog h
    WHERE    h.PropertyId = @PropertyId
    GROUP BY h.UserId
    ORDER BY MAX(h.Username);
END

GO

