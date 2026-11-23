
-- =============================================
-- Author:       Ravindu
-- Create date:  2025-07-18
-- Description:  Tour Guide commission save
-- =============================================
-- [dbo].[TourGuideCommission_M_Save_INV] '<TourGuideCommissionSubmitModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Remark>Test</Remark><TourGuideId>6</TourGuideId><TotalAmount>12350</TotalAmount><Items><TourGuideCommission><OrderNo>INV0000011</OrderNo><TableNo>NA</TableNo><TourGuideCompaniesPer>12</TourGuideCompaniesPer><TourGuidePer>5</TourGuidePer><ServiceCharge>0</ServiceCharge><Subtotal>12350</Subtotal><TaxVal1>0</TaxVal1><TaxVal2>0</TaxVal2><TaxVal3>0</TaxVal3><TaxVal4>0</TaxVal4><TourGuideCompaniesId>26</TourGuideCompaniesId><Outlet>MAIN STORES</Outlet><PropertyId>2</PropertyId><OrderDateString>2023-11-23</OrderDateString><BillType>RT</BillType><BillTypeName>Retail</BillTypeName></TourGuideCommission></Items></TourGuideCommissionSubmitModel>'

CREATE PROCEDURE [dbo].[TourGuideCommission_M_Save_INV]
    @XMLData XML,
    @HeaderId  INT OUTPUT,
    @DocNo  VARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @iDocID INT;
    DECLARE @DocumentNo VARCHAR(MAX);
    DECLARE @PropertyID INT,@UserId INT;
    DECLARE @TourGuideTxnHeaderId BIGINT;

    BEGIN TRY
        BEGIN TRANSACTION;

       
        IF OBJECT_ID('tempdb..#TempTxnHeader') IS NOT NULL
            DROP TABLE #TempTxnHeader;

        IF OBJECT_ID('tempdb..#TempTxnDetails') IS NOT NULL
            DROP TABLE #TempTxnDetails;

       
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;

       
        SELECT
            DocumentNo,
            TourGuideId,
            TotalAmount,
            Remark,
            UserId
        INTO #TempTxnHeader
        FROM OPENXML(@iDocID, '/TourGuideCommissionSubmitModel', 2)
        WITH (
            DocumentNo      VARCHAR(20),
            TourGuideId     INT,
            TotalAmount     DECIMAL(18,6),
            Remark          VARCHAR(MAX),
            UserId          INT
        );

       
        SELECT
            OrderNo,
            OrderDateString,
            OutletCode,
            PropertyId,
            OrderAmount,
            TourGuideCompaniesPer,
            TourGuidePer,
            TourGuideCompaniesId,
            CommissionAmount
        INTO #TempTxnDetails
        FROM OPENXML(@iDocID, '/TourGuideCommissionSubmitModel/Items/TourGuideCommission', 2)
        WITH (
            OrderNo              VARCHAR(20),
            OrderDateString      NVARCHAR(MAX),
            OutletCode               VARCHAR(50),
            PropertyId           INT,
            OrderAmount          DECIMAL(18,6),
            TourGuideCompaniesPer DECIMAL(18,6),
            TourGuidePer         DECIMAL(18,6),
            TourGuideCompaniesId INT,
            CommissionAmount     DECIMAL(18,6)
        );

       
        SELECT TOP (1) @PropertyID = PropertyId FROM #TempTxnDetails;

        SELECT TOP (1)  @UserId = UserId FROM #TempTxnHeader;

       
        SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, -999, 'TG');

        IF @DocumentNo IS NULL
        BEGIN
            INSERT INTO TransactionTypeWiseNextNumbers
            (
                PropertyID,
                LocationID,
                TransactionType,
                NextNumber,
                LengthOfFormatting
            )
            VALUES
            (
                @PropertyID,
                -999,
                'TG',
                1,
                6
            );

            SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, -999, 'TG');
        END

        SET @DocumentNo = 'TG/' + @DocumentNo;

        UPDATE TransactionTypeWiseNextNumbers
        SET NextNumber = NextNumber + 1
        WHERE LocationID = -999 AND TransactionType = 'TG';

       
        IF EXISTS (
            SELECT 1
            FROM #TempTxnDetails T
            INNER JOIN POS_InvoiceHeader P
                ON T.OrderNo = P.InvoiceNo
                AND CONVERT(DATE, T.OrderDateString) = P.BusinessDate
                AND T.PropertyId = P.CompanyID
            WHERE P.IsPaidCommission = 1
        )
        BEGIN
            RAISERROR ('Already Commission paid bill found. Please check again!', 16, 1);
        END

       
        IF EXISTS (
            SELECT 1
            FROM TourGuideTxnHeader
            WHERE DocumentNo = @DocumentNo AND PropertyId = @PropertyID
        )
        BEGIN
            RAISERROR ('Document No already exists!', 16, 1);
        END

      
        INSERT INTO TourGuideTxnHeader
        (
            DocumentNo,
            TourGuideId,
            TotalAmount,
            Remark,
            PropertyId,
            CreatedUserId,
            CreatedDateTime,
            DocumentDate
        )
        SELECT
            @DocumentNo,
            TourGuideId,
            TotalAmount,
            Remark,
            @PropertyID,
            UserId,
            GETDATE(),
            GETDATE()
        FROM #TempTxnHeader;

        SET @TourGuideTxnHeaderId = SCOPE_IDENTITY();

       
        INSERT INTO TourGuideTxnDetails
        (
            TourGuideTxnHeaderId,
            OrderNo,
            OrderDate,
            Outlet,
            PropertyId,
            OrderAmount,
            TourGuideCompaniesPer,
            TourGuidePer,
            TourGuideCompaniesId,
            CommissionAmount,
            CreatedUserId,
            CreatedDateTime
        )
        SELECT
            @TourGuideTxnHeaderId,
            OrderNo,
            OrderDateString,--GETDATE(),
            OutletCode,
            PropertyId,
            OrderAmount,
            TourGuideCompaniesPer,
            TourGuidePer,
            TourGuideCompaniesId,
            CommissionAmount,
            @UserId,
            GETDATE()
        FROM #TempTxnDetails;

       
        UPDATE P
        SET P.IsPaidCommission = 1
        FROM #TempTxnDetails T
        INNER JOIN POS_InvoiceHeader P
            ON T.OrderNo = P.InvoiceNo
            AND CONVERT(DATE, T.OrderDateString) = P.BusinessDate
            AND T.PropertyId = P.CompanyID;


       SET @HeaderId = @TourGuideTxnHeaderId;
        SET @DocNo = @DocumentNo;
        SELECT * FROM #TempTxnHeader;
        SELECT * FROM #TempTxnDetails;

       
        EXEC sp_xml_removedocument @iDocID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

GO

