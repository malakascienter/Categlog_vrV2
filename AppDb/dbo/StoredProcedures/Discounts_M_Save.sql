
-- ============================================================
-- 3. Discounts_M_Save : add @DiscountTierJson handling
--    (full body - only the Tier blocks are new)
--
--    @DiscountTierJson is NULL when the caller does not send tiers at all
--    (Tier block switched off in Web.config) - the saved tier rows are then
--    left exactly as they are. 'null' / [] means "no tiers selected" and does
--    clear them.
-- ============================================================
CREATE PROCEDURE [dbo].[Discounts_M_Save]-- 10.6
	@Code					VARCHAR(2),
	@Description			VARCHAR(100),
	@TimeFrom				NVARCHAR(20),
	@TimeTo					NVARCHAR(20),
	@DateFrom				DATETIME,
	@DateTo					DATETIME,
	@IsActive				BIT,
	@IsAutoApply			BIT,
	@IsAuthorization		BIT,
	@IsDay					BIT,
	@ValidationMode			VARCHAR(MAX),
	@DiscountType			VARCHAR(5),
	@IsNeedRemark			BIT,
	@IsValidatePayType		BIT,
	@DiscountValue			DECIMAL(18,2),
	@Operation				CHAR(1),
	@UserId					INT,
	@IsPercentage			BIT,
	@IsItemWiseDiscount		BIT,
	@DisCountDaysJson		NVARCHAR(max),
	@MenuItemsJson			NVARCHAR(max),
	@OutletJson				NVARCHAR(MAX),
	@MenuItemsTypes			NVARCHAR(MAX),
	@PropertyId				INT,
	@DiscountItemCategory	NVARCHAR(MAX),
	@DiscountBinNumberJson	NVARCHAR(MAX),
	@DiscountPaymentJson	NVARCHAR(MAX),
	@IsApplyAllItems		BIT,
	@MinimumAmount			DECIMAL(18,2),
	@MaximumDiscount		DECIMAL(18,2),
	@DiscountMemberJson     NVARCHAR(MAX),
	@DiscountBuyNGetNJson   NVARCHAR(MAX),
	@BuyItemQty		        DECIMAL(18,2),
	@DiscountItemQty		DECIMAL(18,2),
	@DiscountChannelArrayJson   NVARCHAR(MAX),
	@DiscountCustomerGroupJson  NVARCHAR(MAX) = 'null',
	@DiscountTierJson		NVARCHAR(MAX) = NULL
AS
BEGIN	TRY
BEGIN TRANSACTION
	DECLARE @Discount DECIMAL(18,2)
	DECLARE @DiscountPercent  DECIMAL(18,2)
	DECLARE @Percentage DECIMAL(18,2)
	DECLARE @ValidationModeCode VARCHAR(5)
    DECLARE @InsertValidationModeCode VARCHAR(5)

	SET @ValidationMode = ISNULL(@ValidationMode,'0')
	SELECT @ValidationModeCode = Code,@DiscountType = ISNULL(DiscountType,'')  FROM [ValidationModes] WHERE Id = CONVERT(int,@ValidationMode)
	SET @ValidationModeCode = ISNULL(@ValidationModeCode,'')
	SET @DiscountType = ISNULL(@DiscountType,'')


	IF( @ValidationModeCode IN ('EMP','EML','CUS','CUSV','TYPE','TYPES','SEITM') )
	BEGIN

		SET @InsertValidationModeCode = @ValidationModeCode

	END
	ELSE
	BEGIN

		SET @InsertValidationModeCode = ''

	END


	IF (@IsPercentage=1)
	BEGIN
		SET @Percentage=@DiscountValue--/100
		SET @DiscountPercent=@Percentage
	END
	ELSE
	BEGIN
		SET @Percentage=0
		SET @Discount=@DiscountValue
	END
	-- SOCG (Special Order Customer Group) and AITM (Selected Item Discount) also
	-- target menu items, so they share the ITM item-parsing and DiscountDetails
	-- persistence below.
	IF  (@ValidationModeCode IN ('ITM','SOCG','AITM'))
	BEGIN

		IF( ISNULL(@MenuItemsJson,'') != '' )
		BEGIN

		SELECT * INTO #TempItems
				FROM OPENJSON(@MenuItemsJson)
				WITH
				(
				ItemCode   VARCHAR(10) '$.ItemCode',
				DiscountId INT'$.DiscountId'
				)

		END

	END

	IF(@IsDay=1)
	BEGIN
		SELECT * INTO #TempDiscountDays
		FROM OPENJSON(@DisCountDaysJson)
		WITH(
		Id INT '$.Id',
		Name VARCHAR(50) '$.Name'
		)
	END


	CREATE TABLE #TempItemsTypes
	(
      ItemTypeCode   VARCHAR(10)
	)


    IF( @MenuItemsTypes != '0' )--0 = No Record
    BEGIN
		INSERT INTO #TempItemsTypes (ItemTypeCode)
        SELECT ItemTypeCode
		FROM OPENJSON(@MenuItemsTypes)
		WITH
		(
			ItemTypeCode   VARCHAR(10) '$.ItemTypeCode'
		)

    END


	CREATE TABLE #TempDiscountItemCategory
	(
      CategoryCode   VARCHAR(10)
	)


    IF( @DiscountItemCategory != 'null' )--0 = No Record
    BEGIN
		INSERT INTO #TempDiscountItemCategory (CategoryCode)
        SELECT CategoryCode
		FROM OPENJSON(@DiscountItemCategory)
		WITH
		(
			CategoryCode   VARCHAR(10) '$.CategoryCode'
		)

    END


	CREATE TABLE #TempDiscountBinNumbers
	(
      BinNumber   VARCHAR(50)
	)

	IF( @DiscountBinNumberJson != 'null' )--0 = No Record
    BEGIN

		INSERT INTO #TempDiscountBinNumbers (BinNumber)
        SELECT BinNumber
		FROM OPENJSON(@DiscountBinNumberJson)
		WITH
		(
			BinNumber   VARCHAR(50) '$.BinNumber'
		)

    END

	CREATE TABLE #TempDiscountPayment
	(
      PayType   VARCHAR(50)
	)

	IF( @DiscountPaymentJson != 'null' )--0 = No Record
    BEGIN

		INSERT INTO #TempDiscountPayment (PayType)
        SELECT PayType
		FROM OPENJSON(@DiscountPaymentJson)
		WITH
		(
			PayType   VARCHAR(50) '$.PayType'
		)

    END

	CREATE TABLE #TempDiscountMember
	(
      MemberCode   VARCHAR(50)
	)

	IF( @DiscountMemberJson != 'null' )--0 = No Record
    BEGIN

		INSERT INTO #TempDiscountMember (MemberCode)
        SELECT MemberCode
		FROM OPENJSON(@DiscountMemberJson)
		WITH
		(
			MemberCode   VARCHAR(50) '$.MemberCode'
		)

    END

	CREATE TABLE #TempDiscountChannel
	(
      ChannelCode   VARCHAR(50)
	)

	IF( @DiscountChannelArrayJson != 'null' )--0 = No Record
    BEGIN

		INSERT INTO #TempDiscountChannel (ChannelCode)
        SELECT ChannelCode
		FROM OPENJSON(@DiscountChannelArrayJson)
		WITH
		(
			ChannelCode   VARCHAR(50) '$.ChannelCode'
		)

    END

	-- Special Order Customer Group (SOCG) targeting
	CREATE TABLE #TempDiscountCustomerGroup
	(
      CustomerGroupId   BIGINT
	)

	SET @DiscountCustomerGroupJson = ISNULL(@DiscountCustomerGroupJson,'null')

	IF( @DiscountCustomerGroupJson != 'null' )--0 = No Record
    BEGIN

		INSERT INTO #TempDiscountCustomerGroup (CustomerGroupId)
        SELECT CustomerGroupId
		FROM OPENJSON(@DiscountCustomerGroupJson)
		WITH
		(
			CustomerGroupId   BIGINT '$.CustomerGroupId'
		)

    END

	-- Loyalty tier targeting (dbo.DiscountWiseTier)
	CREATE TABLE #TempDiscountTier
	(
      TierId   INT
	)

	IF( @DiscountTierJson IS NOT NULL AND @DiscountTierJson != 'null' )--NULL = section not sent, 'null' = nothing selected
    BEGIN

		INSERT INTO #TempDiscountTier (TierId)
        SELECT TierId
		FROM OPENJSON(@DiscountTierJson)
		WITH
		(
			TierId   INT '$.TierId'
		)

    END

	CREATE TABLE #TempDiscountBuyNGetN
	(
		Code NVARCHAR(50),
		ItemCode NVARCHAR(50),
		IsBuyItem BIT,
		IsDiscountItem BIT,
		DiscountPercentage DECIMAL(18, 2),
		DiscountValue DECIMAL(18, 2)
	);

	IF( @DiscountBuyNGetNJson != 'null' )--0 = No Record
    BEGIN

		INSERT INTO #TempDiscountBuyNGetN (Code, ItemCode, IsBuyItem, IsDiscountItem, DiscountPercentage, DiscountValue)
		SELECT
			Code,
			ItemCode,
			IsBuyItem,
			IsDiscountItem,
			DiscountPercentage,
			DiscountValue
		FROM OPENJSON(@DiscountBuyNGetNJson)
		WITH
		(
			Code NVARCHAR(50) '$.Code',
			ItemCode NVARCHAR(50) '$.ItemCode',
			IsBuyItem BIT '$.IsBuyItem',
			IsDiscountItem BIT '$.IsDiscountItem',
			DiscountPercentage DECIMAL(18,2) '$.DiscountPercentage',
			DiscountValue DECIMAL(18,2) '$.DiscountValue'
		);

    END



	IF OBJECT_ID('tempdb..#TempOutlet') IS NOT NULL
    DROP TABLE #TempOutlet;

	CREATE TABLE #TempOutlet
	(
		OutletCode VARCHAR(10)
	);

	IF (@OutletJson IS NOT NULL AND @OutletJson != 'null')
	BEGIN

		-- Insert JSON data into temp table
		INSERT INTO #TempOutlet (OutletCode)
		SELECT Code
		FROM OPENJSON(@OutletJson)
		WITH
		(
			Code VARCHAR(10) '$.Code'
		);



	END



	DECLARE @Remark NVARCHAR(250)
	DECLARE @Id INT
	IF(@Operation = 'I')
		BEGIN
			IF EXISTS (SELECT 1 FROM DiscountHeader where Description=@Description AND PropertyId=@PropertyId)
			BEGIN
				RAISERROR('Discount Description already exists',16,1)
			END
			ELSE IF EXISTS(SELECT 1 FROM DiscountHeader WHERE Code=@Code AND PropertyId=@PropertyId)
			BEGIN
				RAISERROR('Discount Code already exists',16,1)
			END
			--ELSE IF ( @TimeFrom < CONVERT(smalldatetime, getdate()) )
			--BEGIN
				--RAISERROR('Discount  Can not apply for before current time ',16,1)
		--END
			ELSE
				BEGIN

				INSERT INTO  DiscountHeader(Code,Description,TimeFrom,TimeTo,DateFrom,DateTo,Percentage,IsAutoApply, IsAuthorization, IsDay, SysDate, ValidationMode, DiscountType, IsNeedRemark, IsValidatePayType, DiscountValue, IsActive, CreatedUserId, CreatedDateTime,OutletListJson,MenuItemJson,DaysJson,IsItemWiseDiscount,IsPercentage,PropertyId,IsUpload,ValidationModesId,IsApplyAllItems,MinimumAmount,MaximumDiscount,BuyQuantity,FreeQuantity)
				VALUES(@Code,@Description,CONVERT(TIME, @TimeFrom,108),CONVERT(TIME,@TimeTo,108),@DateFrom,@DateTo,isnull(@DiscountPercent,0),@IsAutoApply,@IsAuthorization,@IsDay,GetDate(),@InsertValidationModeCode,@DiscountType,@IsNeedRemark,@IsValidatePayType,Isnull(@Discount,0),@IsActive,@UserId,GETDATE(),@OutletJson,@MenuItemsJson,@DisCountDaysJson,@IsItemWiseDiscount,@IsPercentage,@PropertyId,0,CONVERT(int,@ValidationMode),@IsApplyAllItems,@MinimumAmount,@MaximumDiscount,@BuyItemQty,@DiscountItemQty)

				SET @Id = SCOPE_IDENTITY()

				-- Audit trail ----------------------------
				EXEC HotelResWeb_AuditTail_WriteToLog 'DiscountHeader',@Id,'POS','POSDHI','I',@UserId,'','','','','',@PropertyId
				-- End of Audit trail ---------------------

				IF(@IsDay=1)
				BEGIN

					IF EXISTS(SELECT 1 from #TempDiscountDays)
					BEGIN
						INSERT INTO DiscountDays(Code, DayName, SysDate,PropertyId)
						SELECT @Code,Name,GETDATE(),@PropertyId  FROM #TempDiscountDays
					END
				END
				IF  (@ValidationModeCode IN ('ITM','SOCG','AITM'))
				BEGIN
					IF OBJECT_ID('tempdb..#TempItems') IS NOT NULL
					INSERT INTO DiscountDetails( Code, OrderType, MenuItemID, DiscountPercentage, DiscountValue, BuyQuantity, DiscountQuantity, IsUpload, PropertyId, CreatedUserId, CreatedDateTime)
					SELECT @Code,'',ItemCode,@DiscountPercent,Isnull(@Discount,0),0,0,0,@PropertyId,@UserId,GETDATE() FROM #TempItems
				END

				IF  (@ValidationModeCode='FITM')
				BEGIN
					INSERT INTO DiscountDetails
					(
						Code,
						OrderType,
						MenuItemID,
						DiscountPercentage,
						DiscountValue,
						BuyQuantity,
						DiscountQuantity,
						IsUpload,
						PropertyId,
						CreatedUserId,
						CreatedDateTime,
						IsBuyItem,
						IsDiscountItem
					)
					SELECT
						Code,                  -- from temp table
						'',                    -- OrderType empty
						ItemCode,              -- MenuItemID mapped from ItemCode
						DiscountPercentage,    -- Discount %
						ISNULL(DiscountValue, 0),  -- Discount value (fallback 0)
						CASE WHEN IsBuyItem = 1 THEN 1 ELSE 0 END,      -- BuyQuantity, e.g., 1 if IsBuyItem
						CASE WHEN IsDiscountItem = 1 THEN 1 ELSE 0 END, -- DiscountQuantity, 1 if IsDiscountItem
						0,                     -- IsUpload default
						@PropertyId,           -- Provided property ID
						@UserId,               -- CreatedUserId
						GETDATE(),              -- CreatedDateTime
						IsBuyItem,
						IsDiscountItem
					FROM #TempDiscountBuyNGetN;
				END

				INSERT INTO [dbo].[DiscountItemType]([Code],[ItemTypeCode],[SysDate],PropertyId)
				SELECT @Code,ItemTypeCode,GETDATE(),@PropertyId FROM  #TempItemsTypes

				INSERT INTO [dbo].[DiscountItemCategory]([Code],CategoryCode,[SysDate],[PropertyId])
				SELECT @Code,CategoryCode,GETDATE(),@PropertyId FROM  #TempDiscountItemCategory

				INSERT INTO [dbo].[DiscountBinNumbers]([Code],BinNumber,CreatedUserId,[CreatedDateTime],[PropertyId])
				SELECT @Code,BinNumber,@UserId,GETDATE(),@PropertyId FROM  #TempDiscountBinNumbers

				INSERT INTO [dbo].[DiscountPayment]([Code],PayType,[PropertyId])
				SELECT @Code,PayType,@PropertyId FROM  #TempDiscountPayment


				INSERT INTO [dbo].[DiscountMember]([Code],MemberCode,PropertyId)
				SELECT @Code,MemberCode,@PropertyId FROM  #TempDiscountMember

				INSERT INTO [dbo].[DiscountChannel]([Code],ChannelCode,PropertyId)
				SELECT @Code,ChannelCode,@PropertyId FROM  #TempDiscountChannel

				INSERT INTO [dbo].[DiscountCustomerGroup]([DiscountCode],CustomerGroupId,PropertyId)
				SELECT @Code,CustomerGroupId,@PropertyId FROM  #TempDiscountCustomerGroup

				IF( @DiscountTierJson IS NOT NULL )
				BEGIN
					INSERT INTO [dbo].[DiscountWiseTier]([DiscountCode],TierId,PropertyId)
					SELECT @Code,TierId,@PropertyId FROM  #TempDiscountTier
				END

				-- Insert into main table
				INSERT INTO dbo.DiscountOutlet
				(
					PropertyId,
					Code,
					Outlet
				)
				SELECT
					@PropertyId,
					@Code,
					OutletCode
				FROM #TempOutlet;

				SET @Remark = 'Discount '++', '+@Description+' created.';
			END
		END
		ELSE IF(@Operation = 'U')
		BEGIN

			IF EXISTS (SELECT 1 FROM DiscountHeader where Description=@Description AND Code<>@Code AND PropertyId=@PropertyId)
			BEGIN
				RAISERROR('Discount Description already exists',16,1)
			END
			ELSE
			BEGIN

				-- Audit trail ----------------------------
				EXEC HotelResWeb_AuditTail_WriteToLog 'DiscountHeader',@Id,'POS','POSDHU','U',@UserId,'','','','','',@PropertyId
				-- End of Audit trail ---------------------

				UPDATE DiscountHeader
				SET
				Code=@Code,
				Description=@Description,
				TimeFrom=CONVERT(TIME, @TimeFrom,108),
				TimeTo=CONVERT(TIME,@TimeTo,108),
				DateFrom=@DateFrom,
				DateTo=@DateTo,
				Percentage=isnull(@DiscountPercent,0),
				IsAutoApply=@IsAutoApply,
				IsAuthorization=@IsAuthorization,
				IsDay=@IsDay,
				SysDate=GETDATE(),
				ValidationMode=@InsertValidationModeCode,
				DiscountType=@DiscountType,
				IsNeedRemark=@IsNeedRemark,
				IsValidatePayType=@IsValidatePayType,
				DiscountValue=Isnull(@Discount,0),
				IsActive=@IsActive,
				UpdatedUserId=@UserId,
				UpdatedDateTime=GETDATE(),
				IsPercentage=@IsPercentage,
				OutletListJson=@OutletJson,
				MenuItemJson=@MenuItemsJson,
				DaysJson=@DisCountDaysJson,
				IsItemWiseDiscount=@IsItemWiseDiscount,
				IsUpload=0	,
				ValidationModesId = CONVERT(int,@ValidationMode),
				IsApplyAllItems = @IsApplyAllItems,
				MinimumAmount = @MinimumAmount,
				MaximumDiscount = @MaximumDiscount,
				BuyQuantity = @BuyItemQty,
				FreeQuantity = @DiscountItemQty
				WHERE Code=@Code AND PropertyId=@PropertyId

				DELETE FROM DiscountDays WHERE Code=@Code AND PropertyId=@PropertyId

				IF( @IsDay = 1 )
				BEGIN

					IF EXISTS (SELECT 1 FROM #TempDiscountDays)
					BEGIN


						INSERT INTO DiscountDays(Code, DayName, SysDate,PropertyId)
						SELECT @Code,Name,GETDATE(),@PropertyId  FROM #TempDiscountDays
					END

				END



				IF  (@ValidationModeCode IN ('ITM','SOCG','AITM'))
				BEGIN

				DELETE FROM DiscountDetails WHERE Code=@Code AND PropertyId=@PropertyId

				IF OBJECT_ID('tempdb..#TempItems') IS NOT NULL
				INSERT INTO DiscountDetails( Code, OrderType, MenuItemID, DiscountPercentage, DiscountValue, BuyQuantity, DiscountQuantity, IsUpload, PropertyId, CreatedUserId, CreatedDateTime)
				SELECT @Code,'',ItemCode,isnull(@DiscountPercent,0),Isnull(@Discount,0),0,0,0,@PropertyId,@UserId,GETDATE() FROM #TempItems

				END

				IF  (@ValidationModeCode='FITM')
				BEGIN

				    DELETE FROM DiscountDetails WHERE Code=@Code AND PropertyId=@PropertyId

					INSERT INTO DiscountDetails
					(
						Code,
						OrderType,
						MenuItemID,
						DiscountPercentage,
						DiscountValue,
						BuyQuantity,
						DiscountQuantity,
						IsUpload,
						PropertyId,
						CreatedUserId,
						CreatedDateTime,
						IsBuyItem,
						IsDiscountItem
					)
					SELECT
						Code,                  -- from temp table
						'',                    -- OrderType empty
						ItemCode,              -- MenuItemID mapped from ItemCode
						DiscountPercentage,    -- Discount %
						ISNULL(DiscountValue, 0),  -- Discount value (fallback 0)
						CASE WHEN IsBuyItem = 1 THEN 1 ELSE 0 END,      -- BuyQuantity, e.g., 1 if IsBuyItem
						CASE WHEN IsDiscountItem = 1 THEN 1 ELSE 0 END, -- DiscountQuantity, 1 if IsDiscountItem
						0,                     -- IsUpload default
						@PropertyId,           -- Provided property ID
						@UserId,               -- CreatedUserId
						GETDATE(),              -- CreatedDateTime
						IsBuyItem,
						IsDiscountItem
					FROM #TempDiscountBuyNGetN;
				END


				DELETE FROM DiscountItemType WHERE Code=@Code

				INSERT INTO [dbo].[DiscountItemType]([Code],[ItemTypeCode],[SysDate],PropertyId)
				SELECT @Code,ItemTypeCode,GETDATE(),@PropertyId FROM  #TempItemsTypes

				DELETE FROM DiscountItemCategory WHERE Code=@Code  AND [PropertyId] = @PropertyId

				INSERT INTO [dbo].[DiscountItemCategory]([Code],CategoryCode,[SysDate],[PropertyId])
				SELECT @Code,CategoryCode,GETDATE(),@PropertyId FROM  #TempDiscountItemCategory


				DELETE FROM DiscountBinNumbers WHERE Code=@Code  AND [PropertyId] = @PropertyId

				INSERT INTO [dbo].[DiscountBinNumbers]([Code],BinNumber,CreatedUserId,[CreatedDateTime],[PropertyId])
				SELECT @Code,BinNumber,@UserId,GETDATE(),@PropertyId FROM  #TempDiscountBinNumbers

				DELETE FROM [DiscountPayment] WHERE Code=@Code  AND [PropertyId] = @PropertyId

				INSERT INTO [dbo].[DiscountPayment]([Code],PayType,[PropertyId])
				SELECT @Code,PayType,@PropertyId FROM  #TempDiscountPayment

				DELETE FROM [DiscountMember] WHERE Code=@Code  AND [PropertyId] = @PropertyId

				INSERT INTO [dbo].[DiscountMember]([Code],MemberCode,PropertyId)
				SELECT @Code,MemberCode,@PropertyId FROM  #TempDiscountMember


				DELETE FROM [DiscountChannel] WHERE Code=@Code  AND [PropertyId] = @PropertyId

				INSERT INTO [dbo].[DiscountChannel]([Code],ChannelCode,PropertyId)
				SELECT @Code,ChannelCode,@PropertyId FROM  #TempDiscountChannel


				DELETE FROM [DiscountCustomerGroup] WHERE DiscountCode=@Code  AND [PropertyId] = @PropertyId

				INSERT INTO [dbo].[DiscountCustomerGroup]([DiscountCode],CustomerGroupId,PropertyId)
				SELECT @Code,CustomerGroupId,@PropertyId FROM  #TempDiscountCustomerGroup

				-- Tiers are rewritten only when the screen actually sent them
				IF( @DiscountTierJson IS NOT NULL )
				BEGIN
					DELETE FROM [DiscountWiseTier] WHERE DiscountCode=@Code  AND [PropertyId] = @PropertyId

					INSERT INTO [dbo].[DiscountWiseTier]([DiscountCode],TierId,PropertyId)
					SELECT @Code,TierId,@PropertyId FROM  #TempDiscountTier
				END


				DELETE FROM DiscountOutlet WHERE Code=@Code  AND [PropertyId] = @PropertyId
				-- Insert into main table
				INSERT INTO dbo.DiscountOutlet
				(
					PropertyId,
					Code,
					Outlet
				)
				SELECT
					@PropertyId,
					@Code,
					OutletCode
				FROM #TempOutlet;

				-- audit trail
				SET @Remark = 'Discount '++', '+@Description+' updated.';
				-- end of audit trail
			END

		END
	EXEC Insert_Sync_MasterDataTransferStatus 'Discount',@IsActive,@Code,@PropertyId

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @Message NVARCHAR(100)
	SET @Message = N'Record Not Save. ''' + ERROR_MESSAGE() + ''''
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	RAISERROR(@Message,16,1)
END CATCH

GO

