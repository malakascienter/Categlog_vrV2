-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-09-07
-- Description:	SP to run re-Order Notification based on Company DayEnd
-- =============================================

CREATE   PROCEDURE [dbo].[SP_InventoryReorderNotification_OnDayEnd]
    @Debug BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Pending TABLE (
        CompanyID INT  NOT NULL PRIMARY KEY,
        HotelDate DATE NOT NULL);

    ;WITH DayEnd AS (
        SELECT d.PropertyId, MAX(d.HotelDate) AS HotelDate
        FROM [HotelResWeb].[dbo].[DayEndCompleteTime] d   -- test server: dbo.DayEndCompleteTime
        --FROM [HotelResWeb].[dbo].[DayEndCompleteTime] d 
        WHERE d.HotelDate IS NOT NULL
        GROUP BY d.PropertyId
    ),
    AlreadySent AS (
        SELECT CompanyID, MAX(LastSentHotelDate) AS LastSentHotelDate
        FROM dbo.ReOrderLocationWiseEmail
        WHERE IsActive = 1
        GROUP BY CompanyID
    )
    INSERT INTO @Pending (CompanyID, HotelDate)
    SELECT c.CompanyID, de.HotelDate
    FROM DayEnd de
    INNER JOIN dbo.Companies c ON c.CompanyID = de.PropertyId
    LEFT JOIN AlreadySent a    ON a.CompanyID = c.CompanyID
    WHERE c.IsActive = 1
      AND ISNULL(c.IsInventoryReorderNotification, 0) = 1
      AND EXISTS (SELECT 1 FROM dbo.ReOrderLocationWiseEmail r
                  WHERE r.CompanyID = c.CompanyID AND r.IsActive = 1)
      AND (a.LastSentHotelDate IS NULL OR a.LastSentHotelDate <> de.HotelDate);

    IF @Debug = 1
    BEGIN
        SELECT p.CompanyID, LTRIM(RTRIM(c.Name)) AS CompanyName, p.HotelDate
        FROM @Pending p
        INNER JOIN dbo.Companies c ON c.CompanyID = p.CompanyID
        ORDER BY p.CompanyID;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM @Pending)
        RETURN;

    BEGIN TRY
        EXEC dbo.SP_ReSendFailedInventoryReorderNotification;
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.EmailErrorLog (EmailQueueID, Email, ErrorMessage, ErrorDate)
        VALUES (NULL, 'OnDayEnd', 'Resend sweep failed: ' + ERROR_MESSAGE(), GETDATE());
    END CATCH;

    DECLARE @CompanyID INT, @HotelDate DATE;

    DECLARE property_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT CompanyID, HotelDate FROM @Pending ORDER BY CompanyID;

    OPEN property_cursor;
    FETCH NEXT FROM property_cursor INTO @CompanyID, @HotelDate;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            EXEC dbo.SP_InventoryReorderNotification @CompanyID = @CompanyID;

            UPDATE dbo.ReOrderLocationWiseEmail
            SET LastSentHotelDate = @HotelDate
            WHERE CompanyID = @CompanyID
              AND IsActive  = 1;
        END TRY
        BEGIN CATCH
            INSERT INTO dbo.EmailErrorLog (EmailQueueID, Email, ErrorMessage, ErrorDate)
            VALUES (NULL, 'CompanyID=' + CONVERT(VARCHAR(20), @CompanyID),
                    'Reorder run failed for hotel date '
                      + CONVERT(VARCHAR(10), @HotelDate, 120) + ': ' + ERROR_MESSAGE(),
                    GETDATE());
        END CATCH;

        FETCH NEXT FROM property_cursor INTO @CompanyID, @HotelDate;
    END;

    CLOSE property_cursor;
    DEALLOCATE property_cursor;
END

GO

