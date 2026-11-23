-- =============================================
-- Author:		Nivesh
-- Create date: 2026-01-08
-- Description:	Send Inventory Reorder Notification
-- =============================================
CREATE PROCEDURE [dbo].[SP_InventoryReorderNotification]
    @CompanyID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TimePeriod INT = 24, -- Hours
		@StartTime TIME = '10:00',
        @StartDateTime DATETIME,
        @EndDateTime   DATETIME,
        @YesterdayStartDateTime DATETIME,
        @YesterdayEndDateTime   DATETIME,
        @DocNo VARCHAR(50),
        @IsInventoryReorderNotification BIT = 0,
        @CurrentDateTime DATETIME = GETDATE();

    SELECT TOP 1 
        @TimePeriod = DayTimePeriod,
        @StartTime = DayStartTime,
        @IsInventoryReorderNotification = ISNULL(IsInventoryReorderNotification,0)
    FROM Companies
    WHERE (@CompanyID IS NULL OR CompanyID = @CompanyID)
    ORDER BY CompanyID

    IF(@IsInventoryReorderNotification = 1)
    BEGIN

        CREATE TABLE #TempLocationWiseEmail(
            Id INT, LocationID INT, CompanyID INT, EmailList NVARCHAR(MAX))

        INSERT INTO #TempLocationWiseEmail(Id, LocationID, CompanyID, EmailList)
        SELECT Id, LocationID, CompanyID, EmailList
        FROM [dbo].[ReOrderLocationWiseEmail]
        WHERE IsActive =1
          AND (@CompanyID IS NULL OR CompanyID = @CompanyID)

	    DECLARE 
            @EmailQueueID INT,
            @Email NVARCHAR(200) ,
            @Subject NVARCHAR(MAX) = 'Re-Order Reached Items',
            @Body NVARCHAR(MAX),
            @mailitem_id INT,
            @b_format VARCHAR(50),
            @Profile_name SYSNAME,
            @MailStatus NVARCHAR(10);

        SET @StartDateTime =
        CASE
            WHEN CAST(@CurrentDateTime AS TIME) < @StartTime
                THEN DATEADD(DAY, -1,
                        CAST(CAST(@CurrentDateTime AS DATE) AS DATETIME)
                        + CAST(@StartTime AS DATETIME))
            ELSE
                CAST(CAST(@CurrentDateTime AS DATE) AS DATETIME)
                + CAST(@StartTime AS DATETIME)
        END;

        SET @EndDateTime = DATEADD(HOUR, @TimePeriod, @StartDateTime);

        SET @YesterdayStartDateTime =
		        CAST(CAST(DATEADD(DAY, -1, GETDATE()) AS DATE) AS DATETIME)
		        + CAST(@StartTime AS DATETIME);

	    SET @YesterdayEndDateTime = DATEADD(HOUR, @TimePeriod, @YesterdayStartDateTime);

    ---- Email Re Send Start-------------
       IF @CompanyID IS NULL
           EXEC SP_ReSendFailedInventoryReorderNotification
    ---- Email Re Send End-------------

        UPDATE IR
        SET IR.NotificationStatus = 'D'
        FROM
            [dbo].[InventoryReorderNotificationLog] IR
            WHERE (
            FORMAT(GETDATE(),'yyyy-MM-dd HH:mm') NOT
            BETWEEN FORMAT(StartDate,'yyyy-MM-dd HH:mm') 
            AND FORMAT(EndDate,'yyyy-MM-dd HH:mm')
            )

        CREATE TABLE #TempInventoryReorderNotificationLog
        (
            Id INT, StockItemID INT, LocationID INT, UnitID INT, CompanyID INT,
            QuantityInHand DECIMAL(18,4), ReOrderLevel DECIMAL(18,4),
            ReOrderQuantity DECIMAL(18,4), IsSent BIT, NotificationStatus CHAR(2),
            NotificationID INT, SentDate DATETIME
        )

        INSERT INTO #TempInventoryReorderNotificationLog
        ( Id, StockItemID, LocationID, UnitID, CompanyID, QuantityInHand,
          ReOrderLevel, ReOrderQuantity, IsSent, NotificationStatus,
          NotificationID, SentDate )
        SELECT 
            Id, StockItemID, LocationID, UnitID, CompanyID, QuantityInHand,
            ReOrderLevel, ReOrderQuantity, IsSent, NotificationStatus,
            NotificationID, SendRequestDate
        FROM
        [dbo].[InventoryReorderNotificationLog]
        WHERE
        (
            (
                FORMAT(SendRequestDate,'yyyy-MM-dd HH:mm')
                BETWEEN FORMAT(@StartDateTime,'yyyy-MM-dd HH:mm')
                AND FORMAT(@EndDateTime,'yyyy-MM-dd HH:mm')
            )
            OR
            (
                FORMAT(GETDATE(),'yyyy-MM-dd HH:mm')
                BETWEEN FORMAT(StartDate,'yyyy-MM-dd HH:mm')
                AND FORMAT(EndDate,'yyyy-MM-dd HH:mm')
            )
        )
        AND (@CompanyID IS NULL OR CompanyID = @CompanyID)

       INSERT INTO [dbo].[StockReplenishmentLog]
        ( [StockItemId],[LocationID],[UnitID],[CompanyID]
         ,[QuantityInHand],[ReOrderLevel],[ReOrderQuantity] )
        SELECT 
            SD.StockItemHeaderID, SD.LocationID, SD.MasterUnitID, SD.PropertyID,
            SD.QuantityInHand, SD.ReOrderLevel, SD.ReOrderQuantity
        FROM
        StockItemDetails sd
        INNER JOIN StockItemHeaders SH ON SH.id = SD.StockItemHeaderID
        INNER JOIN Locations L ON L.Id = SD.LocationID
        INNER JOIN (
            SELECT STIR.StockItemID, STIR.LocationID, STIR.CompanyID,
                   MAX(STIR.SentDate) AS SentDate
            FROM #TempInventoryReorderNotificationLog STIR 
            GROUP BY STIR.StockItemID, STIR.LocationID, STIR.CompanyID
        ) TIR ON TIR.StockItemID = SD.StockItemHeaderID
        AND TIR.LocationID = SD.LocationID
        AND TIR.CompanyID = SD.PropertyID
        WHERE SD.ReOrderLevel > 0
        AND SD.ReOrderLevel < SD.QuantityInHand
        AND (@CompanyID IS NULL OR SD.PropertyID = @CompanyID)

        CREATE TABLE #TempLowStockItems
        (
            StockItemID INT, LocationID INT, UnitID INT, CompanyID INT,
            QuantityInHand DECIMAL(18,4), ReOrderLevel DECIMAL(18,4),
            ReOrderQuantity DECIMAL(18,4), LocationName VARCHAR(600),
            ItemName VARCHAR(600), StockItemCode VARCHAR(600), SystemDate DATETIME
        )

        INSERT INTO #TempLowStockItems
        ( StockItemID, LocationID, UnitID, CompanyID, QuantityInHand,
          ReOrderLevel, ReOrderQuantity, LocationName, ItemName,
          StockItemCode, SystemDate )
        SELECT 
            SH.Id, L.Id, SD.MasterUnitID, SD.PropertyID, SD.QuantityInHand,
            SD.ReOrderLevel, SD.ReOrderQuantity, L.Name, SH.Name,
            SH.StockItemCode, GETDATE()
        FROM
        StockItemDetails sd
        INNER JOIN StockItemHeaders SH ON SH.id = SD.StockItemHeaderID
        INNER JOIN Locations L ON L.Id = SD.LocationID
        WHERE SD.ReOrderLevel > 0
        AND SD.ReOrderLevel >= SD.QuantityInHand
        AND (@CompanyID IS NULL OR SD.PropertyID = @CompanyID)

        DECLARE @InsertedIDs_InventoryReorderNotificationLog TABLE (ID INT);

        IF EXISTS(
            SELECT 1
            FROM #TempLowStockItems TLS
            INNER JOIN #TempLocationWiseEmail TLWE ON TLWE.CompanyID = TLS.CompanyID
                AND TLWE.LocationID = TLS.LocationID
            LEFT JOIN (
                SELECT STIR.StockItemID, STIR.LocationID, STIR.CompanyID,
                       MAX(STIR.SentDate) AS SentDate
                FROM #TempInventoryReorderNotificationLog STIR 
                GROUP BY STIR.StockItemID, STIR.LocationID, STIR.CompanyID
            ) TIR ON TIR.StockItemID = TLS.StockItemID
            AND TIR.LocationID = TLS.LocationID
            AND TIR.CompanyID = TLS.CompanyID
            LEFT JOIN (
                SELECT STIR.StockItemID, STIR.LocationID, STIR.CompanyID,
                       MAX(STIR.SystemDate) AS SystemDate
                FROM [StockReplenishmentLog] STIR 
                GROUP BY STIR.StockItemID, STIR.LocationID, STIR.CompanyID
            ) SR ON SR.LocationID = TLS.LocationID
            AND SR.StockItemId = TLS.StockItemID
            AND SR.CompanyID = TLS.CompanyID
             AND (
            FORMAT(SR.SystemDate,'yyyy-MM-dd HH:mm') 
            BETWEEN FORMAT(@StartDateTime,'yyyy-MM-dd HH:mm') 
            AND FORMAT(@EndDateTime,'yyyy-MM-dd HH:mm')
            )
            WHERE TIR.StockItemID IS NULL
            OR TLS.SystemDate > SR.SystemDate
        )
        BEGIN
            EXEC SP_InvGetNextDocNo 'SRON', @DocNo OUTPUT
        END

        INSERT INTO [dbo].[InventoryReorderNotificationLog]
        (   [StockItemID],[LocationID],[UnitID],[CompanyID],[QuantityInHand]
           ,[ReOrderLevel],[ReOrderQuantity],[NotificationID],[NotificationType]
           ,[NotificationStatus],[StartDate],[EndDate],[SendRequestDate]
           ,[SentDate],[IsSent],[DocNo] )
        OUTPUT INSERTED.Id INTO @InsertedIDs_InventoryReorderNotificationLog
        SELECT 
            TLS.StockItemID, TLS.LocationID, TLS.UnitID, TLS.CompanyID,
            TLS.QuantityInHand, TLS.ReOrderLevel, TLS.ReOrderQuantity,
            0, 'Email', '', @StartDateTime, @EndDateTime, GETDATE(),
            NULL, 0, @DocNo
        FROM #TempLowStockItems TLS
        INNER JOIN #TempLocationWiseEmail TLWE ON TLWE.CompanyID = TLS.CompanyID
            AND TLWE.LocationID = TLS.LocationID
        LEFT JOIN (
            SELECT STIR.StockItemID, STIR.LocationID, STIR.CompanyID,
                   MAX(STIR.SentDate) AS SentDate
            FROM #TempInventoryReorderNotificationLog STIR 
            GROUP BY STIR.StockItemID, STIR.LocationID, STIR.CompanyID
        ) TIR ON TIR.StockItemID = TLS.StockItemID
        AND TIR.LocationID = TLS.LocationID
        AND TIR.CompanyID = TLS.CompanyID
        LEFT JOIN (
            SELECT STIR.StockItemID, STIR.LocationID, STIR.CompanyID,
                   MAX(STIR.SystemDate) AS SystemDate
            FROM [StockReplenishmentLog] STIR 
            GROUP BY STIR.StockItemID, STIR.LocationID, STIR.CompanyID
        ) SR ON SR.LocationID = TLS.LocationID
        AND SR.StockItemId = TLS.StockItemID
        AND SR.CompanyID = TLS.CompanyID
         AND (
        FORMAT(SR.SystemDate,'yyyy-MM-dd HH:mm') 
        BETWEEN FORMAT(@StartDateTime,'yyyy-MM-dd HH:mm') 
        AND FORMAT(@EndDateTime,'yyyy-MM-dd HH:mm')
        )
        WHERE TIR.StockItemID IS NULL
        OR TLS.SystemDate > SR.SystemDate

            DELETE sr
            FROM [StockReplenishmentLog] sr
            INNER JOIN
            (
                SELECT StockItemID, LocationID, CompanyID, SystemDate AS SystemDate
                FROM [StockReplenishmentLog]
            ) srMax
                ON sr.StockItemID = srMax.StockItemID
               AND sr.LocationID = srMax.LocationID
               AND sr.CompanyID = srMax.CompanyID
               AND sr.SystemDate = srMax.SystemDate
            INNER JOIN #TempLowStockItems ir
                ON ir.StockItemID = sr.StockItemID
               AND ir.LocationID = sr.LocationID
               AND ir.CompanyID = sr.CompanyID
            WHERE 
                sr.SystemDate BETWEEN @StartDateTime AND @EndDateTime
                AND ir.SystemDate > sr.SystemDate;

        IF EXISTS(SELECT 1 FROM @InsertedIDs_InventoryReorderNotificationLog)
        BEGIN
            DECLARE @Id INT,
			    @LocationID INT,
                @Cur_CompanyID INT,
                @EmailList NVARCHAR(MAX),
                @Rows NVARCHAR(MAX);

		    DECLARE locationWiseEmail_cursor CURSOR FOR
		    SELECT TE.Id, TE.LocationID, TE.CompanyID, TE.EmailList
		    FROM #TempLocationWiseEmail TE
            INNER JOIN (
                SELECT IR.LocationID, IR.CompanyID
                FROM [dbo].[InventoryReorderNotificationLog] IR
                INNER JOIN @InsertedIDs_InventoryReorderNotificationLog IIR ON IIR.ID =IR.Id
                GROUP BY IR.LocationID, IR.CompanyID
            ) AS IR ON TE.CompanyID = IR.CompanyID 
                        AND TE.LocationID = IR.LocationID

            OPEN locationWiseEmail_cursor;
            FETCH NEXT FROM locationWiseEmail_cursor INTO 
                @Id, @LocationID, @Cur_CompanyID, @EmailList;

            WHILE @@FETCH_STATUS = 0
            BEGIN

                  --Build subject for this property Start--
                    SET @Subject = N'Re-Order Reached Items';

                    SELECT @Subject = LTRIM(RTRIM(C.Name)) + N': Re-Order Reached Items'
                    FROM dbo.Companies C
                    WHERE C.CompanyID = @Cur_CompanyID;
                    --Build subject for this property End--

                    SELECT @Rows = (
                    SELECT
                        '<tr>' +
                        '<td>' + TLS.LocationName + '</td>' +
                        '<td>' + TLS.ItemName + '</td>' +
                        '<td>' + TLS.StockItemCode + '</td>' +
                        '<td>' + CONVERT(VARCHAR(50), CAST(TLS.QuantityInHand  AS DECIMAL(18,2))) + '</td>' +
                        '<td>' + CONVERT(VARCHAR(50), CAST(TLS.ReOrderLevel    AS DECIMAL(18,2))) + '</td>' +
                        '<td>' + CONVERT(VARCHAR(50), CAST(TLS.ReOrderQuantity AS DECIMAL(18,2))) + '</td>' +
                        '</tr>'
                    FROM
                    [dbo].[InventoryReorderNotificationLog] IR
                    INNER JOIN @InsertedIDs_InventoryReorderNotificationLog IIR ON IIR.ID =IR.Id
                    INNER JOIN #TempLowStockItems TLS ON TLS.CompanyID = IR.CompanyID
                        AND TLS.StockItemID = IR.StockItemID 
                        AND TLS.LocationID = IR.LocationID
                    WHERE TLS.LocationID = @LocationID
                        AND TLS.CompanyID = @Cur_CompanyID
                    FOR XML PATH(''), TYPE
                    ).value('.', 'NVARCHAR(MAX)')

                    SET @Body = '<html><body><p>Low Stock Items</p>
					                    <table border = 1>
					                    <thead>
						                    <th  style="width: 20%" >Location</th>
						                    <th  style="width: 20%" >Item Name</th>
						                    <th  style="width: 20%" >ItemCode</th>
						                    <th  style="width: 20%" >Quantity In Hand</th>
						                    <th  style="width: 20%" >Reorder Level</th>
                                            <th  style="width: 20%" >Reorder Quantity</th>
					                    </thead>
					                    <tbody >
						                '+ ISNULL(@Rows,'') +'
					                    </tbody>
					                    </table></html></body>';

                    DECLARE email_cursor CURSOR FOR
                    SELECT LTRIM(RTRIM(value)) 
                    FROM STRING_SPLIT(@EmailList, ',');

                    OPEN email_cursor;

                    FETCH NEXT FROM email_cursor INTO 
                        @Email;
                    WHILE @@FETCH_STATUS = 0
                    BEGIN

                        BEGIN TRY    
                            EXEC SendReuestMail 
                            @MailSet = @Email,
                            @Subject = @Subject,
                            @Body = @Body,
                            @mailitem_id = @mailitem_id OUTPUT;

                            WAITFOR DELAY '00:00:06';

                            SELECT @MailStatus = sent_status
                            FROM msdb.dbo.sysmail_allitems
                            WHERE mailitem_id = @mailitem_id;

                            UPDATE IRN
                            SET 
                                IRN.IsSent = CASE WHEN @MailStatus = 'sent' THEN 1 ELSE 0 END,
                                IRN.SentDate = CASE WHEN @MailStatus = 'sent' THEN GETDATE() ELSE NULL END,
                                IRN.NotificationID = @mailitem_id,
                                IRN.NotificationStatus = CASE WHEN @MailStatus = 'sent' THEN 'C' ELSE 'P' END
                            FROM
                            [dbo].[InventoryReorderNotificationLog] IRN
                            INNER JOIN @InsertedIDs_InventoryReorderNotificationLog IIRN ON IIRN.ID = IRN.Id
                            INNER JOIN #TempLowStockItems TLS ON TLS.CompanyID = IRN.CompanyID
                                AND TLS.StockItemID = IRN.StockItemID 
                                AND TLS.LocationID = IRN.LocationID
                            WHERE TLS.LocationID = @LocationID
                                AND TLS.CompanyID = @Cur_CompanyID

                            UPDATE ReOrderLocationWiseEmail
                            SET LastSentDate = GETDATE(),
                                LastSentStatus = CASE WHEN @MailStatus = 'sent' THEN 'C' ELSE 'P' END,
                                LastDocNo = @DocNo
                            WHERE Id = @Id

                            IF ISNULL(@MailStatus,'') <> 'sent'
                            BEGIN
                                INSERT INTO dbo.EmailErrorLog (EmailQueueID, Email, ErrorMessage, ErrorDate)
                                VALUES (@mailitem_id, @Email, 'Mail not sent or timed out', GETDATE());
                            END

                        END TRY
                        BEGIN CATCH
                        INSERT INTO dbo.EmailErrorLog (EmailQueueID, Email, ErrorMessage, ErrorDate)
                        VALUES (@mailitem_id, @Email, ERROR_MESSAGE(), GETDATE());
                        END CATCH;

                        -- moved out of TRY: always advance, even after a mail error
                        FETCH NEXT FROM email_cursor INTO @Email;
                    END;

                    CLOSE email_cursor;
                    DEALLOCATE email_cursor;

                FETCH NEXT FROM locationWiseEmail_cursor INTO 
                    @Id, @LocationID, @Cur_CompanyID, @EmailList;
            END;

            CLOSE locationWiseEmail_cursor;
            DEALLOCATE locationWiseEmail_cursor;

        END
        DROP TABLE #TempInventoryReorderNotificationLog
        DROP TABLE #TempLowStockItems

        EXEC [dbo].[InvUpdateNextDocNo] 'SRON'
    END

    IF @CompanyID IS NULL
    BEGIN
        DELETE FROM [dbo].[InventoryReorderNotificationLog]
        WHERE ISNULL(SentDate, SendRequestDate) < DATEADD(DAY, -7, CAST(GETDATE() AS DATE));

        DELETE FROM [StockReplenishmentLog]
        WHERE SystemDate < DATEADD(DAY, -7, CAST(GETDATE() AS DATE));
    END
END

GO

