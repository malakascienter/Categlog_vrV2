
CREATE PROCEDURE dbo.DayEnd_InsertDayEndAuthorizationLog
    @PropertyId         INT            = NULL,
    @HotelDate          DATE           = NULL,
    @Outlet             VARCHAR(10)    = NULL,
    @CurrentUserId      INT            = NULL,
    @CurrentUserName    VARCHAR(100)   = NULL,
    @AuthorizedUserName VARCHAR(100)   = NULL,
    @IsSuccess          BIT            = NULL,
    @ResultDescription  VARCHAR(500)   = NULL,
    @Reason             VARCHAR(200)   = NULL,
    @IpAddress          VARCHAR(50)    = NULL,
    @MachineName        VARCHAR(300)   = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.POS_DayEndAuthorizationLog
          (PropertyId, HotelDate, Outlet, CurrentUserId, CurrentUserName,
           AuthorizedUserName, IsSuccess, ResultDescription, Reason,
           IpAddress, MachineName)
    VALUES(@PropertyId, @HotelDate, @Outlet, @CurrentUserId, @CurrentUserName,
           LEFT(@AuthorizedUserName, 100), @IsSuccess, LEFT(@ResultDescription, 500),
           LEFT(@Reason, 200), LEFT(@IpAddress, 50), LEFT(@MachineName, 300));
END

GO

