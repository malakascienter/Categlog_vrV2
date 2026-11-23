
CREATE PROCEDURE dbo.USP_EventTicketRetag_SelectEligible
    @PropertyId             INT,
    @OutletCode             VARCHAR(5)   = NULL,
    @EventID                INT          = NULL,
    @FromDate               DATE         = NULL,
    @ToDate                 DATE         = NULL,
    @MobileNo               VARCHAR(20)  = NULL,
    @RequireConfirmedStatus BIT          = 1,
    @OnlyPastOccurrences    BIT          = 1,
    @AsAtDateTime           DATETIME     = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @AsAtDateTime IS NULL SET @AsAtDateTime = GETDATE();

    SELECT
            ETD.ID                              AS EventReservationID,
            ETD.EventTransactionHeaderID,
            EH.ID                               AS EventID,
            EH.EventNo,
            EH.EventName,
            EH.OutletCode,
            EH.PropertyId,

            EDD.ID                              AS CurrentEventDateDetailID,
            EDD.[Date]                          AS CurrentEventDate,
            EDD.FromTime                        AS CurrentFromTime,
            EDD.ToTime                          AS CurrentToTime,

            ETD.OriginalEventDateDetailID,
            ISNULL(OEDD.[Date], EDD.[Date])     AS OriginalEventDate,
            ETD.RetagCount,
            ETD.LastRetagDate,

            ETH.Salutation,
            ETH.FirstName,
            ETH.LastName,
            LTRIM(RTRIM(ISNULL(ETH.Salutation, N'') + N' '
                      + ISNULL(ETH.FirstName,  N'') + N' '
                      + ISNULL(ETH.LastName,   N''))) AS CustomerName,
            ETH.MobileNo                        AS ContactNo,
            ETH.Email,
            ETH.SysDate                         AS BookingDate,

            ETH.BookingStatusId                 AS BookingStatusID,
            LTRIM(RTRIM(ISNULL(RS.Status, '')))  AS BookingStatus,
            ETD.IsComplete,

            ISNULL(TK.TotalTickets, 0)          AS TotalTickets,
            ISNULL(TK.TotalAmount, 0)           AS TotalAmount,
            ISNULL(TK.TicketSummary, N'')       AS TicketSummary
    FROM        dbo.EventTransactionDetail  AS ETD
    INNER JOIN  dbo.EventDateDetails        AS EDD  ON EDD.ID = ETD.EventDateDetailID
    INNER JOIN  dbo.EventHeader             AS EH   ON EH.ID  = ETD.EventID
    INNER JOIN  dbo.EventTransactionHeader  AS ETH  ON ETH.ID = ETD.EventTransactionHeaderID
    LEFT  JOIN  dbo.EventDateDetails        AS OEDD ON OEDD.ID = ETD.OriginalEventDateDetailID
    LEFT  JOIN  dbo.ReservationStatus       AS RS   ON RS.ID = ETH.BookingStatusId
    OUTER APPLY (
            SELECT  SUM(ETTD.BookQty)     AS TotalTickets,
                    SUM(ETTD.TotalAmount) AS TotalAmount,
                    STUFF((
                        SELECT N', ' + LTRIM(RTRIM(EWTD2.TicketName)) + N' x'
                                     + CAST(ETTD2.BookQty AS NVARCHAR(10))
                        FROM   dbo.EventTransactionTicketDetail AS ETTD2
                        LEFT  JOIN dbo.EventWiseTicketDetail    AS EWTD2
                               ON EWTD2.TicketID = ETTD2.TicketID
                        WHERE  ETTD2.EventTransactionDetailID = ETD.ID
                        ORDER BY EWTD2.TicketName
                        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N'')
                                          AS TicketSummary
            FROM    dbo.EventTransactionTicketDetail AS ETTD
            WHERE   ETTD.EventTransactionDetailID = ETD.ID
    ) AS TK
    WHERE   EH.PropertyId  = @PropertyId
      AND   ETD.IsComplete = 0                                   -- not redeemed
      AND   (@OutletCode IS NULL OR EH.OutletCode = @OutletCode)
      AND   (@EventID    IS NULL OR EH.ID         = @EventID)
      AND   (@FromDate   IS NULL OR EDD.[Date]   >= @FromDate)
      AND   (@ToDate     IS NULL OR EDD.[Date]   <= @ToDate)
      AND   (@MobileNo   IS NULL OR ETH.MobileNo  = @MobileNo)
      AND   (@RequireConfirmedStatus = 0 OR ETH.BookingStatusId = 2)
      AND   NOT EXISTS (SELECT 1 FROM dbo.ReservationStatus RS2
                        WHERE RS2.ID = ETH.BookingStatusId
                          AND (RS2.Status LIKE '%cancel%'
                            OR RS2.Status LIKE '%refund%'
                            OR RS2.Status LIKE '%void%'
                            OR RS2.Status LIKE '%reject%'))
      AND   (@OnlyPastOccurrences = 0
             OR DATEADD(SECOND, DATEDIFF(SECOND, 0, EDD.FromTime),
                        CAST(EDD.[Date] AS DATETIME)) <= @AsAtDateTime)
    ORDER BY EDD.[Date] DESC, EDD.FromTime, ETH.LastName, ETH.FirstName, ETD.ID;
END

GO

