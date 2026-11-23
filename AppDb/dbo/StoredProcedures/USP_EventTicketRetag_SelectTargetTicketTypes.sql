
CREATE PROCEDURE dbo.USP_EventTicketRetag_SelectTargetTicketTypes
    @TargetEventDateDetailID INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Booked AS (
        SELECT  ETTD.TicketID, SUM(ETTD.BookQty) AS BookedQty
        FROM    dbo.EventTransactionTicketDetail ETTD
        INNER JOIN dbo.EventTransactionDetail    ETD ON ETD.ID = ETTD.EventTransactionDetailID
        WHERE   ETD.EventDateDetailID = @TargetEventDateDetailID
        GROUP BY ETTD.TicketID
    )
    SELECT  EWTD.TicketID,
            LTRIM(RTRIM(EWTD.TicketName))              AS TicketName,
            EWTD.Amount,
            EWTD.Qty,
            ISNULL(B.BookedQty, 0)                     AS BookedQty,
            EWTD.Qty - ISNULL(B.BookedQty, 0)          AS RemainingQty
    FROM    dbo.EventWiseTicketDetail EWTD
    LEFT JOIN Booked B ON B.TicketID = EWTD.TicketID
    WHERE   EWTD.EventDateDetailsID = @TargetEventDateDetailID
    ORDER BY EWTD.TicketName;
END

GO

