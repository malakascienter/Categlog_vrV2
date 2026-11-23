CREATE TABLE [dbo].[EventDateDetails] (
    [ID]       INT      IDENTITY (1, 1) NOT NULL,
    [EventID]  INT      NOT NULL,
    [Date]     DATE     NOT NULL,
    [FromTime] TIME (7) NOT NULL,
    [ToTime]   TIME (7) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO


CREATE TRIGGER dbo.TR_EventDateDetails_OneDatePerEvent
ON dbo.EventDateDetails
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT  EDD.EventID
        FROM    dbo.EventDateDetails EDD
        WHERE   EDD.EventID IN (SELECT EventID FROM inserted)
        GROUP BY EDD.EventID
        HAVING  COUNT(*) > 1
    )
    BEGIN
        RAISERROR('An event can only have one date (EventDateDetails row). Multiple event dates are not allowed.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

GO

