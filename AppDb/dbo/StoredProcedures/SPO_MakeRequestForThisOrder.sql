-- =============================================
-- Author:      Ravindu
-- Create date: 2026-04-03
-- Description: Special Orders Production.
-- =============================================
-- EXEC [dbo].[SPO_MakeRequestForThisOrder] 2098,4168
CREATE     PROCEDURE [dbo].[SPO_MakeRequestForThisOrder]
(
    @OrderId BIGINT,
    @UserProfileID INT
)
AS
BEGIN
    BEGIN TRY

        -- Advance payment validation
        --DECLARE @TotalAmount               DECIMAL(18,2);
        --DECLARE @MinAdvancePercentage      DECIMAL(18,2);
        --DECLARE @RequiredAdvanceAmount     DECIMAL(18,2);
        --DECLARE @TotalPaid                 DECIMAL(18,2);

        --SELECT
        --    @TotalAmount          = OH.NetAmount,
        --    @MinAdvancePercentage = OT.MiniumAdvancePercentage
        --FROM SPO_OrderHeader OH
        --INNER JOIN SPO_OrderType OT
        --    ON OT.ID = OH.OrderTypeId
        --   AND OT.PropertyId = OH.PropertyId
        --WHERE OH.OrderId = @OrderId;


        --SET @TotalPaid = dbo.fn_SPO_GetPaidAmount(@OrderId);

        --SET @RequiredAdvanceAmount = (@TotalAmount * @MinAdvancePercentage) / 100;

        --IF @TotalPaid < @RequiredAdvanceAmount
        --BEGIN
        --    ROLLBACK TRANSACTION;
        --    RETURN;
        --END

        -- Insert transfer request

        SELECT
            OH.InvoiceNo,
            OH.OrderOutlet,
            LR.StockLocationId               AS LocationID,
            C.SPOProductionLocation          AS SPOProductionLocation,
            CONVERT(DATE, OH.CreatedDate)    AS RequestDate,
            OH.DeliveryDate                  AS DeliveryDate,
            M.StockItemId,
            SD.MasterUnitID,
            CONVERT(DECIMAL(18, 4), OD.Qty)  AS RequestedQuantity,
            SD.AveragePrice,
            OH.PropertyId                    AS PropertyId
        INTO #TempTR
        FROM SPO_OrderHeader OH
            INNER JOIN SPO_OrderDetails OD
                ON OH.OrderId = OD.OrderId
            INNER JOIN Mainmenu M
                ON M.Itemcode = OD.ItemCode
            INNER JOIN StockItemHeaders SM
                ON SM.Id = M.StockItemId
            INNER JOIN StockItemDetails SD
                ON SM.Id = SD.StockItemHeaderID
            INNER JOIN Location_Ref LR
                ON OH.DeliveryOutlet = LR.code
            INNER JOIN Companies C
                ON C.CompanyID = OH.PropertyId
        WHERE
            OH.OrderId = @OrderId
        GROUP BY
            OH.InvoiceNo,
            OH.OrderOutlet,
            LR.StockLocationId,
            C.SPOProductionLocation,
            CONVERT(DATE, OH.CreatedDate),
            OH.DeliveryDate,
            M.StockItemId,
            SD.MasterUnitID,
            OD.Qty,
            SD.AveragePrice,
            OH.PropertyId;

            SELECT * INTO #TempTR2 FROM #TempTR;
            select * from #TempTR
            

            -- =============================================
            -- Validate each item mapping in StockItemDetails
            -- =============================================
            DECLARE @ValidateStockItemId    INT;
            DECLARE @ValidateLocationID     INT;
            DECLARE @ValidateTransferLoc    INT;
            DECLARE @ValidatePropertyID     INT;
            DECLARE @ValidateInvoiceNo      NVARCHAR(MAX);
            DECLARE @ValidationError        NVARCHAR(500);

            DECLARE @ValidateItemName       NVARCHAR(MAX);
            DECLARE @ValidateLocationName   NVARCHAR(MAX);
            DECLARE @ValidateTransferLocName NVARCHAR(MAX);

            WHILE EXISTS (SELECT 1 FROM #TempTR2)
            BEGIN
                SELECT TOP (1)
                    @ValidateStockItemId  = StockItemId,
                    @ValidateLocationID   = LocationID,
                    @ValidateTransferLoc  = SPOProductionLocation,
                    @ValidatePropertyID   = PropertyId,
                    @ValidateInvoiceNo    = InvoiceNo
                FROM #TempTR2;

                SELECT @ValidateItemName = Name
                FROM StockItemHeaders
                WHERE Id = @ValidateStockItemId;

                SELECT @ValidateLocationName = description
                FROM Location_Ref
                WHERE StockLocationId = @ValidateLocationID;

                SELECT @ValidateTransferLocName = Name
                FROM Locations
                WHERE Id = @ValidateTransferLoc;

                -- Check item exists in StockItemDetails for Delivery Location
                IF NOT EXISTS (
                    SELECT 1 FROM StockItemDetails
                    WHERE StockItemHeaderID = @ValidateStockItemId
                      AND LocationID        = @ValidateLocationID
                      AND PropertyID        = @ValidatePropertyID
                      AND IsActive          = 1
                )
                BEGIN
                    SET @ValidationError = 
                    'Item "' + ISNULL(@ValidateItemName, 'Unknown') + '"' +
                    ' is not configured for Delivery Location "' + ISNULL(@ValidateLocationName, 'Unknown') + '"' +
                    ' (Invoice: ' + ISNULL(@ValidateInvoiceNo, 'N/A') + ')';
                    RAISERROR(@ValidationError, 16, 1);
                    RETURN;
                END

                -- Check item exists in StockItemDetails for Production Location
                IF NOT EXISTS (
                    SELECT 1 FROM StockItemDetails
                    WHERE StockItemHeaderID = @ValidateStockItemId
                      AND LocationID        = @ValidateTransferLoc
                      AND PropertyID        = @ValidatePropertyID
                      AND IsActive          = 1
                )
                BEGIN
                    SET @ValidationError = 
                    'Item "' + ISNULL(@ValidateItemName, 'Unknown') + '"' +
                    ' is not configured for Production Location "' + ISNULL(@ValidateTransferLocName, 'Unknown') + '"' +
                    ' (Invoice: ' + ISNULL(@ValidateInvoiceNo, 'N/A') + ')';

                    RAISERROR(@ValidationError, 16, 1);
                    RETURN;
                END

                -- Remove validated row and move to next
                DELETE TOP (1) FROM #TempTR2
                WHERE StockItemId          = @ValidateStockItemId
                  AND LocationID           = @ValidateLocationID
                  AND SPOProductionLocation = @ValidateTransferLoc;
            END

        WHILE EXISTS (SELECT 1 FROM #TempTR)
        BEGIN
            DECLARE @xmlOutput      XML;
            DECLARE @LocationID     INT;
            DECLARE @TransferLocation INT;
            DECLARE @PropertyID     INT;
            DECLARE @docID          VARCHAR(MAX);
            DECLARE @headerid       INT;

            SELECT TOP (1)
                @LocationID       = LocationID,
                @TransferLocation = SPOProductionLocation,
                @PropertyID       = PropertyId
            FROM #TempTR;

            -- Generate XML and store in @xmlOutput
            SELECT @xmlOutput =
            (
                SELECT TOP (1)
                    -1                                          AS [Id],
                    0                                           AS [Flag],
                    'false'                                     AS [Isprint],
                    @PropertyID                                 AS [PropertyID],
                    @TransferLocation                           AS [LocationID],
                    1                                           AS [DepartmentID],
                    @LocationID                                 AS [TransferLocation],
                    'RT'                                        AS [RequestType],
                    H.InvoiceNo                                 AS [DocumentNo],
                    CONVERT(DATETIME, H.RequestDate)            AS [RequestDate],
                    'P'                                         AS [DocumentStatus],
                    @UserProfileID                              AS [UserProfileID],
                    H.InvoiceNo                                 AS [JobNo],
                    'false'                                     AS [IsApproved],
                    'SPO'                                        AS [Remarks],
                    GETDATE()                                   AS [TimeStamp],
                    'TR'                                        AS [TransactionTypeCode],
                    CONVERT(DATETIME, H.DeliveryDate)           AS [DeliveryDate],
                    0                                           AS [JobID],
                    'false'                                     AS [Urgent],
                    (
                        SELECT
                            0                                   AS [Id],
                            0                                   AS [RequestHeaderID],
                            D.StockItemId                       AS [StockItemID],
                            D.MasterUnitID                      AS [UnitID],
                            D.RequestedQuantity                 AS [RequestedQuantity],
                            0                                   AS [IssuedQuantity],
                            0                                   AS [ApprovedQuantity],
                            GETDATE()                           AS [TimeStamp],
                            ISNULL(D.AveragePrice, 0)           AS [UnitPrice],
                            0                                   AS [InvAccountID],
                            '0001-01-01T00:00:00'               AS [ItemDeliveryDate]
                        FROM #TempTR D
                        WHERE
                            D.LocationID           = @LocationID
                            AND D.SPOProductionLocation = @TransferLocation
                        FOR XML PATH('RequestDetail'), TYPE
                    )                                           AS [DetailList]
                FROM #TempTR H
                WHERE
                    H.LocationID           = @LocationID
                    AND H.SPOProductionLocation = @TransferLocation
                FOR XML PATH('RequestHeader'), TYPE, ELEMENTS XSINIL
            );

            DELETE FROM #TempTR
            WHERE
                LocationID           = @LocationID
                AND SPOProductionLocation = @TransferLocation;

            SELECT @xmlOutput AS RequestXML;

            EXEC [SP_InsertRequest] @xmlOutput, @docID OUTPUT, @headerid OUTPUT;

        END

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg  NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSev  INT            = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSev, 1);
    END CATCH
END

GO

