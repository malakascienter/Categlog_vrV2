-- =============================================
-- Author:		Nivesh
-- Create date: 2023-12-15
-- Description:	Update Save Discount Details
-- Edited 2026-09-24 : the U branch matched rows on Code + PropertyId, so editing one
--                     discount overwrote every discount sharing that Code (Ids 5/6 and
--                     7/8 in Categlog_vrV2 became identical copies). It now matches on
--                     @Id; the duplicate-description check excludes the row by Id.
-- Edited 2026-09-25 : validation mode targeting (step 7 of 8, needs scripts 01-06).
--   1. New parameters @ValidationModeId and @TargetsJson (both optional, so older
--      callers still work unchanged).
--   2. The mode Id is saved in DiscountHeader.ValidationModesId. The mode Code is
--      saved in DiscountHeader.ValidationMode when INV_ValidationModeSettings.SaveCodeInHeader = 1.
--   3. When @TargetsJson is sent, the targeting rows are checked against the same
--      rules the screen uses (INV_ValidationModeSections / INV_DiscountSectionTypes /
--      INV_DiscountSectionFields) and saved per section:
--        ITEMS, BUYNGETN -> DiscountDetails        ITEMTYPES  -> DiscountItemType
--        PAYTYPES        -> DiscountPayment        CATEGORIES -> INV_DiscountItemCategory
--        BINNUMBERS      -> INV_DiscountBinNumbers MEMBERS    -> INV_DiscountMember
--        CUSTGROUPS      -> INV_DiscountCustomerGroup
--        BUYQTY / FREEQTY -> DiscountHeader.BuyQuantity / FreeQuantity
--   4. The error message is no longer cut at 100 characters, and a '%' in it is
--      no longer read as a format code.
--   To go back to the previous version, run update scripts/54_ALTER_SP_Discounts_Update_Save_UpdateById.sql
--
-- @TargetsJson example:
-- { "Rows": [ { "Section": "BUYNGETN", "Code": "1001", "Fields": { "ISBUY": true, "ISDISC": false, "PCT": 0, "VALUE": 0 } } ],
--   "SectionFields": [ { "Section": "BUYNGETN", "Field": "BUYQTY", "Value": "2" } ] }
-- =============================================

CREATE PROCEDURE [dbo].[SP_Discounts_Update_Save]
	@Id INT,
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
	@IsApplyAllItems		BIT,
	@ValidationMode			VARCHAR(5),
	@DiscountType			VARCHAR(2),
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
	@MaxDiscountAmount		numeric(18, 2),
	@MinInvoiceAmount		numeric(18, 2),
	-- Added 2026-09-25: validation mode targeting
	@ValidationModeId		INT = NULL,
	@TargetsJson			NVARCHAR(MAX) = NULL
AS
BEGIN	TRY
SET XACT_ABORT ON
BEGIN TRANSACTION
	DECLARE @Discount DECIMAL(18,2)
	DECLARE @DiscountPercent  DECIMAL(18,2)
	DECLARE @Percentage DECIMAL(18,2)
	DECLARE	@RowcountTempLocations int =0;
	------------------------- Added by Nivesh 2024-03-13
	DECLARE @InsertedIDs_DiscountWiseDates TABLE (ID INT);
	DECLARE @tempDiWiDa int = null
	DECLARE @InsertedIDs_LocationWiseDiscount TABLE (ID INT);
	DECLARE @tempLoWiDi int = null
	------------------------
	------------------------- Added 2026-09-25: validation mode targeting
	DECLARE @ValidationModeCode	VARCHAR(10) = NULL
	DECLARE @SaveCodeInHeader	BIT = 1
	DECLARE @UseTargets			BIT = CASE WHEN @TargetsJson IS NULL THEN 0 ELSE 1 END
	DECLARE @BuyQuantity		NUMERIC(18,2) = 0
	DECLARE @FreeQuantity		NUMERIC(18,2) = 0
	DECLARE @TargetMsg			NVARCHAR(400) = NULL
	------------------------
	IF (@IsPercentage=1)
	BEGIN
		SET @Percentage=@DiscountValue
		SET @DiscountPercent=@Percentage
	END
	ELSE
	BEGIN
		SET @Percentage=0
		SET @Discount=@DiscountValue
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

	SELECT * INTO #TempLocations
	FROM OPENJSON(@outletJson)
	WITH(
	Code VARCHAR(5) '$.Code'
	)


	CREATE TABLE #TempItemsTypes
	(
      ItemTypeCode   VARCHAR(10)
	)


    IF( @MenuItemsTypes != '' )
    BEGIN
		INSERT INTO #TempItemsTypes (ItemTypeCode)
        SELECT ItemTypeCode
		FROM OPENJSON(@MenuItemsTypes)
		WITH
		(
			ItemTypeCode   VARCHAR(10) '$.ItemTypeCode'
		)

    END

	-------------------------------------------------------------------------
	-- Added 2026-09-25: resolve the validation mode.
	-- The new screen sends @ValidationModeId; older callers send only the Code.
	-------------------------------------------------------------------------
	IF ISNULL(@ValidationModeId, 0) = 0
		SELECT TOP (1) @ValidationModeId = Id
		  FROM dbo.ValidationModes
		 WHERE LTRIM(RTRIM(Code)) = LTRIM(RTRIM(ISNULL(@ValidationMode, '')))
		   AND PropertyId = @PropertyId
		 ORDER BY Id

	SELECT @ValidationModeCode = LTRIM(RTRIM(vm.Code)),
	       @SaveCodeInHeader   = ISNULL(st.SaveCodeInHeader, 1)
	  FROM dbo.ValidationModes vm
	  LEFT JOIN dbo.INV_ValidationModeSettings st ON st.ValidationModeId = vm.Id
	 WHERE vm.Id = @ValidationModeId

	IF @ValidationModeCode IS NOT NULL
		SET @ValidationMode = CASE WHEN @SaveCodeInHeader = 1 THEN LEFT(@ValidationModeCode, 5) ELSE '' END

	SET @ValidationModeId = ISNULL(@ValidationModeId, 0)

	-------------------------------------------------------------------------
	-- Added 2026-09-25: read and check the targeting rows (new screen only).
	-- The rules are the same ones the screen uses, read from the INV_ config tables.
	-------------------------------------------------------------------------
	CREATE TABLE #Targets
	(
		RowNo	INT IDENTITY(1,1),
		Section	VARCHAR(20)   COLLATE DATABASE_DEFAULT,
		Code	NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		Fields	NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
	)

	CREATE TABLE #SectionFields
	(
		Section	VARCHAR(20)   COLLATE DATABASE_DEFAULT,
		Field	VARCHAR(20)   COLLATE DATABASE_DEFAULT,
		Value	NVARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	IF @UseTargets = 1
	BEGIN
		IF ISJSON(@TargetsJson) = 0
			RAISERROR('Targeting data is not valid.', 16, 1)

		INSERT INTO #Targets (Section, Code, Fields)
		SELECT LTRIM(RTRIM(Section)), LTRIM(RTRIM(Code)), Fields
		  FROM OPENJSON(@TargetsJson, '$.Rows')
		  WITH
		  (
			Section	VARCHAR(20)		'$.Section',
			Code	NVARCHAR(100)	'$.Code',
			Fields	NVARCHAR(MAX)	'$.Fields' AS JSON
		  )

		INSERT INTO #SectionFields (Section, Field, Value)
		SELECT LTRIM(RTRIM(Section)), LTRIM(RTRIM(Field)), LTRIM(RTRIM(Value))
		  FROM OPENJSON(@TargetsJson, '$.SectionFields')
		  WITH
		  (
			Section	VARCHAR(20)		'$.Section',
			Field	VARCHAR(20)		'$.Field',
			Value	NVARCHAR(100)	'$.Value'
		  )

		-- Ignore rows and fields of sections that don't belong to this mode, empty values and duplicates
		DELETE FROM #Targets
		 WHERE NOT EXISTS (SELECT 1
		                     FROM dbo.INV_ValidationModeSections s
		                     JOIN dbo.INV_DiscountSectionTypes t ON t.Id = s.SectionTypeId AND t.IsActive = 1
		                    WHERE s.ValidationModeId = @ValidationModeId
		                      AND t.SectionCode = #Targets.Section)

		DELETE FROM #SectionFields
		 WHERE NOT EXISTS (SELECT 1
		                     FROM dbo.INV_ValidationModeSections s
		                     JOIN dbo.INV_DiscountSectionTypes t ON t.Id = s.SectionTypeId AND t.IsActive = 1
		                    WHERE s.ValidationModeId = @ValidationModeId
		                      AND t.SectionCode = #SectionFields.Section)

		DELETE FROM #Targets WHERE ISNULL(Code, '') = ''

		;WITH Dup AS
		(
			SELECT ROW_NUMBER() OVER (PARTITION BY Section, Code ORDER BY RowNo) AS Rn
			  FROM #Targets
		)
		DELETE FROM Dup WHERE Rn > 1

		-- a) required sections
		SELECT TOP (1) @TargetMsg = ISNULL(s.RequiredMessage, 'Please fill ' + t.Title + '.')
		  FROM dbo.INV_ValidationModeSections s
		  JOIN dbo.INV_DiscountSectionTypes t ON t.Id = s.SectionTypeId AND t.IsActive = 1
		 WHERE s.ValidationModeId = @ValidationModeId
		   AND s.IsRequired = 1
		   AND NOT EXISTS (SELECT 1 FROM #Targets x WHERE x.Section = t.SectionCode)
		 ORDER BY s.SortOrder

		-- b) value too long or in the wrong format
		IF @TargetMsg IS NULL
			SELECT TOP (1) @TargetMsg = t.Title + ': value ''' + LEFT(x.Code, 50) + ''' is not valid.'
			  FROM #Targets x
			  JOIN dbo.INV_DiscountSectionTypes t ON t.SectionCode = x.Section
			 WHERE LEN(x.Code) > ISNULL(t.ValueMaxLength, 100)
			    OR (t.ValueFormat = 'DIGITS'   AND x.Code LIKE '%[^0-9]%')
			    OR (t.ValueFormat = 'ALPHANUM' AND x.Code LIKE '%[^A-Za-z0-9]%')
			 ORDER BY x.RowNo

		-- c) too many rows
		IF @TargetMsg IS NULL
			SELECT TOP (1) @TargetMsg = t.Title + ': no more than ' + CONVERT(VARCHAR(10), t.MaxRows) + ' rows are allowed.'
			  FROM dbo.INV_DiscountSectionTypes t
			 WHERE t.MaxRows IS NOT NULL
			   AND (SELECT COUNT(*) FROM #Targets x WHERE x.Section = t.SectionCode) > t.MaxRows

		-- d) section fields (e.g. Buy Item Qty): required, number range, text length
		IF @TargetMsg IS NULL
			SELECT TOP (1) @TargetMsg = t.Title + ': ' + f.Label + ' is required or out of range.'
			  FROM dbo.INV_ValidationModeSections s
			  JOIN dbo.INV_DiscountSectionTypes  t ON t.Id = s.SectionTypeId AND t.IsActive = 1
			  JOIN dbo.INV_DiscountSectionFields f ON f.SectionTypeId = t.Id AND f.Scope = 'SECTION' AND f.IsActive = 1
			  LEFT JOIN #SectionFields v ON v.Section = t.SectionCode AND v.Field = f.FieldCode
			 WHERE s.ValidationModeId = @ValidationModeId
			   AND (   (f.IsRequired = 1 AND f.InputType <> 'checkbox' AND ISNULL(v.Value, '') = '')
			        OR (f.InputType = 'number' AND ISNULL(v.Value, '') <> ''
			            AND (   TRY_CONVERT(DECIMAL(18,2), v.Value) IS NULL
			                 OR TRY_CONVERT(DECIMAL(18,2), v.Value) < ISNULL(f.MinValue, -999999999)
			                 OR TRY_CONVERT(DECIMAL(18,2), v.Value) > ISNULL(f.MaxValue,  999999999)))
			        OR (f.InputType = 'text' AND f.MaxLength IS NOT NULL AND LEN(ISNULL(v.Value, '')) > f.MaxLength))
			 ORDER BY s.SortOrder, f.SortOrder

		-- e) row fields (e.g. Discount % on a Buy N Get N row): required, number range
		IF @TargetMsg IS NULL
			SELECT TOP (1) @TargetMsg = t.Title + ': ' + f.Label + ' is required or out of range for ''' + LEFT(x.Code, 50) + '''.'
			  FROM #Targets x
			  JOIN dbo.INV_DiscountSectionTypes  t ON t.SectionCode = x.Section
			  JOIN dbo.INV_DiscountSectionFields f ON f.SectionTypeId = t.Id AND f.Scope = 'ROW' AND f.IsActive = 1
			 OUTER APPLY (SELECT j.[value] AS Value
			                FROM OPENJSON(ISNULL(x.Fields, N'{}')) j
			               			              WHERE j.[key] COLLATE DATABASE_DEFAULT = f.FieldCode) v
			 WHERE (   (f.IsRequired = 1 AND f.InputType <> 'checkbox' AND ISNULL(v.Value, '') = '')
			        OR (f.InputType = 'number' AND ISNULL(v.Value, '') <> ''
			            AND (   TRY_CONVERT(DECIMAL(18,2), v.Value) IS NULL
			                 OR TRY_CONVERT(DECIMAL(18,2), v.Value) < ISNULL(f.MinValue, -999999999)
			                 OR TRY_CONVERT(DECIMAL(18,2), v.Value) > ISNULL(f.MaxValue,  999999999))))
			 ORDER BY x.RowNo, f.SortOrder

		IF @TargetMsg IS NOT NULL
		BEGIN
			SET @TargetMsg = REPLACE(@TargetMsg, '%', '%%')   -- '%' in a label (e.g. 'Discount %') is not a format code
			RAISERROR(@TargetMsg, 16, 1)
		END

		-- Buy N Get N quantities go to the header
		SELECT @BuyQuantity  = ISNULL(TRY_CONVERT(NUMERIC(18,2), Value), 0) FROM #SectionFields WHERE Section = 'BUYNGETN' AND Field = 'BUYQTY'
		SELECT @FreeQuantity = ISNULL(TRY_CONVERT(NUMERIC(18,2), Value), 0) FROM #SectionFields WHERE Section = 'BUYNGETN' AND Field = 'FREEQTY'

		-- Selected items are also kept in the header JSON, as the POS does
		SET @MenuItemsJson = ISNULL((SELECT Code AS ItemCode FROM #Targets WHERE Section = 'ITEMS' ORDER BY RowNo FOR JSON PATH), '')
	END

	DECLARE @Remark NVARCHAR(250)

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
			ELSE
				BEGIN

				INSERT INTO  DiscountHeader
				(Code,
				Description,
				TimeFrom,
				TimeTo,
				DateFrom,
				DateTo,
				Percentage,
				IsAutoApply,
				IsAuthorization,
				IsDay,
				SysDate,
				ValidationMode,
				DiscountType,
				IsNeedRemark,
				IsValidatePayType,
				DiscountValue,
				IsActive,
				CreatedUserId,
				CreatedDateTime,
				OutletListJson,
				MenuItemJson,
				DaysJson,
				IsItemWiseDiscount,
				IsPercentage,
				PropertyId,
				IsUpload,
				IsApplyAllItems,
				MaxDiscountAmount,
				MinInvoiceAmount,
				UpdatedUserId,
				UpdatedDateTime,
				-- Added 2026-09-25: validation mode targeting
				ValidationModesId,
				BuyQuantity,
				FreeQuantity
				)
				VALUES
				(@Code,
				@Description,
				--CONVERT(TIME, @TimeFrom,108),
				--CONVERT(TIME,@TimeTo,108),
				@TimeFrom,
				@TimeTo,
				@DateFrom,
				@DateTo,
				isnull(@DiscountPercent,0),
				@IsAutoApply,
				@IsAuthorization,
				@IsDay,
				GetDate(),
				@ValidationMode,
				@DiscountType,
				@IsNeedRemark,
				@IsValidatePayType,
				Isnull(@Discount,0),
				@IsActive,
				@UserId,
				GETDATE(),
				@OutletJson,
				@MenuItemsJson,
				@DisCountDaysJson,
				@IsItemWiseDiscount,
				@IsPercentage,
				@PropertyId,
				0,
				@IsApplyAllItems,
				@MaxDiscountAmount,
				@MinInvoiceAmount,
				@UserId,
				getdate(),
				-- Added 2026-09-25: validation mode targeting
				@ValidationModeId,
				@BuyQuantity,
				@FreeQuantity);

				DECLARE @newDiscountId int;
				SET @newDiscountId = SCOPE_IDENTITY();
				SET @Id = @newDiscountId;
				EXEC Inventry_AuditTail_WriteToLog 'DiscountHeader', @newDiscountId, 'INV', 'DHI', 'I', @UserId,@PropertyId, '', ''
				--raiserror('reached',16,1)

					--Add discount to tempDiscountDays table
				IF EXISTS (SELECT 1 FROM #TempDiscountDays)
				BEGIN

				INSERT INTO DiscountWiseDates (DiscountId, DayName, DayId,Date)
				OUTPUT INSERTED.Id INTO @InsertedIDs_DiscountWiseDates --Added by Nivesh 2024-03-13
				SELECT @newDiscountId, Name, Id, GETDATE() from #TempDiscountDays

				WHILE EXISTS (SELECT 1 FROM @InsertedIDs_DiscountWiseDates)
				BEGIN
					SELECT TOP(1) @tempDiWiDa = Id FROM @InsertedIDs_DiscountWiseDates
					EXEC Inventry_AuditTail_WriteToLog 'DiscountWiseDates', @tempDiWiDa, 'INV', 'DWDI', 'I', @UserId,@PropertyId, '', ''
					DELETE TOP(1) FROM @InsertedIDs_DiscountWiseDates
				END


				END

				--Add DiscountwiseLocation table
				IF EXISTS (SELECT 1 FROM #TempLocations)
				BEGIN

					SELECT @RowcountTempLocations = COUNT(Code) from #TempLocations

					WHILE (@RowcountTempLocations <> 0)
					BEGIN
						SET @RowcountTempLocations = @RowcountTempLocations -1;

						INSERT INTO LocationWiseDiscount (DiscountId, DiscountCode, LocationId,CreatedUserId,CreatedDateTime,UpdateUserId,UpdatedDateTime,PropertyId,IsUpload)
						OUTPUT INSERTED.Id INTO @InsertedIDs_LocationWiseDiscount --Added by Nivesh 2024-02-26
						VALUES(@newDiscountId,@Code,(select Id from Locations where id= (select top(1) cast(Code as int) from #TempLocations)),@UserId,GETDATE(),@UserId,GETDATE(),@PropertyId,0)




						DELETE top(1) from #TempLocations
					END

					WHILE EXISTS (SELECT 1 FROM @InsertedIDs_LocationWiseDiscount)
					BEGIN
						SELECT TOP(1) @tempLoWiDi = Id FROM @InsertedIDs_LocationWiseDiscount
						EXEC Inventry_AuditTail_WriteToLog 'LocationWiseDiscount', @tempLoWiDi, 'INV', 'LWDI', 'I', @UserId,@PropertyId, '', ''
						DELETE TOP(1) FROM @InsertedIDs_LocationWiseDiscount
					END

				END

				--EXEC Inventry_AuditTail_WriteToLog 'DiscountHeader', @UserId, 'INV', 'DHU', 'U', @UserId,1, '', ''
				-- Edited 2026-09-25: item types sent by the new screen are saved in the targeting block below
				IF @UseTargets = 0
				INSERT INTO [dbo].[DiscountItemType]([Code],[ItemTypeCode],[SysDate])
				SELECT @Code,ItemTypeCode,GETDATE() FROM  #TempItemsTypes

				SET @Remark = 'Discount '++', '+@Description+' created.';
			END
		END
	ELSE IF(@Operation = 'U')
		BEGIN

			DECLARE @TempDisUpda int
			-- Edited 2026-09-24: exclude the row being edited by Id, not by Code
			--IF EXISTS (SELECT 1 FROM DiscountHeader where Description=@Description AND Code<>@Code AND PropertyId=@PropertyId)
			IF EXISTS (SELECT 1 FROM DiscountHeader where Description=@Description AND Id<>@Id AND PropertyId=@PropertyId)
			BEGIN
				RAISERROR('Discount Description already exists',16,1)
			END
			ELSE
			BEGIN


			--raiserror('Reached', 16,1)



				UPDATE DiscountHeader
				SET
				Code=@Code,
				Description=@Description,
				--TimeFrom=CONVERT(TIME, @TimeFrom,108),
				--TimeTo=CONVERT(TIME,@TimeTo,108),
				TimeFrom= @TimeFrom,
				TimeTo=@TimeTo,
				DateFrom=@DateFrom,
				DateTo=@DateTo,
				Percentage=isnull(@DiscountPercent,0),
				IsAutoApply=@IsAutoApply,
				IsAuthorization=@IsAuthorization,
				IsDay=@IsDay,
				SysDate=GETDATE(),
				ValidationMode=@ValidationMode,
				DiscountType=@DiscountType,
				IsNeedRemark=@IsNeedRemark,
				IsValidatePayType=@IsValidatePayType,
				DiscountValue=Isnull(@Discount,0),
				IsActive=@IsActive,
				UpdatedUserId=@UserId,
				createduserid= @UserId,
				UpdatedDateTime=GETDATE(),
				IsPercentage=@IsPercentage,
				OutletListJson=@OutletJson,
				MenuItemJson=@MenuItemsJson,
				DaysJson=@DisCountDaysJson,
				IsItemWiseDiscount=@IsItemWiseDiscount,
				IsUpload=0,
				isapplyallitems =@IsApplyAllItems,
				MinInvoiceAmount= @MinInvoiceAmount,
				MaxDiscountAmount=@MaxDiscountAmount,
				-- Added 2026-09-25: validation mode targeting (quantities change only when the new screen saves)
				ValidationModesId=@ValidationModeId,
				BuyQuantity=CASE WHEN @UseTargets = 1 THEN @BuyQuantity ELSE BuyQuantity END,
				FreeQuantity=CASE WHEN @UseTargets = 1 THEN @FreeQuantity ELSE FreeQuantity END
				-- Edited 2026-09-24: update only the edited discount; matching on Code overwrote every discount sharing that Code
				--WHERE Code=@Code AND PropertyId=@PropertyId
				WHERE Id=@Id AND PropertyId=@PropertyId

				-- Edited 2026-09-24: audit log the edited discount by Id
				--IF EXISTS (SELECT 1 FROM DiscountHeader WHERE Code=@Code AND PropertyId=@PropertyId)
				IF EXISTS (SELECT 1 FROM DiscountHeader WHERE Id=@Id AND PropertyId=@PropertyId)
				BEGIN
					--SELECT @TempDisUpda=ID FROM DiscountHeader WHERE Code=@Code AND PropertyId=@PropertyId
					SET @TempDisUpda=@Id
					EXEC Inventry_AuditTail_WriteToLog 'DiscountHeader', @TempDisUpda, 'INV', 'DHU', 'U', @UserId,@PropertyId, '', ''
				END
				--Add discount to tempDiscountDays table
				IF EXISTS (SELECT 1 FROM #TempDiscountDays)
				BEGIN

				DECLARE @TempDiscID INT
				SELECT @TempDiscID = id FROM DiscountWiseDates WHERE DiscountId=@Id

				EXEC Inventry_AuditTail_WriteToLog 'DiscountWiseDates', @TempDiscID, 'INV', 'DWDD', 'D', @UserId,@PropertyId, '', ''
				DELETE FROM DiscountWiseDates WHERE DiscountId=@Id



				INSERT INTO DiscountWiseDates (DiscountId, DayName, DayId,Date)
				OUTPUT INSERTED.Id INTO @InsertedIDs_DiscountWiseDates --Added by Nivesh 2024-03-13
				SELECT @Id, Name, Id, GETDATE() from #TempDiscountDays

				--EXEC Inventry_AuditTail_WriteToLog 'DiscountWiseDates', @Id, 'INV', 'DWDI', 'I', @UserId,@PropertyId, '', ''
				WHILE EXISTS (SELECT 1 FROM @InsertedIDs_DiscountWiseDates)
				BEGIN
					SELECT TOP(1) @tempDiWiDa = Id FROM @InsertedIDs_DiscountWiseDates
					EXEC Inventry_AuditTail_WriteToLog 'DiscountWiseDates', @tempDiWiDa, 'INV', 'DWDI', 'I', @UserId,@PropertyId, '', ''
					DELETE TOP(1) FROM @InsertedIDs_DiscountWiseDates
				END
				END

				--Add DiscountwiseLocation table
				IF EXISTS (SELECT 1 FROM #TempLocations)
				BEGIN

					DECLARE @TempLocDis int
					SELECT @TempLocDis= ID FROM LocationWiseDiscount WHERE DiscountId=@Id;
					DELETE FROM LocationWiseDiscount WHERE DiscountId=@Id;
					EXEC Inventry_AuditTail_WriteToLog 'LocationWiseDiscount', @TempLocDis, 'INV', 'LWDD', 'D', @UserId,@PropertyId, '', ''

					SELECT @RowcountTempLocations = COUNT(Code) from #TempLocations

					WHILE (@RowcountTempLocations <> 0)
					BEGIN
						SET @RowcountTempLocations = @RowcountTempLocations -1;

						INSERT INTO LocationWiseDiscount (DiscountId, DiscountCode, LocationId,CreatedUserId,CreatedDateTime,UpdateUserId,UpdatedDateTime,PropertyId,IsUpload)
						OUTPUT INSERTED.Id INTO @InsertedIDs_LocationWiseDiscount --Added by Nivesh 2024-03-13
						VALUES(@Id,@Code,(select Id from Locations where id= (select top(1) cast(Code as int) from #TempLocations)),@UserId,GETDATE(),@UserId,GETDATE(),@PropertyId,0)

						DELETE top(1) from #TempLocations
					END
				WHILE EXISTS (SELECT 1 FROM @InsertedIDs_LocationWiseDiscount)
				BEGIN
					SELECT TOP(1) @tempDiWiDa = Id FROM @InsertedIDs_LocationWiseDiscount
					EXEC Inventry_AuditTail_WriteToLog 'LocationWiseDiscount', @tempDiWiDa, 'INV', 'LWDI', 'I', @UserId,@PropertyId, '', ''
					DELETE TOP(1) FROM @InsertedIDs_LocationWiseDiscount
				END


				END

				--Add DiscountType table
				--EXEC Inventry_AuditTail_WriteToLog 'DiscountItemType', '', 'INV', 'DITD', 'D', @UserId,@PropertyId, '', ''
				-- Edited 2026-09-25: item types sent by the new screen are saved in the targeting block below
				IF @UseTargets = 0
				BEGIN
					DELETE FROM DiscountItemType WHERE Code=@Code

					INSERT INTO [dbo].[DiscountItemType]([Code],[ItemTypeCode],[SysDate])
					SELECT @Code,ItemTypeCode,GETDATE() FROM  #TempItemsTypes
				END
				-- audit trail
				SET @Remark = 'Discount '++', '+@Description+' updated.';
				--EXEC Inventry_AuditTail_WriteToLog 'DiscountItemType', '', 'INV', 'DITI', 'I', @UserId,@PropertyId, '', ''
			END

		END

		-------------------------------------------------------------------------
		-- Added 2026-09-25: save the targeting sections (new screen only).
		-- Every section is cleared first, so the rows of an old mode are removed
		-- when the mode changes.
		-------------------------------------------------------------------------
		IF @UseTargets = 1 AND ISNULL(@Id, 0) > 0
		BEGIN
			-- ITEMS and BUYNGETN -> DiscountDetails (keyed on Code, as the POS does)
			DELETE FROM dbo.DiscountDetails WHERE Code = @Code AND PropertyId = @PropertyId

			INSERT INTO dbo.DiscountDetails
				(Code, OrderType, MenuItemID, DiscountPercentage, DiscountValue, BuyQuantity, DiscountQuantity,
				 IsUpload, PropertyId, CreatedUserId, CreatedDateTime, IsBuyItem, IsDiscountItem)
			SELECT @Code, '', LEFT(x.Code, 10), ISNULL(@DiscountPercent, 0), ISNULL(@Discount, 0), 0, 0,
			       0, @PropertyId, @UserId, GETDATE(), 0, 0
			  FROM #Targets x
			 WHERE x.Section = 'ITEMS'
			 ORDER BY x.RowNo

			INSERT INTO dbo.DiscountDetails
				(Code, OrderType, MenuItemID, DiscountPercentage, DiscountValue, BuyQuantity, DiscountQuantity,
				 IsUpload, PropertyId, CreatedUserId, CreatedDateTime, IsBuyItem, IsDiscountItem)
			SELECT @Code, '', LEFT(x.Code, 10),
			       ISNULL(TRY_CONVERT(NUMERIC(18,2), JSON_VALUE(x.Fields, '$.PCT')), 0),
			       ISNULL(TRY_CONVERT(NUMERIC(18,2), JSON_VALUE(x.Fields, '$.VALUE')), 0),
			       CASE WHEN JSON_VALUE(x.Fields, '$.ISBUY')  IN ('true', '1') THEN 1 ELSE 0 END,   -- BuyQuantity, as the POS does
			       CASE WHEN JSON_VALUE(x.Fields, '$.ISDISC') IN ('true', '1') THEN 1 ELSE 0 END,   -- DiscountQuantity, as the POS does
			       0, @PropertyId, @UserId, GETDATE(),
			       CASE WHEN JSON_VALUE(x.Fields, '$.ISBUY')  IN ('true', '1') THEN 1 ELSE 0 END,
			       CASE WHEN JSON_VALUE(x.Fields, '$.ISDISC') IN ('true', '1') THEN 1 ELSE 0 END
			  FROM #Targets x
			 WHERE x.Section = 'BUYNGETN'
			 ORDER BY x.RowNo

			-- ITEMTYPES -> DiscountItemType
			DELETE FROM dbo.DiscountItemType WHERE Code = @Code AND (PropertyId = @PropertyId OR PropertyId IS NULL)

			INSERT INTO dbo.DiscountItemType (Code, ItemTypeCode, SysDate, PropertyId)
			SELECT @Code, LEFT(x.Code, 2), GETDATE(), @PropertyId
			  FROM #Targets x
			 WHERE x.Section = 'ITEMTYPES'
			 ORDER BY x.RowNo

			-- PAYTYPES -> DiscountPayment
			DELETE FROM dbo.DiscountPayment WHERE Code = @Code AND (PropertyId = @PropertyId OR PropertyId IS NULL)

			INSERT INTO dbo.DiscountPayment (Code, PayType, PropertyId)
			SELECT @Code, LEFT(x.Code, 2), @PropertyId
			  FROM #Targets x
			 WHERE x.Section = 'PAYTYPES'
			 ORDER BY x.RowNo

			-- CATEGORIES -> INV_DiscountItemCategory
			DELETE FROM dbo.INV_DiscountItemCategory WHERE DiscountId = @Id AND PropertyId = @PropertyId

			INSERT INTO dbo.INV_DiscountItemCategory (DiscountId, DiscountCode, CategoryCode, PropertyId, CreatedUserId)
			SELECT @Id, @Code, LEFT(x.Code, 50), @PropertyId, @UserId
			  FROM #Targets x
			 WHERE x.Section = 'CATEGORIES'
			 ORDER BY x.RowNo

			-- BINNUMBERS -> INV_DiscountBinNumbers
			DELETE FROM dbo.INV_DiscountBinNumbers WHERE DiscountId = @Id AND PropertyId = @PropertyId

			INSERT INTO dbo.INV_DiscountBinNumbers (DiscountId, DiscountCode, BinNumber, PropertyId, CreatedUserId)
			SELECT @Id, @Code, LEFT(x.Code, 10), @PropertyId, @UserId
			  FROM #Targets x
			 WHERE x.Section = 'BINNUMBERS'
			 ORDER BY x.RowNo

			-- MEMBERS -> INV_DiscountMember
			DELETE FROM dbo.INV_DiscountMember WHERE DiscountId = @Id AND PropertyId = @PropertyId

			INSERT INTO dbo.INV_DiscountMember (DiscountId, DiscountCode, MemberCode, PropertyId, CreatedUserId)
			SELECT @Id, @Code, LEFT(x.Code, 20), @PropertyId, @UserId
			  FROM #Targets x
			 WHERE x.Section = 'MEMBERS'
			 ORDER BY x.RowNo

			-- CUSTGROUPS -> INV_DiscountCustomerGroup
			DELETE FROM dbo.INV_DiscountCustomerGroup WHERE DiscountId = @Id AND PropertyId = @PropertyId

			INSERT INTO dbo.INV_DiscountCustomerGroup (DiscountId, DiscountCode, CustomerGroupId, PropertyId, CreatedUserId)
			SELECT @Id, @Code, TRY_CONVERT(BIGINT, x.Code), @PropertyId, @UserId
			  FROM #Targets x
			 WHERE x.Section = 'CUSTGROUPS'
			   AND TRY_CONVERT(BIGINT, x.Code) IS NOT NULL
			 ORDER BY x.RowNo
		END


		 Declare @LocationJson VARCHAR(MAX)
		 SET @LocationJson = (SELECT  Id AS LocationID FROM Locations WHERE IsActive = 1 AND CompanyID = @PropertyID AND IsSalesLocation = 1 FOR JSON PATH,INCLUDE_NULL_VALUES)
		 EXEC RT_SYNC_DATA_INSERT @PropertyID,@Id,@Code,'Discount',1,0,@LocationJson


COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	-- Edited 2026-09-25: NVARCHAR(100) cut longer messages; '%s' keeps a '%' in the message from being read as a format code
	--DECLARE @Message NVARCHAR(100)
	DECLARE @Message NVARCHAR(400)
	SET @Message = 'Error Occured: ' +  ERROR_MESSAGE() + ''''
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	--RAISERROR(@Message,16,1)
	RAISERROR('%s',16,1,@Message)
END CATCH

GO

