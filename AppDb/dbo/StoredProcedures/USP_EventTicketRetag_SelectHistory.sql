
CREATE PROCEDURE dbo.USP_EventTicketRetag_SelectHistory
    @PropertyId         INT,
    @EventReservationID INT         = NULL,
    @EventID            INT         = NULL,
    @FromDate           DATE        = NULL,
    @ToDate             DATE        = NULL,
    @MobileNo           VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  H.Id,
            H.EventReservationID,
            H.EventTransactionHeaderID,
            H.MobileNo,
            H.CustomerName,
            H.EventID,
            H.EventNo,
            H.EventName,
            H.OutletCode,
            H.FromEventDateDetailID,
            H.FromEventDate,
            H.FromFromTime,
            H.ToEventDateDetailID,
            H.ToEventDate,
            H.ToFromTime,
            H.ToEventID,
            H.ToEventNo,
            H.ToEventName,
            H.IsCrossEvent,
            H.PreviousBookingStatusId,
            H.PreviousBookingStatus,
            H.PreviousIsComplete,
            H.NewBookingStatusId,
            H.NewBookingStatus,
            H.NewIsComplete,
            H.TotalTickets,
            H.TotalAmount,
            H.TargetTotalAmount,
            H.RetagSeqNo,
            H.RetaggedDate,
            H.RetaggedBy,
            H.RetaggedByName,
            H.Reason,
            H.SourceScreen,
            H.TicketMappingJson
    FROM    dbo.EventTicketRetagHistory H
    WHERE   H.PropertyId = @PropertyId
      AND   (@EventReservationID IS NULL OR H.EventReservationID = @EventReservationID)
      AND   (@EventID            IS NULL OR H.EventID            = @EventID)
      AND   (@FromDate           IS NULL OR CAST(H.RetaggedDate AS DATE) >= @FromDate)
      AND   (@ToDate             IS NULL OR CAST(H.RetaggedDate AS DATE) <= @ToDate)
      AND   (@MobileNo           IS NULL OR H.MobileNo = @MobileNo)
    ORDER BY H.Id DESC;
END

GO

