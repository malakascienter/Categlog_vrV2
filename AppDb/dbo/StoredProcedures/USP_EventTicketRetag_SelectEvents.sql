
CREATE PROCEDURE dbo.USP_EventTicketRetag_SelectEvents
    @PropertyId INT,
    @OutletCode VARCHAR(5) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  EH.ID   AS EventID,
            EH.EventNo,
            EH.EventName,
            EH.OutletCode,
            (SELECT COUNT(*) FROM dbo.EventDateDetails D WHERE D.EventID = EH.ID) AS OccurrenceCount
    FROM    dbo.EventHeader EH
    WHERE   EH.PropertyId = @PropertyId
      AND   (@OutletCode IS NULL OR EH.OutletCode = @OutletCode)
      AND   EXISTS (SELECT 1 FROM dbo.EventDateDetails D WHERE D.EventID = EH.ID)
    ORDER BY EH.EventNo;
END

GO

