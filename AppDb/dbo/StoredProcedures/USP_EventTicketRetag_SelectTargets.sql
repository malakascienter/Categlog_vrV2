
CREATE PROCEDURE dbo.USP_EventTicketRetag_SelectTargets
    @PropertyId         INT,
    @EventReservationID INT,
    @TargetEventID      INT      = NULL,
    @AsAtDateTime       DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @AsAtDateTime IS NULL SET @AsAtDateTime = GETDATE();

    DECLARE @EventID                  INT,
            @CurrentEventDateDetailID INT,
            @OutletCode               VARCHAR(5);

    SELECT  @EventID                  = ETD.EventID,
            @CurrentEventDateDetailID = ETD.EventDateDetailID,
            @OutletCode               = EH.OutletCode
    FROM    dbo.EventTransactionDetail ETD
    INNER JOIN dbo.EventHeader EH ON EH.ID = ETD.EventID
    WHERE   ETD.ID = @EventReservationID
      AND   EH.PropertyId = @PropertyId;

    IF @TargetEventID IS NULL SET @TargetEventID = @EventID;

    IF @EventID IS NULL
       OR (@TargetEventID <> @EventID
           AND NOT EXISTS (SELECT 1 FROM dbo.EventHeader
                           WHERE ID = @TargetEventID AND PropertyId = @PropertyId
                             AND OutletCode = @OutletCode))
    BEGIN
        -- Shape-compatible empty result set: no source ticket, or the chosen
        -- target event does not belong to this property / outlet.
        SELECT  CAST(0 AS INT)  AS EventDateDetailID,
                CAST(NULL AS DATE) AS EventDate,
                CAST(NULL AS TIME(7)) AS FromTime,
                CAST(NULL AS TIME(7)) AS ToTime,
                CAST(0 AS INT)  AS TicketTypeCount,
                CAST(0 AS INT)  AS MinRemainingQty,
                CAST(0 AS BIT)  AS IsCompatible
        WHERE   1 = 0;
        RETURN;
    END

    IF @TargetEventID <> @EventID
    BEGIN
        /*  Different event: no ticket-type name to match against, so
            compatibility only means "has some ticket type"; the real check
            happens per-line once the admin has mapped ticket types.  */
        SELECT  EDD.ID          AS EventDateDetailID,
                EDD.[Date]      AS EventDate,
                EDD.FromTime,
                EDD.ToTime,
                (SELECT COUNT(*) FROM dbo.EventWiseTicketDetail T
                 WHERE T.EventDateDetailsID = EDD.ID)             AS TicketTypeCount,
                ISNULL((
                    SELECT MIN(T.Qty - ISNULL(BK.BookedQty, 0))
                    FROM    dbo.EventWiseTicketDetail T
                    LEFT JOIN (
                        SELECT  ETTD.TicketID, SUM(ETTD.BookQty) AS BookedQty
                        FROM    dbo.EventTransactionTicketDetail ETTD
                        INNER JOIN dbo.EventTransactionDetail    ETD2 ON ETD2.ID = ETTD.EventTransactionDetailID
                        WHERE   ETD2.EventDateDetailID = EDD.ID
                        GROUP BY ETTD.TicketID
                    ) BK ON BK.TicketID = T.TicketID
                    WHERE   T.EventDateDetailsID = EDD.ID
                ), 0)                                             AS MinRemainingQty,
                CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.EventWiseTicketDetail T
                                       WHERE T.EventDateDetailsID = EDD.ID)
                          THEN 1 ELSE 0 END AS BIT)                AS IsCompatible
        FROM    dbo.EventDateDetails EDD
        WHERE   EDD.EventID = @TargetEventID
          AND   DATEADD(SECOND, DATEDIFF(SECOND, 0, EDD.FromTime),
                        CAST(EDD.[Date] AS DATETIME)) > @AsAtDateTime
        ORDER BY EDD.[Date], EDD.FromTime;
        RETURN;
    END

    ;WITH SrcTypes AS (
        SELECT  LTRIM(RTRIM(EWTD.TicketName)) AS TicketName,
                SUM(ETTD.BookQty)             AS MoveQty
        FROM    dbo.EventTransactionTicketDetail ETTD
        LEFT JOIN dbo.EventWiseTicketDetail      EWTD ON EWTD.TicketID = ETTD.TicketID
        WHERE   ETTD.EventTransactionDetailID = @EventReservationID
        GROUP BY LTRIM(RTRIM(EWTD.TicketName))
    ),
    TgtTypes AS (
        SELECT  EWTD.EventDateDetailsID       AS EventDateDetailID,
                LTRIM(RTRIM(EWTD.TicketName)) AS TicketName,
                MIN(EWTD.TicketID)            AS TargetTicketID,
                MIN(EWTD.Qty)                 AS TargetQty
        FROM    dbo.EventWiseTicketDetail EWTD
        WHERE   EWTD.EventID = @EventID
        GROUP BY EWTD.EventDateDetailsID, LTRIM(RTRIM(EWTD.TicketName))
    ),
    TgtBooked AS (
        SELECT  ETTD.TicketID, SUM(ETTD.BookQty) AS BookedQty
        FROM    dbo.EventTransactionTicketDetail ETTD
        INNER JOIN dbo.EventTransactionDetail    ETD ON ETD.ID = ETTD.EventTransactionDetailID
        INNER JOIN dbo.EventWiseTicketDetail     EWTD ON EWTD.TicketID = ETTD.TicketID
        WHERE   EWTD.EventID = @EventID
          AND   ETD.EventDateDetailID = EWTD.EventDateDetailsID
        GROUP BY ETTD.TicketID
    ),
    Fit AS (
        SELECT  T.EventDateDetailID,
                S.TicketName,
                S.MoveQty,
                T.TargetQty - ISNULL(B.BookedQty, 0) AS RemainingQty
        FROM    SrcTypes S
        LEFT JOIN TgtTypes  T ON T.TicketName = S.TicketName
        LEFT JOIN TgtBooked B ON B.TicketID   = T.TargetTicketID
    )
    SELECT  EDD.ID                      AS EventDateDetailID,
            EDD.[Date]                  AS EventDate,
            EDD.FromTime,
            EDD.ToTime,
            (SELECT COUNT(*) FROM TgtTypes T2 WHERE T2.EventDateDetailID = EDD.ID) AS TicketTypeCount,
            ISNULL((SELECT MIN(F.RemainingQty) FROM Fit F WHERE F.EventDateDetailID = EDD.ID), 0) AS MinRemainingQty,
            CAST(CASE WHEN NOT EXISTS (SELECT 1 FROM SrcTypes)                              THEN 0
                      WHEN EXISTS (SELECT 1 FROM Fit F
                                   WHERE F.EventDateDetailID IS NULL)                        THEN 0
                      WHEN EXISTS (SELECT 1 FROM Fit F
                                   WHERE F.EventDateDetailID = EDD.ID
                                     AND F.RemainingQty < F.MoveQty)                         THEN 0
                      WHEN (SELECT COUNT(*) FROM Fit F WHERE F.EventDateDetailID = EDD.ID)
                           < (SELECT COUNT(*) FROM SrcTypes)                                 THEN 0
                      ELSE 1 END AS BIT) AS IsCompatible
    FROM    dbo.EventDateDetails EDD
    WHERE   EDD.EventID = @EventID
      AND   EDD.ID <> @CurrentEventDateDetailID
      AND   DATEADD(SECOND, DATEDIFF(SECOND, 0, EDD.FromTime),
                    CAST(EDD.[Date] AS DATETIME)) > @AsAtDateTime
    ORDER BY EDD.[Date], EDD.FromTime;
END

GO

