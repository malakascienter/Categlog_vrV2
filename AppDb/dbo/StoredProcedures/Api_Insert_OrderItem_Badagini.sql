
CREATE   PROCEDURE [dbo].[Api_Insert_OrderItem_Badagini]
    @itemOrderDetailJson NVARCHAR(MAX),
    @PropertyId INT,
    @Outlet NVARCHAR(50),
    @OrderType NVARCHAR(50),
    @EventDetail NVARCHAR(100),
    @AggregatorId INT,
    @ChannelCode NVARCHAR(50),
    @OutsideOrderId NVARCHAR(50),
    @EventType NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

	 INSERT INTO [dbo].[BadaginiOrderLog]
            ([itemOrderDetailJson],
             [PropertyId],
             [Outlet],
             [OrderType],
             [EventDetail],
             [AggregatorId],
             [ChannelCode],
             [SysDate])
        VALUES
            (@itemOrderDetailJson,
             @PropertyId,
             @Outlet,
             @OrderType,
             @EventDetail,
             @AggregatorId,
             @ChannelCode,
             GETDATE());

    BEGIN TRY

       SET @OrderType = 'R'

        BEGIN TRANSACTION;

        CREATE TABLE #TempOrderDetails
        (
            shop_id NVARCHAR(100),
            shop_name NVARCHAR(100),
            order_number NVARCHAR(50),
            order_type NVARCHAR(50),
            table_number INT,
            total_cents INT,
            created_at DATETIMEOFFSET
        );

        CREATE TABLE #TempItemDetails
        (
            order_number NVARCHAR(50),
            name NVARCHAR(100),
            quantity INT,
            price_cents INT,
            pos_product_id NVARCHAR(50),
            special_instructions NVARCHAR(500)
        );


        CREATE TABLE #TempChosenOptions
        (
            order_number NVARCHAR(50),
            item_name NVARCHAR(100),
            modifier_pos_id NVARCHAR(50),
            option_pos_id NVARCHAR(50),
            modifier_name NVARCHAR(100),
            option_name NVARCHAR(100),
            option_price_cents INT
        );

        INSERT INTO #TempOrderDetails (shop_id, shop_name, order_number, order_type, table_number, total_cents, created_at)
        SELECT 
            JSON_VALUE(@itemOrderDetailJson, '$.shop_id'),
            JSON_VALUE(@itemOrderDetailJson, '$.shop_name'),
            JSON_VALUE(@itemOrderDetailJson, '$.order_number'),
            JSON_VALUE(@itemOrderDetailJson, '$.order_type'),
            JSON_VALUE(@itemOrderDetailJson, '$.table_number'),
            JSON_VALUE(@itemOrderDetailJson, '$.total_cents'),
            CAST(JSON_VALUE(@itemOrderDetailJson, '$.created_at') AS DATETIMEOFFSET);


		IF EXISTS( SELECT 1 FROM POS_OutsideOrders O INNER JOIN #TempOrderDetails TTO ON O.OutsideOrderId = TTO.order_number )
		BEGIN

		IF OBJECT_ID('tempdb..#TempOrderDetails') IS NOT NULL
        DROP TABLE #TempOrderDetails;

        IF OBJECT_ID('tempdb..#TempItemDetails') IS NOT NULL
        DROP TABLE #TempItemDetails;

        IF OBJECT_ID('tempdb..#TempChosenOptions') IS NOT NULL
        DROP TABLE #TempChosenOptions;


		   RETURN
		END


        INSERT INTO #TempItemDetails
        (
            order_number,
            name,
            quantity,
            price_cents,
            pos_product_id,
            special_instructions
        )
        SELECT 
            JSON_VALUE(@itemOrderDetailJson, '$.order_number'),
            JSON_VALUE(Item.value, '$.name'),
            JSON_VALUE(Item.value, '$.quantity'),
            JSON_VALUE(Item.value, '$.price_cents'),
            JSON_VALUE(Item.value, '$.pos_product_id'),
            JSON_VALUE(Item.value, '$.special_instructions')
        FROM OPENJSON(@itemOrderDetailJson, '$.items') AS Item;


        INSERT INTO #TempChosenOptions
        (
            order_number,
            item_name,
            modifier_pos_id,
            option_pos_id,
            modifier_name,
            option_name,
            option_price_cents
        )
        SELECT
            JSON_VALUE(@itemOrderDetailJson, '$.order_number'),
            JSON_VALUE(Item.value, '$.name'),
            JSON_VALUE(Opt.value, '$.modifier_pos_id'),
            JSON_VALUE(Opt.value, '$.option_pos_id'),
            JSON_VALUE(Opt.value, '$.modifier_name'),
            JSON_VALUE(Opt.value, '$.option_name'),
            JSON_VALUE(Opt.value, '$.option_price_cents')
        FROM OPENJSON(@itemOrderDetailJson, '$.items') AS Item
        CROSS APPLY OPENJSON(Item.value, '$.chosen_options') AS Opt;

        -- Insert Main Items
        ;WITH MainItems AS
        (
            SELECT *,
                   ROW_NUMBER() OVER (ORDER BY i.name) AS ItemSequenceGlobal
            FROM #TempItemDetails i
        )
        INSERT INTO POS_OutsideOrders
        (
            PropertyId, OutletID, OutsideOrderNo, OrderType, OrderDateTime,
            MenuItemID, Name, Quantity, Rate, RefItemID, ActionID, IsModifier,
            IsInstruction, Remarks, ItemSequence, SortSeq, OutsideOrderId,
            AggregatorId, ChannelCode, RefOrderNo, DiscountValue, DiscountPercentage
        )
        SELECT
            @PropertyId,
            @Outlet,
            @OutsideOrderId,
            @OrderType,
            o.created_at,
            i.pos_product_id,
            i.name,
            i.quantity,
            CAST(i.price_cents AS NUMERIC(18,8)) / 100 AS Rate,
            i.pos_product_id AS RefItemID,
            0 AS ActionID,
            0 AS IsModifier,
            CASE WHEN i.special_instructions IS NOT NULL AND i.special_instructions <> '' THEN 1 ELSE 0 END,
            i.special_instructions,
            i.ItemSequenceGlobal,
            1 AS SortSeq,       
            i.order_number,
            @AggregatorId,
            @ChannelCode,
            @OutsideOrderId,
            0,
            0
        FROM MainItems i
        INNER JOIN #TempOrderDetails o ON i.order_number = o.order_number;

        -- Insert Modifiers
        ;WITH MainItems AS
        (
            SELECT *,
                   ROW_NUMBER() OVER (ORDER BY i.name) AS ItemSequenceGlobal
            FROM #TempItemDetails i
        )
        INSERT INTO POS_OutsideOrders
        (
            PropertyId, OutletID, OutsideOrderNo, OrderType, OrderDateTime,
            MenuItemID, Name, Quantity, Rate, RefItemID, ActionID, IsModifier,
            IsInstruction, Remarks, ItemSequence, SortSeq, OutsideOrderId,
            AggregatorId, ChannelCode, RefOrderNo, DiscountValue, DiscountPercentage
        )
        SELECT
            @PropertyId,
            @Outlet,
            @OutsideOrderId,
            @OrderType,
            o.created_at,
            REPLACE(c.option_pos_id, 'OPT_', '') AS MenuItemID,
            c.option_name AS Name,
            1 AS Quantity,
            CAST(c.option_price_cents AS NUMERIC(18,8)) / 100 AS Rate,
            i.pos_product_id AS RefItemID,         
            ISNULL(TRY_CAST(c.option_pos_id AS INT), 0) AS ActionID,
            1 AS IsModifier,
            0 AS IsInstruction,
            0 AS Remarks,
            i.ItemSequenceGlobal,                  
            ROW_NUMBER() OVER (PARTITION BY i.ItemSequenceGlobal ORDER BY c.modifier_pos_id) + 1 AS SortSeq, 
            i.order_number,
            @AggregatorId,
            @ChannelCode,
            @OutsideOrderId,
            0,
            0
        FROM #TempChosenOptions c
        INNER JOIN MainItems i
            ON c.order_number = i.order_number
           AND c.item_name = i.name
        INNER JOIN #TempOrderDetails o
            ON i.order_number = o.order_number;

        --SELECT * FROM BadaginiOrderLog
        --SELECT * FROM #TempOrderDetails;
        --SELECT * FROM #TempItemDetails;
        --SELECT * FROM #TempChosenOptions;
        --SELECT * FROM POS_OutsideOrders;

        IF OBJECT_ID('tempdb..#TempOrderDetails') IS NOT NULL
        DROP TABLE #TempOrderDetails;

        IF OBJECT_ID('tempdb..#TempItemDetails') IS NOT NULL
        DROP TABLE #TempItemDetails;

        IF OBJECT_ID('tempdb..#TempChosenOptions') IS NOT NULL
        DROP TABLE #TempChosenOptions;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

GO

