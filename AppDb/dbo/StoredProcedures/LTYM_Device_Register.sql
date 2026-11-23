/*  Register this member's device for push.

    @MemberId comes from the caller's JWT, never from the request body - the
    member portal's controllers pass CurrentMemberId. A body-supplied member id
    would let anyone redirect another member's notifications to their own device.
    That property is enforced by the API, but it is worth stating here because it
    is the whole security story of this procedure.                               */
CREATE PROCEDURE dbo.LTYM_Device_Register
    @MemberId   int,
    @Platform   varchar(10),
    @Token      nvarchar(500),
    @AuthSecret nvarchar(200) = NULL,
    @P256dhKey  nvarchar(200) = NULL,
    @DeviceName nvarchar(150) = NULL,
    @AppVersion varchar(30)   = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PropertyId int = (SELECT PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);

    IF (@PropertyId IS NULL)
        THROW 52410, 'That member does not exist.', 1;

    EXEC dbo.LTYC_DeviceToken_Register
         @MemberId   = @MemberId,
         @PropertyId = @PropertyId,
         @Platform   = @Platform,
         @Token      = @Token,
         @AuthSecret = @AuthSecret,
         @P256dhKey  = @P256dhKey,
         @DeviceName = @DeviceName,
         @AppVersion = @AppVersion;
END

GO

