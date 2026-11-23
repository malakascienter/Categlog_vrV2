
CREATE PROCEDURE [dbo].[SPO_UpdateOrderWithDetails]
    @OrderId INT,
    @OrderHeaderJSON NVARCHAR(MAX),
    @OrderDetailsJSON NVARCHAR(MAX),
    @TotalBillDiscountJSON NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OrderTypeId    INT,
                @DeliveryDate   DATE,
                @DeliveryTime   TIME,
                @DeliveryOutlet VARCHAR(100),
                @Discount       DECIMAL(18,2),
                @OrderRemark    VARCHAR(500),
                @TotalAmount    DECIMAL(18,2),
                @ModifiedBy     INT,
                @IsAmend        BIT,
                @AmendCount     INT,
                @OldData        NVARCHAR(MAX),
                @NewData        NVARCHAR(MAX),
                @PropertyId     INT,
                @IsItemWiseDiscount BIT = 0   -- ← [CHANGE 1] Added

        SET @OrderTypeId    = JSON_VALUE(@OrderHeaderJSON, '$.OrderTypeId');
        SET @DeliveryDate   = JSON_VALUE(@OrderHeaderJSON, '$.DeliveryDate');
        SET @DeliveryTime   = JSON_VALUE(@OrderHeaderJSON, '$.DeliveryTime');
        SET @DeliveryOutlet = JSON_VALUE(@OrderHeaderJSON, '$.DeliveryOutlet');
        SET @Discount       = JSON_VALUE(@OrderHeaderJSON, '$.Discount');
        SET @OrderRemark    = JSON_VALUE(@OrderHeaderJSON, '$.OrderRemark');
        SET @TotalAmount    = JSON_VALUE(@OrderHeaderJSON, '$.TotalAmount');
        SET @ModifiedBy     = JSON_VALUE(@OrderHeaderJSON, '$.ModifiedBy');
        SET @IsAmend        = JSON_VALUE(@OrderHeaderJSON, '$.IsAmend');
        SET @IsItemWiseDiscount = ISNULL(
            CAST(JSON_VALUE(@OrderHeaderJSON, '$.IsItemWiseDiscount') AS BIT), 0
        );                                    -- ← [CHANGE 1] Read from JSON

        -- Read PropertyId from existing header
        SELECT  @AmendCount         = ISNULL(AmendCount, 0),
                @PropertyId         = PropertyId              -- ← [CHANGE 2] Capture PropertyId
        FROM SPO_OrderHeader
        WHERE OrderId = @OrderId;

        SET @AmendCount = @AmendCount + 1;

        -- ============================================================
        -- [CHANGE 3] SAVE OLD DETAILS TO HISTORY before any changes
        -- ============================================================
        INSERT INTO SPO_OrderDetailsHistory
        (
            OrderDetailId, OrderId, ItemCode, ItemName, Price, Qty,
            Discount, TotalAmount, ItemRemark, CreatedDate, DiscountType,
            IsDiscount, IsDiscountApprove, DiscountStatus,
            ItemSeq, SortSeq, RefItemCode
        )
        SELECT
            OrderDetailId, OrderId, ItemCode, ItemName, Price, Qty,
            Discount, TotalAmount, ItemRemark, CreatedDate, DiscountType,
            IsDiscount, IsDiscountApprove, DiscountStatus,
            ItemSeq, SortSeq, RefItemCode
        FROM SPO_OrderDetails
        WHERE OrderId = @OrderId;
        -- ============================================================

        -- Capture old data for transaction log
        SET @OldData = 
        (
            SELECT *,
            (
                SELECT * FROM SPO_OrderDetails
                WHERE OrderId = @OrderId
                FOR JSON PATH
            ) AS DetailData
            FROM SPO_OrderHeader
            WHERE OrderId = @OrderId
            FOR JSON PATH
        );

        -- Update Order Header
        UPDATE SPO_OrderHeader SET
            OrderTypeId           = @OrderTypeId,
            DeliveryDate          = @DeliveryDate,
            DeliveryTime          = @DeliveryTime,
            DeliveryOutlet        = @DeliveryOutlet,
            Status                = 'P',
            Discount              = @Discount,
            OrderRemark           = @OrderRemark,
            TotalAmount           = @TotalAmount,
            NetAmount             = @TotalAmount,
            ModifiedDate          = GETDATE(),
            ModifiedBy            = @ModifiedBy,
            TotalBillDiscountJSON = @TotalBillDiscountJSON,
            AmendCount            = @AmendCount,
            IsAmend               = @IsAmend,
            LastAmendUser         = @ModifiedBy,
            LastAmendDate         = GETDATE(),
            IsApprove             = 0,
            IsItemWiseDiscount    = @IsItemWiseDiscount   -- ← [CHANGE 4] Update flag
        WHERE OrderId = @OrderId;

        -- ============================================================
        -- [CHANGE 5] DELETE old details — then re-insert like Save SP
        -- ============================================================
        DELETE FROM SPO_OrderDetails WHERE OrderId = @OrderId;
        -- ============================================================

        -- ============================================================
        -- [CHANGE 6] Extract TotalBillDiscountTypeId
        -- ============================================================
        DECLARE @TotalBillDiscountTypeId INT = 0;
        IF (@TotalBillDiscountJSON IS NOT NULL AND ISJSON(@TotalBillDiscountJSON) = 1)
        BEGIN
            SELECT @TotalBillDiscountTypeId = ISNULL(
                CAST(JSON_VALUE(@TotalBillDiscountJSON, '$.DiscountTypeId') AS INT), 0
            );
        END
        -- ============================================================

        -- ============================================================
        -- [CHANGE 7] Parse new order details into temp table
        --            exactly like Save SP
        -- ============================================================
        CREATE TABLE #OrderDetailsTemp
        (
            RowNum              INT IDENTITY(1,1),
            ItemCode            VARCHAR(50),
            ItemName            VARCHAR(100),
            Price               DECIMAL(18,2),
            Qty                 INT,
            Discount            DECIMAL(18,2),
            TotalAmount         DECIMAL(18,2),
            ItemRemark          VARCHAR(500),
            DiscountType        INT,
            HeaderDiscountShare DECIMAL(18,2) DEFAULT 0,
            SetMenuSubItemsJSON NVARCHAR(MAX)
        );

        INSERT INTO #OrderDetailsTemp
        (
            ItemCode, ItemName, Price, Qty, Discount,
            TotalAmount, ItemRemark, DiscountType, SetMenuSubItemsJSON
        )
        SELECT
            ItemCode, ItemName, Price, Qty, Discount,
            TotalAmount, ItemRemark, DiscountType, SetMenuSubItems
        FROM OPENJSON(@OrderDetailsJSON)
        WITH (
            ItemCode        VARCHAR(50)      '$.ItemCode',
            ItemName        VARCHAR(100)     '$.ItemName',
            Price           DECIMAL(18,2)    '$.Price',
            Qty             INT              '$.Qty',
            Discount        DECIMAL(18,2)    '$.Discount',
            TotalAmount     DECIMAL(18,2)    '$.TotalAmount',
            ItemRemark      VARCHAR(500)     '$.ItemRemark',
            DiscountType    INT              '$.DiscountType',
            SetMenuSubItems NVARCHAR(MAX)    '$.SetMenuSubItems' AS JSON
        );
        -- ============================================================

        -- ============================================================
        -- [CHANGE 8] Distribute header discount proportionally
        --            exactly like Save SP
        -- ============================================================
        IF (@Discount > 0 AND @IsItemWiseDiscount = 0)
        BEGIN
            DECLARE @SubTotal       DECIMAL(18,4);
            DECLARE @AllocatedSoFar DECIMAL(18,2);
            DECLARE @LastRowNum     INT;

            SELECT
                @SubTotal  = SUM(TotalAmount)
            FROM #OrderDetailsTemp;

            UPDATE #OrderDetailsTemp
            SET HeaderDiscountShare =
                CASE
                    WHEN @SubTotal = 0 THEN 0
                    ELSE FLOOR((@Discount / @SubTotal * TotalAmount) * 100) / 100
                END;

            SELECT @AllocatedSoFar = SUM(HeaderDiscountShare) FROM #OrderDetailsTemp;
            SELECT @LastRowNum     = MAX(RowNum)               FROM #OrderDetailsTemp;

            UPDATE #OrderDetailsTemp
            SET HeaderDiscountShare = HeaderDiscountShare + (@Discount - @AllocatedSoFar)
            WHERE RowNum = @LastRowNum;
        END
        -- ============================================================

        -- ============================================================
        -- [CHANGE 9] Build final rows including set menu sub-items
        --            exactly like Save SP
        -- ============================================================
        CREATE TABLE #AllOrderRows
        (
            ItemSeq             INT,
            SortSeq             INT,
            ItemCode            VARCHAR(50),
            ItemName            VARCHAR(255),
            Price               DECIMAL(18,2),
            Qty                 INT,
            Discount            DECIMAL(18,2),
            TotalAmount         DECIMAL(18,2),
            ItemRemark          VARCHAR(500),
            DiscountType        INT,
            IsDiscount          BIT,
            DiscountStatus      CHAR(1),
            RefItemCode         VARCHAR(50),
            HeaderDiscountShare DECIMAL(18,2)
        );

        -- Parent / standalone items
        INSERT INTO #AllOrderRows
        SELECT
            RowNum, RowNum,
            ItemCode, ItemName, Price, Qty, Discount, TotalAmount, ItemRemark, DiscountType,
            CASE
                WHEN @IsItemWiseDiscount = 1 AND Discount > 0            THEN 1
                WHEN @IsItemWiseDiscount = 0 AND HeaderDiscountShare > 0 THEN 1
                ELSE 0
            END,
            CASE
                WHEN @IsItemWiseDiscount = 1 AND Discount > 0            THEN 'P'
                WHEN @IsItemWiseDiscount = 0 AND HeaderDiscountShare > 0 THEN 'P'
                ELSE 'N'
            END,
            ItemCode,
            HeaderDiscountShare
        FROM #OrderDetailsTemp;

        -- Set menu sub-items
        INSERT INTO #AllOrderRows
        SELECT
            parent.RowNum,
            parent.RowNum * 1000 + sub.SubRowNum,
            sub.ItemCode, sub.ItemName,
            ISNULL(sub.AddRate, 0), 1, 0, ISNULL(sub.AddRate, 0),
            NULL, 0, 0, 'N',
            parent.ItemCode,
            0
        FROM #OrderDetailsTemp AS parent
        CROSS APPLY (
            SELECT
                JSON_VALUE(s.value, '$.ItemCode')                                   AS ItemCode,
                JSON_VALUE(s.value, '$.ItemName')                                   AS ItemName,
                CAST(ISNULL(JSON_VALUE(s.value, '$.AddRate'), 0) AS DECIMAL(18,2))  AS AddRate,
                CAST(s.[key] AS INT) + 1                                            AS SubRowNum
            FROM OPENJSON(parent.SetMenuSubItemsJSON) AS s
        ) AS sub
        WHERE parent.SetMenuSubItemsJSON IS NOT NULL
          AND ISJSON(parent.SetMenuSubItemsJSON) = 1
          AND LEN(parent.SetMenuSubItemsJSON) > 2;
        -- ============================================================

        -- ============================================================
        -- [CHANGE 10] Insert new details exactly like Save SP
        -- ============================================================
        INSERT INTO SPO_OrderDetails
        (
            OrderId, ItemCode, ItemName, Price, Qty,
            Discount, TotalAmount, ItemRemark, CreatedDate,
            DiscountType, IsDiscount, IsDiscountApprove, DiscountStatus,
            ItemSeq, SortSeq, RefItemCode
        )
        SELECT
            @OrderId,
            ItemCode, ItemName, Price, Qty,
            CASE
                WHEN @IsItemWiseDiscount = 1 THEN Discount
                ELSE Discount + HeaderDiscountShare
            END,
            TotalAmount, ItemRemark, GETDATE(),
            CASE
                WHEN @IsItemWiseDiscount = 1 THEN DiscountType
                ELSE @TotalBillDiscountTypeId
            END,
            IsDiscount, 0, DiscountStatus,
            ItemSeq,
            ROW_NUMBER() OVER (PARTITION BY ItemSeq ORDER BY SortSeq),
            RefItemCode
        FROM #AllOrderRows;

        DROP TABLE #AllOrderRows;
        DROP TABLE #OrderDetailsTemp;
        -- ============================================================

        -- Capture new data for transaction log
        SET @NewData =
        (
            SELECT *,
            (
                SELECT * FROM SPO_OrderDetails
                WHERE OrderId = @OrderId
                FOR JSON PATH
            ) AS DetailData
            FROM SPO_OrderHeader
            WHERE OrderId = @OrderId
            FOR JSON PATH
        );

        -- Insert Transaction Log
        INSERT INTO [dbo].[SPO_TransactionLog]
        (
            [TransactionType], [LogData], [TransactionID], [Reference1]
        )
        VALUES
        (
            'Order',
            (SELECT @OldData AS OldData, @NewData AS NewData FOR JSON PATH),
            @OrderId,
            'Order Amend'
        );

        -- Discount Approval
        DECLARE @DetailDiscount DECIMAL(18,2) = 0;
        SELECT @DetailDiscount = ISNULL(
            SUM(CAST(JSON_VALUE(value, '$.Discount') AS DECIMAL(18,2))), 0
        )
        FROM OPENJSON(@OrderDetailsJSON);

        DECLARE @TotalDiscount DECIMAL(18,2) = ISNULL(@Discount, 0) + ISNULL(@DetailDiscount, 0);

        IF (@TotalDiscount > 0)
        BEGIN
            DECLARE @DiscountApprovalJson NVARCHAR(MAX);
            SET @DiscountApprovalJson =
            (
                SELECT
                    JSON_QUERY((
                        SELECT
                            @ModifiedBy     AS UserID,
                            @PropertyId     AS PropertyID,
                            @DeliveryOutlet AS LocationID
                        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                    )) AS spParam,
                    3 AS TransactionTypeID,
                    @OrderId AS TransactionHeadereID
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );
            EXEC dbo.SPO_SP_InsertTransactionApprovalLog @DiscountApprovalJson;
        END

        -- Order Approval
        DECLARE @IsOrderApproval BIT = 0;
        SELECT @IsOrderApproval = IsOrderApproval
        FROM [dbo].[SPO_OrderType]
        WHERE ID = @OrderTypeId;

        IF (@IsOrderApproval = 1)
        BEGIN
            DECLARE @OrderApprovalJson NVARCHAR(MAX);
            SET @OrderApprovalJson =
            (
                SELECT
                    JSON_QUERY((
                        SELECT
                            @ModifiedBy     AS UserID,
                            @PropertyId     AS PropertyID,
                            @DeliveryOutlet AS LocationID
                        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                    )) AS spParam,
                    2 AS TransactionTypeID,
                    @OrderId AS TransactionHeadereID
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );
            EXEC dbo.SPO_SP_InsertTransactionApprovalLog @OrderApprovalJson;
        END

        COMMIT TRANSACTION;

        SELECT 1 AS Result;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        IF OBJECT_ID('tempdb..#AllOrderRows') IS NOT NULL
            DROP TABLE #AllOrderRows;
        IF OBJECT_ID('tempdb..#OrderDetailsTemp') IS NOT NULL
            DROP TABLE #OrderDetailsTemp;

        DECLARE @ErrorMessage  NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT            = ERROR_SEVERITY();
        DECLARE @ErrorState    INT            = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

GO

