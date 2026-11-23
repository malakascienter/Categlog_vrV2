
CREATE PROCEDURE [dbo].[SPO_SaveOrderWithDetails]
    @CustomerId INT,
    @MobileNo VARCHAR(20),
    @OrderTypeId INT,
    @DeliveryDate DATE,
    @DeliveryTime TIME,
    @DeliveryOutlet VARCHAR(100),
    @Discount DECIMAL(18,2),
    @OrderRemark VARCHAR(500),
    @TotalAmount DECIMAL(18,2),
    @CreatedBy INT,
    @PropertyId INT,
    @OrderDetailsJSON NVARCHAR(MAX),
    @TotalBillDiscountJSON NVARCHAR(MAX) = NULL,
    @TempOrderDetail NVARCHAR(MAX) = NULL,
    @OrderId INT OUTPUT,
    @OrderOutlet VARCHAR(50),
    @IsItemWiseDiscount BIT = 0        
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogID INT,
    @DocNo NVARCHAR(300),
    @TransactionType VARCHAR(5) = 'OA'

    --- Insert Log ----
    INSERT INTO [dbo].[SPO_TransactionLog]
           ([TransactionType],[LogData])
     VALUES
           ('Order', @TempOrderDetail)

    SET @LogID = SCOPE_IDENTITY();

    BEGIN TRY
        BEGIN TRANSACTION;

        ----Get Doc No ----
        SELECT @DocNo = [dbo].[FN_SPO_GetNextDocumentNumber](@PropertyID, @DeliveryOutlet, @TransactionType) 
        IF (@DocNo IS NULL)
        BEGIN
            EXEC SPO_InsertDocumentNumber @PropertyID, @DeliveryOutlet, @TransactionType
            SELECT @DocNo = [dbo].[FN_SPO_GetNextDocumentNumber](@PropertyID, @DeliveryOutlet, @TransactionType) 
        END

        SET @DocNo = CONCAT(TRIM(@TransactionType), '/', @DeliveryOutlet, '/', @DocNo)

        -- Insert Order Header
        INSERT INTO SPO_OrderHeader 
        (
            CustomerId, MobileNo, OrderTypeId, DeliveryDate, DeliveryTime, 
            DeliveryOutlet, Discount, OrderRemark, TotalAmount, CreatedDate, 
            CreatedBy, PropertyId, Status, TotalBillDiscountJSON, InvoiceNo,
            OrderOutlet, NetAmount, IsItemWiseDiscount        
        )
        VALUES 
        (
            @CustomerId, @MobileNo, @OrderTypeId, @DeliveryDate, @DeliveryTime, 
            @DeliveryOutlet, 0, @OrderRemark, @TotalAmount, GETDATE(), 
            @CreatedBy, @PropertyId, 'P', @TotalBillDiscountJSON, @DocNo,
            @OrderOutlet, @TotalAmount, @IsItemWiseDiscount      
        );

        SET @OrderId = SCOPE_IDENTITY();

        -- ← PLACE 1: Extract DiscountTypeId from TotalBillDiscountJSON
        DECLARE @TotalBillDiscountTypeId INT = 0;
        IF (@TotalBillDiscountJSON IS NOT NULL AND ISJSON(@TotalBillDiscountJSON) = 1)
        BEGIN
            SELECT @TotalBillDiscountTypeId = ISNULL(
                CAST(JSON_VALUE(@TotalBillDiscountJSON, '$.DiscountTypeId') AS INT), 0
            );
        END
        -- ─────────────────────────────────────────────────────────────

        -- Step 1: Parse JSON into temp table
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
            TotalAmount, ItemRemark, DiscountType,SetMenuSubItemsJSON
        )
        SELECT
            ItemCode, ItemName, Price, Qty, Discount,
            TotalAmount, ItemRemark, DiscountType,SetMenuSubItems
        FROM OPENJSON(@OrderDetailsJSON)
        WITH (
            ItemCode     VARCHAR(50)      '$.ItemCode',     
            ItemName     VARCHAR(100)     '$.ItemName',     
            Price        DECIMAL(18,2)    '$.Price',        
            Qty          INT              '$.Qty',           
            Discount     DECIMAL(18,2)    '$.Discount',     
            TotalAmount  DECIMAL(18,2)    '$.TotalAmount',  
            ItemRemark   VARCHAR(500)     '$.ItemRemark',   
            DiscountType INT              '$.DiscountType',
            SetMenuSubItems NVARCHAR(MAX) '$.SetMenuSubItems' AS JSON
        );

        IF (@Discount > 0 AND @IsItemWiseDiscount = 0)  
        BEGIN
            DECLARE @SubTotal       DECIMAL(18,4);
            DECLARE @TotalRows      INT;
            DECLARE @AllocatedSoFar DECIMAL(18,2);
            DECLARE @LastRowNum     INT;

            SELECT 
                @SubTotal  = SUM(TotalAmount),
                @TotalRows = COUNT(*)
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
                JSON_VALUE(s.value, '$.ItemCode')                               AS ItemCode,
                JSON_VALUE(s.value, '$.ItemName')                               AS ItemName,
                CAST(ISNULL(JSON_VALUE(s.value, '$.AddRate'), 0) AS DECIMAL(18,2)) AS AddRate,
                CAST(s.[key] AS INT) + 1                                        AS SubRowNum
            FROM OPENJSON(parent.SetMenuSubItemsJSON) AS s
        ) AS sub
        WHERE parent.SetMenuSubItemsJSON IS NOT NULL
          AND ISJSON(parent.SetMenuSubItemsJSON) = 1
          AND LEN(parent.SetMenuSubItemsJSON) > 2;

        -- Step 4: Insert into SPO_OrderDetails
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

        ---- Update Log ----
        UPDATE SPO_TransactionLog
        SET TransactionID = @OrderId
        WHERE Id = @LogID;

        EXEC [dbo].[SPO_UpdateDocumentNumber] @PropertyID, @DeliveryOutlet, @TransactionType;


        -- Discount Approval
        DECLARE @DetailDiscount DECIMAL(18,2) = 0;
        SELECT @DetailDiscount = ISNULL(SUM(CAST(JSON_VALUE(value, '$.Discount') AS DECIMAL(18,2))), 0)
        FROM OPENJSON(@OrderDetailsJSON);

        DECLARE @TotalDiscount DECIMAL(18,2) = ISNULL(@Discount, 0) + ISNULL(@DetailDiscount, 0);

        IF (@TotalDiscount > 0)
        BEGIN
            --DECLARE @DiscountTransactionID INT;
            --SELECT @DiscountTransactionID = TransactionID
            --FROM SPO_CommonTransactionColumnConfiguration
            --WHERE Id = 3;

            IF EXISTS (
                SELECT 1
                FROM SPO_UserWiseApproveLevels
                WHERE TransactionTypeID = 3
                  AND PropertyId = @PropertyId
                  AND LocationId = @OrderOutlet
            )
            BEGIN
                DECLARE @DiscountApprovalJson NVARCHAR(MAX);
                SET @DiscountApprovalJson =
                (
                    SELECT
                        JSON_QUERY((
                            SELECT
                                @CreatedBy      AS UserID,
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
            ELSE
            BEGIN
                UPDATE SPO_OrderDetails
                SET IsDiscountApprove = 1,
                    DiscountStatus    = 'C'
                WHERE OrderId = @OrderId
                  AND ISNULL(Discount, 0) > 0;

                UPDATE SPO_OrderHeader
                SET Discount  = ISNULL((
                        SELECT  SUM(ISNULL(Discount, 0))
                        FROM    SPO_OrderDetails
                        WHERE   OrderId = @OrderId AND IsDiscountApprove = 1
                    ), 0),
                    NetAmount = TotalAmount - ISNULL((
                        SELECT SUM(ISNULL(Discount, 0))
                        FROM SPO_OrderDetails
                        WHERE OrderId = @OrderId
                          AND IsDiscountApprove = 1
                    ), 0)
                WHERE OrderId = @OrderId;
            END
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
                            @CreatedBy      AS UserID,
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
        ELSE
        BEGIN
        UPDATE SPO_OrderHeader
            SET Status = 'C',
            IsApprove =1
        WHERE OrderId = @OrderId;
        IF EXISTS (
                SELECT 1 FROM [dbo].[SPO_OrderHeader]
                WHERE OrderId = @OrderId
                  AND Status  = 'C'
            )
            BEGIN
                EXEC [dbo].[SPO_MakeRequestForThisOrder]
                    @OrderId       = @OrderId,
                    @UserProfileID = @CreatedBy;
            END
        END

        COMMIT TRANSACTION;
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

