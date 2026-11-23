
CREATE PROCEDURE dbo.CSOX_Outlets_Select
    @PropertyId INT,
    @UserId     INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Users WHERE Id = @UserId AND IsGroupUser = 1)
       OR EXISTS (SELECT 1 FROM dbo.Companies
                   WHERE CompanyID = @PropertyId AND EnableAllOutletAccessToUser = 1)
    BEGIN
        SELECT   lr.code        AS Code,
                 lr.description AS Description,
                 lr.CurrentDate AS BusinessDate
        FROM     dbo.Location_Ref lr
        WHERE    lr.PropertyId = @PropertyId
          AND    lr.Active = 1
        ORDER BY lr.description;
    END
    ELSE
    BEGIN
        SELECT   lr.code        AS Code,
                 lr.description AS Description,
                 lr.CurrentDate AS BusinessDate
        FROM     dbo.Location_Ref lr
        INNER JOIN dbo.UserWiseOutlet uwo
                ON uwo.OutletCode = lr.code
               AND uwo.PropertyId = lr.PropertyId
        WHERE    uwo.UserId = @UserId
          AND    lr.Active = 1
          AND    lr.PropertyId = @PropertyId
        ORDER BY lr.description;
    END
END

GO

