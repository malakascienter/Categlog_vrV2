
CREATE PROCEDURE [dbo].[CSOX_CompleteSignOff_Central]
    @PropertyId             INT,
    @Outlet                 CHAR(3),
    @ShiftNo                INT,
    @ShiftDate              DATETIME,
    @CashierCode            VARCHAR(10),
    @StationId              VARCHAR(200)    = NULL,
    @SignOnDate             DATETIME        = NULL,
    @SignOffAuthorizedUser  VARCHAR(100)    = NULL,
    @OpeningBalance         DECIMAL(18,2),
    @TotalCashReceipts      DECIMAL(18,2),
    @Withdrawals            DECIMAL(18,2),
    @CalculatedCashAmount   DECIMAL(18,2),
    @PhysicalAmount         DECIMAL(18,2),
    @TotalCashSale          DECIMAL(18,2),
    @Variance               DECIMAL(18,2),
    @WorkStation            VARCHAR(100)    = NULL,
    @LocationName           VARCHAR(100)    = NULL,
    @StartingInvoiceNo      VARCHAR(100)    = NULL,
    @EndingInvoiceNo        VARCHAR(100)    = NULL,
    @InvoiceCount           INT             = 0,
    @CancelledInvoiceCount  INT             = 0,
    @TotalDiscount          DECIMAL(18,4)   = 0,
    @SystemAmountsJson      NVARCHAR(MAX),  -- [{ "PayCode":"02","SystemAmount":18400.00 }]
    @DeclaredJson           NVARCHAR(MAX)   -- [{ "PayCode":"01","DenominationType":"5000","Count":4,"Amount":20000.00,"IsCash":1 }]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ShiftDay DATE = CONVERT(DATE, @ShiftDate);

    BEGIN TRY
        BEGIN TRANSACTION;

		 DECLARE @CashierName VARCHAR(250) =
            (SELECT TOP (1) [Name] FROM dbo.Waiter
              WHERE Code = @CashierCode AND PropertyId = @PropertyId);

	    SET @CashierName = ISNULL(@CashierName,@CashierCode)

        -- ---- Parse the two JSON payloads once -----------------------------
        DECLARE @SystemAmounts TABLE (PayCode VARCHAR(10), SystemAmount DECIMAL(18,4));

        INSERT INTO @SystemAmounts (PayCode, SystemAmount)
        SELECT PayCode, SystemAmount
        FROM OPENJSON(@SystemAmountsJson)
        WITH (
            PayCode      VARCHAR(10)   '$.PayCode',
            SystemAmount DECIMAL(18,4) '$.SystemAmount'
        );

        DECLARE @Declared TABLE
        (
            PayCode          VARCHAR(10),
            DenominationType VARCHAR(50),
            [Count]          INT,
            Amount           DECIMAL(18,4),
            IsCash           BIT
        );

        INSERT INTO @Declared (PayCode, DenominationType, [Count], Amount, IsCash)
        SELECT PayCode, DenominationType, [Count], Amount, IsCash
        FROM OPENJSON(@DeclaredJson)
        WITH (
            PayCode          VARCHAR(10)   '$.PayCode',
            DenominationType VARCHAR(50)   '$.DenominationType',
            [Count]          INT           '$.Count',
            Amount           DECIMAL(18,4) '$.Amount',
            IsCash           BIT           '$.IsCash'
        );

        -- ---- 1) Payment-type-wise system amounts --------------------------
        DELETE FROM dbo.CashierSignOffPaymentTypesWiseSystemAmounts
        WHERE ShiftId = @ShiftNo AND Outlet = @Outlet AND PropertyId = @PropertyId
          AND CONVERT(DATE, ShiftDate) = @ShiftDay;

        INSERT INTO dbo.CashierSignOffPaymentTypesWiseSystemAmounts
              (PayCode, SystemAmount, ShiftId, ShiftDate, Outlet, PropertyId)
        SELECT PayCode, SystemAmount, @ShiftNo, @ShiftDate, @Outlet, @PropertyId
        FROM   @SystemAmounts;

        -- ---- 2) Summary details -------------------------------------------
        DELETE FROM dbo.CashierSignOffSummaryDetails
        WHERE ShiftNo = @ShiftNo AND OutletCode = @Outlet AND PropertyId = @PropertyId
          AND CONVERT(DATE, SystemDate) = @ShiftDay;

        INSERT INTO dbo.CashierSignOffSummaryDetails
              (ShiftNo, OutletCode, OpeningBalance, TotCashReceipts, Withrawals,
               CalculatedCashAmount, PhysicalAmount, TotCashSale, SystemDate, Variance,
               CashierSignOnDateTime, CashierSignOffAuthorizedUser, PropertyId)
        VALUES(@ShiftNo, @Outlet, @OpeningBalance, @TotalCashReceipts, @Withdrawals,
               @CalculatedCashAmount, @PhysicalAmount, @TotalCashSale, @ShiftDate, @Variance,
               @SignOnDate, @SignOffAuthorizedUser, @PropertyId);

        -- ---- 3) Sign off user details -------------------------------------
        DELETE FROM dbo.CashierSignOffUserDetails
        WHERE ShiftNo = @ShiftNo AND OutletCode = @Outlet AND PropertyId = @PropertyId
          AND CONVERT(DATE, ShiftDate) = @ShiftDay;

        INSERT INTO dbo.CashierSignOffUserDetails
              (ShiftNo, ShiftDate, [Location], [Users], SystemDate, Station, StartingInvoiceNo,
               EndingInvoiceNo, InvoiceCount, CancelInvoiceCount, OutletCode, ReturnExchange,
               TotalDiscount, PropertyId)
        SELECT @ShiftNo, @ShiftDate, @LocationName,
               @CashierName,
               @ShiftDate, @WorkStation, @StartingInvoiceNo,
               @EndingInvoiceNo, @InvoiceCount, @CancelledInvoiceCount, @Outlet, 0,
               @TotalDiscount, @PropertyId;

        -- ---- 4) Central mirror of the POS cashier shift -------------------
        -- NOTE: PK_CashierShift covers only (ShiftNo, WaiterCode) — not outlet,
        -- date or property. The existence check MUST test those two columns
        -- alone. Testing more (as CashierShift_Save_OutletsCashierShift does)
        -- lets the guard pass for a new date and then hit a primary key
        -- violation on insert.
        --
        -- NOTE: EVERY column of this table is NOT NULL, including StationID,
        -- SignOnDate and SignOnAuthorizedUser — all three of which arrive as
        -- optional parameters and can legitimately be NULL. Passing any of them
        -- straight through aborts the whole transaction and loses a completed
        -- cash count, so each is defaulted here. StationID is also narrower than
        -- its parameter (varchar(50) vs varchar(200)), hence the LEFT().
        --
        -- The UPDATE branch is safe without defaults for a subtle reason: the
        -- columns it falls back to cannot themselves be NULL.
        IF EXISTS (SELECT 1 FROM dbo.POS_CashierShift
                    WHERE ShiftNo = @ShiftNo AND WaiterCode = @CashierCode)
        BEGIN
            UPDATE dbo.POS_CashierShift
            SET    ShiftDate            = @ShiftDate,
                   Outlet               = @Outlet,
                   PropertyId           = @PropertyId,
                   StationID            = LEFT(ISNULL(@StationId, StationID), 50),
                   CashFloat            = @OpeningBalance,
                   IsSignOff            = 1,
                   IsManagerSignOff     = 1,
                   SignOffDate          = GETDATE(),
                   SignOnDate           = ISNULL(@SignOnDate, SignOnDate),
                   SignOnAuthorizedUser = LEFT(ISNULL(@SignOffAuthorizedUser, SignOnAuthorizedUser), 100)
            WHERE  ShiftNo = @ShiftNo AND WaiterCode = @CashierCode;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.POS_CashierShift
                  (ShiftNo, ShiftDate, WaiterCode, IsSignOff, CashFloat, SignOffDate,
                   StationID, Outlet, IsManagerSignOff, SignOnDate, SignOnAuthorizedUser, PropertyId)
            VALUES(@ShiftNo, @ShiftDate, @CashierCode, 1, @OpeningBalance, GETDATE(),
                   LEFT(ISNULL(@StationId, ''), 50), @Outlet, 1,
                   ISNULL(@SignOnDate, @ShiftDate),
                   LEFT(ISNULL(@SignOffAuthorizedUser, ''), 100), @PropertyId);
        END

        -- ---- 5) Denomination / payment breakdown log ----------------------
        DELETE FROM dbo.CashireShiftEndLog
        WHERE ShiftNo = @ShiftNo AND Cashireid = @CashierCode AND Outlet = @Outlet
          AND PropertyId = @PropertyId AND CONVERT(DATE, sysdate) = @ShiftDay;

        INSERT INTO dbo.CashireShiftEndLog
              (ShiftNo, Cashireid, dType, nos, [value], sysdate, IsCash, Outlet,
               PayCode, SystemAmount, PropertyId)
        SELECT @ShiftNo, @CashierCode, ISNULL(d.DenominationType, ''), ISNULL(d.[Count], 0),
               d.Amount, @ShiftDate, d.IsCash, @Outlet, d.PayCode,
               ISNULL(sa.SystemAmount, 0), @PropertyId
        FROM      @Declared d
        LEFT JOIN @SystemAmounts sa ON sa.PayCode = d.PayCode
        ORDER BY  d.PayCode, d.[Count];

        -- ---- 6) Payment details + variance log ----------------------------
        -- Cash is reconciled against (system + advances + opening float
        -- - withdrawals), matching the adjustment CashireShiftEndLog_M_Save
        -- applies to the CASH row after inserting.
        DECLARE @PaymentDetails TABLE
        (
            PayCode        VARCHAR(10),
            [Description]  VARCHAR(100),
            PhysicalAmount DECIMAL(18,4),
            SystemAmount   DECIMAL(18,4),
            Variance       DECIMAL(18,4)
        );

        INSERT INTO @PaymentDetails (PayCode, [Description], PhysicalAmount, SystemAmount, Variance)
        SELECT   d.PayCode,
                 MAX(p.[Description]),
                 SUM(d.Amount),
                 MAX(ISNULL(sa.SystemAmount, 0)),
                 SUM(d.Amount) - MAX(ISNULL(sa.SystemAmount, 0))
        FROM     @Declared d
        INNER JOIN dbo.PaymentTypes p
                ON p.PayCode = d.PayCode AND p.PropertyId = @PropertyId
        LEFT  JOIN @SystemAmounts sa ON sa.PayCode = d.PayCode
        WHERE    d.PayCode <> 'AD'
        GROUP BY d.PayCode;

        UPDATE @PaymentDetails
        SET    SystemAmount = SystemAmount + ISNULL(@TotalCashReceipts, 0)
                            + ISNULL(@OpeningBalance, 0) - ISNULL(@Withdrawals, 0),
               Variance     = PhysicalAmount
                            - (SystemAmount + ISNULL(@TotalCashReceipts, 0)
                               + ISNULL(@OpeningBalance, 0) - ISNULL(@Withdrawals, 0))
        WHERE  PayCode = '01';

        DELETE FROM dbo.CashierSignOffPaymentDetails
        WHERE ShiftNo = @ShiftNo AND OutletCode = @Outlet AND PropertyId = @PropertyId
          AND CONVERT(DATE, SystemDate) = @ShiftDay;

        INSERT INTO dbo.CashierSignOffPaymentDetails
              ([Desccription], SystemAmount, PhysicalAmount, Variance, SystemDate,
               ShiftNo, OutletCode, PropertyId)
        SELECT [Description], SystemAmount, PhysicalAmount, Variance, @ShiftDate,
               @ShiftNo, @Outlet, @PropertyId
        FROM   @PaymentDetails;

       

        DELETE FROM dbo.CashierVarianceLog
        WHERE ShiftId = @ShiftNo AND Outlet = @Outlet AND PropertyId = @PropertyId
          AND CONVERT(DATE, TxnDate) = @ShiftDay;

        INSERT INTO dbo.CashierVarianceLog
              (TxnDate, ShiftId, Outlet, CashierID, Paycode, PaymentType, Variance,
               Remark, SysDate, CashierName, PropertyId)
        SELECT @ShiftDate, @ShiftNo, @Outlet, @CashierCode, PayCode, [Description],
               Variance, '', GETDATE(), @CashierName, @PropertyId
        FROM   @PaymentDetails;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

