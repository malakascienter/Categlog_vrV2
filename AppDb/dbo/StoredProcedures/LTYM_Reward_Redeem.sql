
CREATE   PROCEDURE [dbo].[LTYM_Reward_Redeem]
    @MemberId   INT,
    @RewardId   INT,
    @CreatedBy  INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @LockResult INT,
                @LockName NVARCHAR(100) = CONCAT('LTYM_Redeem_Member_', @MemberId);
        EXEC @LockResult = sp_getapplock
             @Resource    = @LockName,
             @LockOwner   = 'Transaction',
             @LockMode    = 'Exclusive',
             @LockTimeout = 5000,
             @DbPrincipal = 'public';

        IF @LockResult < 0
            THROW 52034, 'Could not acquire redemption lock; please retry.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTY_Member
                       WHERE MemberId = @MemberId AND PropertyId = @PropertyId AND IsActive = 1)
            THROW 52020, 'Member not found.', 1;

        DECLARE @Name NVARCHAR(150), @PointsCost DECIMAL(18,2), @DiscountValue DECIMAL(18,4),
                @IsPercentage BIT, @ValidityDays INT;

        SELECT @Name = Name, @PointsCost = PointsCost, @DiscountValue = DiscountValue,
               @IsPercentage = IsPercentage, @ValidityDays = ValidityDays
        FROM   dbo.LTYM_Rewards
        WHERE  Id = @RewardId
          AND  IsActive = 1
          AND (StartDate IS NULL OR StartDate <= SYSUTCDATETIME())
          AND (EndDate   IS NULL OR EndDate   >= SYSUTCDATETIME());

        IF @Name IS NULL
            THROW 52030, 'This reward is not available.', 1;

        DECLARE @Balance DECIMAL(18,2) = dbo.LTYM_fn_MemberPointsBalance(@MemberId, @PropertyId);

        IF @Balance < @PointsCost
            THROW 52031, 'Not enough points to redeem this reward.', 1;

        /* Coupon document number, following dbo.LTY_SaveMember conventions. */
        DECLARE @CouponType   VARCHAR(5)  = 'COU';
        DECLARE @LocationCode VARCHAR(20) = dbo.LTY_GetSettingValue(1, @PropertyId);
        DECLARE @DocNo        NVARCHAR(300);

        SELECT @DocNo = dbo.FN_LTY_GetNextDocumentNumber(@PropertyId, @LocationCode, @CouponType);
        IF (@DocNo IS NULL)
        BEGIN
            EXEC dbo.LTY_InsertDocumentNumber @PropertyId, @LocationCode, @CouponType;
            SELECT @DocNo = dbo.FN_LTY_GetNextDocumentNumber(@PropertyId, @LocationCode, @CouponType);
        END

        DECLARE @Code VARCHAR(50) = CONCAT(TRIM(@CouponType), '/', @LocationCode, '/', @DocNo);
        DECLARE @Now  DATETIME = GETDATE();
        DECLARE @Expire DATETIME = DATEADD(DAY, @ValidityDays, @Now);

        INSERT INTO dbo.LTY_CouponMaster
              (DocumentNo, PropertyId, Outlet, IsPerecentage, Value, ExpireDate, CreateBy, CreatedDate, MemberId)
        VALUES (@Code, @PropertyId, @LocationCode, @IsPercentage, @DiscountValue, @Expire, @CreatedBy, @Now, @MemberId);

        DECLARE @CouponId INT = SCOPE_IDENTITY();

        UPDATE dbo.LTY_TransactionTypeWiseNextNumbers
        SET    NextNumber = NextNumber + 1
        WHERE  PropertyID      = @PropertyId
          AND  LocationCode    = @LocationCode
          AND  TransactionType = @CouponType;

        INSERT INTO dbo.LTY_MemberWisePointTransaction
              (MemberId, NoPoints, OutletCode, PropertyId, BillValue, PointsBefore, PointsBalance,
               TransactionType, Remark, TxnDate, CreatedUserId, CreatedDateTime, OrderNo, ExpireDate)
        VALUES (@MemberId, -1 * @PointsCost, @LocationCode, @PropertyId, 0, @Balance, @Balance - @PointsCost,
                'R', CONCAT('Portal reward: ', @Name, ' (coupon ', @Code, ')'), @Now, @CreatedBy, @Now, '', @Expire);

        DECLARE @TransId INT = SCOPE_IDENTITY();

        INSERT INTO dbo.LTYM_RewardRedemptions
              (RewardId, MemberId, CouponId, PointTransId, PointsSpent, CouponCode)
        VALUES (@RewardId, @MemberId, @CouponId, @TransId, @PointsCost, @Code);

        COMMIT TRANSACTION;

        SELECT @Code                                        AS CouponCode,
               @Name                                        AS RewardName,
               @PointsCost                                  AS PointsSpent,
               CAST(@Balance - @PointsCost AS DECIMAL(18,2)) AS NewBalance,
               @Now                                         AS ValidFrom,
               @Expire                                      AS ValidTo,
               @DiscountValue                               AS DiscountValue,
               @IsPercentage                                AS IsPercentage;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

