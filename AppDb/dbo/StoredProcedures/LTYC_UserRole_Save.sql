/*  Grant or change a role.

    Refuses to remove the last ADMIN on a property. Without that check the first
    administrator can demote themselves and leave nobody able to grant the role
    back - recoverable only by editing the table directly, which is exactly the
    thing this table exists to avoid.                                            */
CREATE PROCEDURE dbo.LTYC_UserRole_Save
    @UserRoleId int          = 0,
    @UserId     int,
    @PropertyId int          = NULL,
    @Role       varchar(20),
    @Notes      nvarchar(300) = NULL,
    @IsActive   bit          = 1,
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF (@Role NOT IN ('VIEWER','AUTHOR','PUBLISHER','ADMIN'))
        THROW 50420, 'Role must be VIEWER, AUTHOR, PUBLISHER or ADMIN.', 1;

    -- What this row grants today, so the last-admin check knows what is changing.
    DECLARE @OldRole varchar(20), @OldActive bit, @OldProperty int, @OldUser int;

    IF (@UserRoleId > 0)
        SELECT @OldRole = Role, @OldActive = IsActive, @OldProperty = PropertyId, @OldUser = UserId
        FROM   dbo.LTYC_UserRole WHERE UserRoleId = @UserRoleId;

    IF (@OldRole = 'ADMIN' AND (@Role <> 'ADMIN' OR @IsActive = 0))
    BEGIN
        DECLARE @RemainingAdmins int =
        (
            SELECT COUNT(*)
            FROM   dbo.LTYC_UserRole
            WHERE  Role = 'ADMIN' AND IsActive = 1
              AND  UserRoleId <> @UserRoleId
              AND  (PropertyId = @OldProperty OR (PropertyId IS NULL AND @OldProperty IS NULL))
        );

        IF (@RemainingAdmins = 0)
            THROW 50421, 'This is the last administrator. Grant the role to someone else first.', 1;
    END

    IF (@UserRoleId > 0)
    BEGIN
        UPDATE dbo.LTYC_UserRole
        SET    UserId = @UserId, PropertyId = @PropertyId, Role = @Role, Notes = @Notes,
               IsActive = @IsActive, ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
        WHERE  UserRoleId = @UserRoleId;
    END
    ELSE
    BEGIN
        /*  Matched on user and property rather than blindly inserted: the unique
            indexes would reject a duplicate anyway, and a caller re-granting an
            existing role means "make it so", not "fail".                        */
        IF EXISTS (SELECT 1 FROM dbo.LTYC_UserRole
                   WHERE UserId = @UserId
                     AND (PropertyId = @PropertyId OR (PropertyId IS NULL AND @PropertyId IS NULL)))
        BEGIN
            UPDATE dbo.LTYC_UserRole
            SET    Role = @Role, Notes = @Notes, IsActive = @IsActive,
                   ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
            WHERE  UserId = @UserId
              AND  (PropertyId = @PropertyId OR (PropertyId IS NULL AND @PropertyId IS NULL));

            SET @UserRoleId = (SELECT UserRoleId FROM dbo.LTYC_UserRole
                               WHERE UserId = @UserId
                                 AND (PropertyId = @PropertyId OR (PropertyId IS NULL AND @PropertyId IS NULL)));
        END
        ELSE
        BEGIN
            INSERT INTO dbo.LTYC_UserRole (UserId, PropertyId, Role, Notes, IsActive, CreatedBy)
            VALUES (@UserId, @PropertyId, @Role, @Notes, @IsActive, @ActionBy);

            SET @UserRoleId = SCOPE_IDENTITY();
        END
    END

    SELECT UserRoleId = @UserRoleId;
END

GO

