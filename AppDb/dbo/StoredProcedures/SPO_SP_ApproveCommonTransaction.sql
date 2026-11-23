-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-08
-- Description:	Common transaction approval
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SP_ApproveCommonTransaction] 
	@JsonDetail NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	BEGIN TRY 
    BEGIN TRAN
        ---------------------------------------------
        -- 1. Parse JSON input
        ---------------------------------------------
        DECLARE 
            @UserID INT,
            @PropertyID INT,
            @TransactionTypeID INT,
            @TransactionID INT,
            @Action CHAR(1),
            @HeaderID INT;

        -- Extract top-level fields
        SELECT
            @TransactionTypeID = JSON_VALUE(@JsonDetail, '$.TransactionTypeID'),
            @Action            = JSON_VALUE(@JsonDetail, '$.action');

        SELECT @TransactionID = TransactionID 
        FROM
        SPO_CommonTransactionColumnConfiguration
        WHERE Id = @TransactionTypeID
        ---------------------------------------------
        -- 2. Parse spParam object
        ---------------------------------------------
        DECLARE @spParam NVARCHAR(MAX) = JSON_VALUE(@JsonDetail, '$.spParam');

        SELECT
            @UserID     = JSON_VALUE(@spParam, '$.UserID'),
            @PropertyID = JSON_VALUE(@spParam, '$.PropertyID');

        ---------------------------------------------
        -- 3. Parse headerData object
        ---------------------------------------------
        DECLARE @headerData NVARCHAR(MAX) = JSON_VALUE(@JsonDetail, '$.headerData');

        ---------------------------------------------
        -- 4. DetailData (optional)
        ---------------------------------------------
        DECLARE @detailData NVARCHAR(MAX) = JSON_VALUE(@JsonDetail, '$.detailData');
        SET @detailData = REPLACE(REPLACE(@detailData, '\\"', '"'), '\\\\', '\');
        SET @detailData = JSON_QUERY(@detailData);
        --IF @detailData IS NOT NULL AND @detailData <> '[]'
        --BEGIN
            
        --        SELECT *
        --        FROM OPENJSON(@detailData)
        --        WITH
        --        (
        --            DetailID INT '$.ID',
        --            Qty DECIMAL(18,2) '$.Qty',
        --            ItemID INT '$.ItemID',
        --            Remark NVARCHAR(500) '$.Remark'
        --        )
           
        -- END

        IF(@TransactionTypeID = 1) -- Customer Approval
        BEGIN
            SELECT  @HeaderID = JSON_VALUE(@headerData, '$.ID');

            --Insert Old Data--
            UPDATE TA
            SET TA.OldData = (
                SELECT * FROM
                SPO_Customer WHERE ID = @HeaderID
                FOR JSON PATH
            )
            FROM
            [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID
            AND TA.UserProfileID= @UserID
            -------------------
            
            UPDATE TA
            SET TA.IsApproved =1,
                TA.LastModifiedUserID = @UserID,
                TA.LastModifiedDate = GETDATE()
            FROM
            [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID
            AND TA.UserProfileID= @UserID

            IF NOT EXISTS(SELECT 1 FROM  [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID AND TA.IsApproved =0)
            BEGIN
                UPDATE TA
                SET TA.TransactionStatus = 'C'
                FROM
                [dbo].[SPO_TransactionApprovalLog] TA
                WHERE TA.TransactionTypeID = @TransactionID
                AND TA.TransactionHeaderID = @HeaderID

                UPDATE SPO_Customer
                SET 
                DocumentStatus = 'C'
                WHERE ID = @HeaderID
            END

            --Insert New Data--
            UPDATE TA
            SET TA.NewData = (
                SELECT * FROM
                SPO_Customer WHERE ID = @HeaderID
                FOR JSON PATH
            )
            FROM
            [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID
            AND TA.UserProfileID= @UserID
            -------------------

        END
        IF(@TransactionTypeID = 2) -- Discount Approval
            BEGIN

                ---------------------------------------------
                -- Get HeaderID
                ---------------------------------------------
                SELECT @HeaderID = JSON_VALUE(@headerData, '$.OrderId');

                ---------------------------------------------
                -- Ensure transaction log exists
                ---------------------------------------------
                IF NOT EXISTS(
                    SELECT 1 
                    FROM [dbo].[SPO_TransactionApprovalLog] 
                    WHERE TransactionTypeID = @TransactionID
                      AND TransactionHeaderID = @HeaderID
                      AND UserProfileID = @UserID
                )
                BEGIN
                    INSERT INTO [dbo].[SPO_TransactionApprovalLog]
                        (TransactionTypeID, TransactionHeaderID, UserProfileID, CreatedUserID, CreatedDate, TransactionStatus)
                    VALUES
                        (@TransactionID, @HeaderID, @UserID, @UserID, GETDATE(),'P');
                END


                ---------------------------------------------
                -- Save Old Data
                ---------------------------------------------
                UPDATE TA
                SET TA.OldData = (
                    SELECT 
                        (SELECT * FROM SPO_OrderHeader WHERE OrderId = @HeaderID FOR JSON PATH) AS HeaderData,
                        (SELECT * FROM SPO_OrderDetails WHERE OrderId = @HeaderID FOR JSON PATH) AS DetailData
                    FOR JSON PATH
                )
                FROM SPO_TransactionApprovalLog TA
                WHERE TA.TransactionTypeID = @TransactionID
                  AND TA.TransactionHeaderID = @HeaderID
                  AND TA.UserProfileID = @UserID;


                ---------------------------------------------
                -- USER LEVEL APPROVAL
                ---------------------------------------------
                DECLARE @CurrentLevel INT;
                DECLARE @LocationID NVARCHAR(10);

                SELECT @LocationID = OrderOutlet
                FROM SPO_OrderHeader
                WHERE OrderId = @HeaderID;

                SELECT TOP 1 @CurrentLevel = ApproveTypeID
                FROM SPO_UserWiseApproveLevels
                WHERE UserProfileId = @UserID
                  AND TransactionTypeID = @TransactionID
                  AND PropertyId = @PropertyID
                  AND LocationId = @LocationID;

                ---------------------------------------------
                -- Approve ALL users in same level
                ---------------------------------------------
                UPDATE TA
                SET TA.IsApproved = 1,
                    TA.TransactionStatus = 'C',
                    TA.LastModifiedUserID = @UserID,
                    TA.LastModifiedDate = GETDATE()
                FROM SPO_TransactionApprovalLog TA
                INNER JOIN SPO_UserWiseApproveLevels AUC
                    ON AUC.UserProfileId = TA.UserProfileID
                    AND AUC.TransactionTypeID = TA.TransactionTypeID
                    AND AUC.LocationId = TA.LocationID
                    AND AUC.PropertyId = @PropertyID
                WHERE TA.TransactionTypeID = @TransactionID
                  AND TA.TransactionHeaderID = @HeaderID
                  AND (
                        TA.UserProfileID = @UserID
                        OR AUC.ApproveTypeID = @CurrentLevel
                      );


                ---------------------------------------------
                -- CHECK ALL APPROVAL LEVELS COMPLETED
                ---------------------------------------------
                IF NOT EXISTS(
                    SELECT 1
                    FROM SPO_TransactionApprovalLog
                    WHERE TransactionTypeID = @TransactionID
                      AND TransactionHeaderID = @HeaderID
                      AND ISNULL(TransactionStatus,'P') <> 'C'
                )
                BEGIN

                    ---------------------------------------------
                    -- Approve Discounts (FINAL APPROVAL ONLY)
                    ---------------------------------------------
                    --DECLARE @HeaderIsDiscount BIT;
                    --SELECT @HeaderIsDiscount = CAST(JSON_VALUE(@headerData, '$.IsDiscount') AS BIT);

                    --IF @HeaderIsDiscount = 1
                    --BEGIN
                        UPDATE OD
                        SET OD.IsDiscountApprove = 1,
                            OD.DiscountStatus = 'C'
                        FROM SPO_OrderDetails OD
                        WHERE OD.OrderId = @HeaderID
                          AND ISNULL(OD.Discount,0) > 0;
                    --END


                    ---------------------------------------------
                    -- Update Header Discount
                    ---------------------------------------------
                    UPDATE OH
                    SET OH.Discount = ISNULL((
                            SELECT SUM(ISNULL(Discount,0))
                            FROM SPO_OrderDetails
                            WHERE OrderId = @HeaderID
                            AND IsDiscountApprove = 1
                        ),0),
                        OH.NetAmount = OH.TotalAmount -
                        ISNULL((
                            SELECT SUM(ISNULL(Discount,0))
                            FROM SPO_OrderDetails
                            WHERE OrderId = @HeaderID
                            AND IsDiscountApprove = 1
                        ),0)
                    FROM SPO_OrderHeader OH
                    WHERE OH.OrderId = @HeaderID;

                END


                ---------------------------------------------
                -- Save New Data
                ---------------------------------------------
                UPDATE TA
                SET TA.NewData = (
                    SELECT 
                        (SELECT * FROM SPO_OrderHeader WHERE OrderId = @HeaderID FOR JSON PATH) AS HeaderData,
                        (SELECT * FROM SPO_OrderDetails WHERE OrderId = @HeaderID FOR JSON PATH) AS DetailData
                    FOR JSON PATH
                )
                FROM SPO_TransactionApprovalLog TA
                WHERE TA.TransactionTypeID = @TransactionID
                  AND TA.TransactionHeaderID = @HeaderID
                  AND TA.UserProfileID = @UserID;

            END
        IF(@TransactionTypeID = 4) -- Order Cancelation Approval
        BEGIN
            SELECT  @HeaderID = JSON_VALUE(@headerData, '$.OrderId')
            
            --Insert Old Data--
            UPDATE TA
            SET TA.OldData = (
                SELECT (
                SELECT * FROM
                [dbo].[SPO_OrderHeader] WHERE OrderId = @HeaderID
                FOR JSON PATH
                ) AS HeaderData,
                 (
                SELECT * FROM
                [dbo].[SPO_OrderDetails] WHERE OrderId = @HeaderID
                FOR JSON PATH
                ) AS DetailData
                FOR JSON PATH
            )
            FROM
            [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID
            AND TA.UserProfileID= @UserID
            -------------------
            
            UPDATE TA
            SET TA.IsApproved =1,
                TA.LastModifiedUserID = @UserID,
                TA.LastModifiedDate = GETDATE()
            FROM
            [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID
            AND TA.UserProfileID= @UserID

            IF NOT EXISTS(SELECT 1 FROM  [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID AND TA.IsApproved =0)
            BEGIN
                UPDATE TA
                SET TA.TransactionStatus = 'C'
                FROM
                [dbo].[SPO_TransactionApprovalLog] TA
                WHERE TA.TransactionTypeID = @TransactionID
                AND TA.TransactionHeaderID = @HeaderID

                UPDATE [dbo].[SPO_OrderHeader]
                SET IsOrderCancel =1,
                OrderCancelStatus = 'C',
                IsApprove = 0,
                Status ='X'
                WHERE OrderId = @HeaderID
            END

            --Insert New Data--
            UPDATE TA
            SET TA.NewData = (
                SELECT (
                SELECT * FROM
                [dbo].[SPO_OrderHeader] WHERE OrderId = @HeaderID
                FOR JSON PATH
                ) AS HeaderData,
                 (
                SELECT * FROM
                [dbo].[SPO_OrderDetails] WHERE OrderId = @HeaderID
                FOR JSON PATH
                ) AS DetailData
                FOR JSON PATH
            )
            FROM
            [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID
            AND TA.UserProfileID= @UserID
            -------------------


           IF EXISTS (SELECT 1 FROM [dbo].[SPO_OrderWisePayment] WHERE OrderId = @HeaderID AND PropertyId = @PropertyID)
            BEGIN

                DECLARE @ReturnHeaderID BIGINT
                DECLARE @ReturnReason   VARCHAR(250)
                DECLARE @ReturnNo       VARCHAR(20)
                DECLARE @ReturnAmount NUMERIC

                SELECT @ReturnReason = JSON_VALUE(@spParam, '$.Remarks')

                -- Get return amount
                SET @ReturnAmount = dbo.fn_SPO_GetPaidAmount(@HeaderID)

                -- Generate ReturnNo
                SELECT @ReturnNo = RIGHT(REPLICATE('0',10) + LTRIM(ISNULL(MAX(CAST(ReturnNo AS BIGINT)),0) + 1), 10)
                FROM POS_OrderReturnHeader

                INSERT INTO [dbo].[POS_OrderReturnHeader]
                (
                    PropertyId,
                    ReturnNo,
                    BusinessDate,
                    InsertDateTime,
                    UserID,
                    Outlet,
                    ReturnAmount,
                    ReturnReason,
                    OrderNo,
                    OrderDate,
                    OrderOutlet
                )
                SELECT
                    @PropertyID,
                    @ReturnNo,
                    CAST(GETDATE() AS DATE),
                    GETDATE(),
                    CAST(@UserID AS VARCHAR(20)),
                    OH.DeliveryOutlet,
                    OH.RefundAmount,
                    @ReturnReason,
                    OH.OrderId,
                    CAST(OH.CreatedDate AS DATE),
                    OH.OrderOutlet
                FROM [dbo].[SPO_OrderHeader] OH
                WHERE OH.OrderId = @HeaderID AND OH.PropertyId = @PropertyID

                SET @ReturnHeaderID = SCOPE_IDENTITY()

                INSERT INTO [dbo].[POS_OrderReturnDetail]
                (
                    ReturnHeaderID,
                    PropertyId,
                    Outlet,
                    ReturnNo,
                    BusinessDate,
                    InsertDateTime,
                    MainMenuCode,
                    Quantity,
                    ReturnPrice
                )
                SELECT
                    @ReturnHeaderID,
                    @PropertyID,
                    OH.OrderOutlet,
                    @ReturnNo,
                    CAST(GETDATE() AS DATE),
                    GETDATE(),
                    OD.ItemCode,
                    OD.Qty,
                    OD.Price
                FROM [dbo].[SPO_OrderDetails] OD
                INNER JOIN [dbo].[SPO_OrderHeader] OH
                    ON OH.OrderId = OD.OrderId
                WHERE OD.OrderId = @HeaderID AND OH.PropertyId = @PropertyID
            END
        END
        IF(@TransactionTypeID = 5) -- Order Approval
            BEGIN
                SELECT  @HeaderID = JSON_VALUE(@headerData, '$.OrderId')
            
                --Insert Old Data--
                UPDATE TA
                SET TA.OldData = (
                    SELECT (
                    SELECT * FROM
                    [dbo].[SPO_OrderHeader] WHERE OrderId = @HeaderID
                    FOR JSON PATH
                    ) AS HeaderData,
                     (
                    SELECT * FROM
                    [dbo].[SPO_OrderDetails] WHERE OrderId = @HeaderID
                    FOR JSON PATH
                    ) AS DetailData
                    FOR JSON PATH
                )
                FROM
                [dbo].[SPO_TransactionApprovalLog] TA
                WHERE TA.TransactionTypeID = @TransactionID
                AND TA.TransactionHeaderID = @HeaderID
                AND TA.UserProfileID= @UserID
                -------------------
                -- Mark all users in the same ApprovalLevel as the current approving user as approved
                UPDATE TA
                SET TA.IsApproved = 1,
                    TA.LastModifiedUserID = @UserID,
                    TA.LastModifiedDate = GETDATE()
                FROM [dbo].[SPO_TransactionApprovalLog] TA
                INNER JOIN [dbo].[SPO_UserWiseApproveLevels] AUC 
                    ON AUC.UserProfileId = TA.UserProfileID
                    AND AUC.TransactionTypeID = @TransactionID
                    AND AUC.LocationId = TA.LocationID
                    AND AUC.PropertyId = @PropertyID
                WHERE TA.TransactionTypeID = @TransactionID
                AND TA.TransactionHeaderID = @HeaderID
                AND AUC.ApproveTypeID = (
                    SELECT TOP 1 ApproveTypeID 
                    FROM [dbo].[SPO_UserWiseApproveLevels]
                    WHERE UserProfileId = @UserID
                    AND TransactionTypeID = @TransactionID
                    AND PropertyId = @PropertyID
                    AND LocationId = TA.LocationID
                )

                -- =============================================
                -- CASE 1: Approval log EXISTS — check all done
                -- =============================================
                IF EXISTS (
                    SELECT 1 FROM [dbo].[SPO_TransactionApprovalLog]
                    WHERE TransactionTypeID = @TransactionID
                      AND TransactionHeaderID = @HeaderID
                )
                BEGIN
                    -- All approvers approved?
                    IF NOT EXISTS (
                        SELECT 1 FROM [dbo].[SPO_TransactionApprovalLog] TA
                        WHERE TA.TransactionTypeID = @TransactionID
                        AND TA.TransactionHeaderID = @HeaderID
                        AND TA.IsApproved = 0
                    )
                    BEGIN
                        -- Final approver done — complete order
                        UPDATE TA
                        SET TA.TransactionStatus = 'C'
                        FROM [dbo].[SPO_TransactionApprovalLog] TA
                        WHERE TA.TransactionTypeID = @TransactionID
                        AND TA.TransactionHeaderID = @HeaderID

                        UPDATE [dbo].[SPO_OrderHeader]
                        SET IsApprove = 1,
                            Status = 'C'
                        WHERE OrderId = @HeaderID

                        -- Run MakeRequest only after Status = 'C'
                        IF EXISTS (
                            SELECT 1 FROM [dbo].[SPO_OrderHeader]
                            WHERE OrderId = @HeaderID
                              AND Status = 'C'
                        )
                        BEGIN
                            EXEC [dbo].[SPO_MakeRequestForThisOrder]
                                @OrderId       = @HeaderID,
                                @UserProfileID = @UserID;
                        END
                    END
                    -- else: still pending approvers → wait, do nothing
                END

                -- =============================================
                -- CASE 2: No approval log — no levels configured
                --         Direct approve immediately
                -- =============================================
                ELSE
                BEGIN
                    UPDATE [dbo].[SPO_OrderHeader]
                    SET IsApprove = 1,
                        Status = 'C'
                    WHERE OrderId = @HeaderID

                    --  Run MakeRequest only after Status = 'C'
                    IF EXISTS (
                        SELECT 1 FROM [dbo].[SPO_OrderHeader]
                        WHERE OrderId = @HeaderID
                          AND Status = 'C'
                    )
                    BEGIN
                        EXEC [dbo].[SPO_MakeRequestForThisOrder]
                            @OrderId       = @HeaderID,
                            @UserProfileID = @UserID;
                    END
                END

                --Insert New Data--
                UPDATE TA
                SET TA.NewData = (
                    SELECT (
                    SELECT * FROM
                    [dbo].[SPO_OrderHeader] WHERE OrderId = @HeaderID
                    FOR JSON PATH
                    ) AS HeaderData,
                     (
                    SELECT * FROM
                    [dbo].[SPO_OrderDetails] WHERE OrderId = @HeaderID
                    FOR JSON PATH
                    ) AS DetailData
                    FOR JSON PATH
                )
                FROM
                [dbo].[SPO_TransactionApprovalLog] TA
                WHERE TA.TransactionTypeID = @TransactionID
                AND TA.TransactionHeaderID = @HeaderID
                AND TA.UserProfileID= @UserID
                -------------------
            END
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;
END

GO

