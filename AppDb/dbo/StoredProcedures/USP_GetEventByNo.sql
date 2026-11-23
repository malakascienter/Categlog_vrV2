
CREATE PROCEDURE [dbo].[USP_GetEventByNo]
    @EventNo VARCHAR(50),
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Get event header
    SELECT
        E.[ID] as Id,
        E.[EventNo],
        E.[EventName],
        E.[Address],
        E.[Remark],
        E.[OutletCode],
        E.[PropertyId],
        E.[CoverPath],
        E.ThubnailPath as ThumbnailPath,
        1 IsActive,
        E.[IsEventAvailable],
        E.[CreateDate],
        E.[CreateUser],
        E.[LastModifiedDate],
        E.[LastModifiedUser],
        (SELECT ED.[ID] as Id, ED.[EventID] as EventId, ED.[Date], ED.[FromTime], ED.[ToTime] FROM EventDateDetails ED WHERE ED.EventID = E.ID FOR JSON AUTO) AS EventDateDetailsJson,
        (SELECT ET.[TicketID] as TicketId, ET.[EventDateDetailsID] as EventDateDetailsId, ET.[EventID] as EventId, ET.[TicketName], ET.[Amount], ET.[Qty] FROM EventWiseTicketDetail ET WHERE ET.EventID = E.ID FOR JSON AUTO) AS EventWiseTicketDetailJson
    FROM [dbo].[EventHeader] E
    WHERE E.[EventNo] = @EventNo AND E.[PropertyId] = @PropertyId;

END

GO

