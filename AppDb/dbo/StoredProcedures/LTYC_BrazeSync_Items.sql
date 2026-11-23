/*  Per-member outcomes, so "which 640 members did not go, and why?" is
    answerable from the screen rather than from a log file.                      */
CREATE PROCEDURE dbo.LTYC_BrazeSync_Items
    @SyncId int,
    @Status varchar(20) = NULL,
    @Top    int = 200
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Top)
           i.ItemId, i.MemberId, m.MembershipCode,
           CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,
           i.ExternalId, i.Status, i.SkipReason, i.AttemptCount, i.HttpStatus, i.ErrorMessage, i.SentAt
    FROM   dbo.LTYC_BrazeSyncItem AS i
    LEFT JOIN dbo.LTY_Member AS m ON m.MemberId = i.MemberId
    WHERE  i.SyncId = @SyncId
      AND  (@Status IS NULL OR i.Status = @Status)
    ORDER BY CASE i.Status WHEN 'FAILED' THEN 0 WHEN 'SKIPPED' THEN 1 ELSE 2 END, i.ItemId;
END

GO

