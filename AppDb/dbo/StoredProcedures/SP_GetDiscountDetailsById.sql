CREATE PROCEDURE dbo.SP_GetDiscountDetailsById
    @Id         INT,
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ModeId      INT = 0;
    DECLARE @HasBuyNGetN BIT = 0;

    SELECT @ModeId = ISNULL(NULLIF(h.ValidationModesId, 0),
                            (SELECT TOP (1) vm.Id
                               FROM dbo.ValidationModes vm
                              WHERE LTRIM(RTRIM(vm.Code)) = LTRIM(RTRIM(h.ValidationMode))
                                AND vm.PropertyId = h.PropertyId
                              ORDER BY vm.Id))
      FROM dbo.DiscountHeader h
     WHERE h.Id = @Id AND h.PropertyId = @PropertyId;

    SET @ModeId = ISNULL(@ModeId, 0);

    -- DiscountDetails rows are Buy N Get N rows when the mode has that section, item rows otherwise
    IF EXISTS (SELECT 1
                 FROM dbo.INV_ValidationModeSections s
                 JOIN dbo.INV_DiscountSectionTypes t ON t.Id = s.SectionTypeId
                WHERE s.ValidationModeId = @ModeId AND t.SectionCode = 'BUYNGETN')
        SET @HasBuyNGetN = 1;

    SELECT h.Id,
           LTRIM(RTRIM(h.Code))                                          AS Code,
           h.Description,
           CONVERT(VARCHAR(8), TRY_CONVERT(TIME, h.TimeFrom), 108)       AS TimeFrom,
           CONVERT(VARCHAR(8), TRY_CONVERT(TIME, h.TimeTo), 108)         AS TimeTo,
           h.DateFrom,
           h.DateTo,
           ISNULL(h.Percentage, 0)                                       AS Percentage,
           h.IsAutoApply,
           h.IsAuthorization,
           h.IsDay,
           h.SysDate,
           h.ValidationMode,
           h.DiscountType,
           h.IsNeedRemark,
           h.IsValidatePayType,
           ISNULL(CASE WHEN h.IsPercentage = 1 THEN h.Percentage ELSE h.DiscountValue END, 0) AS DiscountValue,
           ISNULL(h.IsActive, 0)                                         AS IsActive,
           h.MenuItemJson,
           h.OutletListJson                                              AS OutletJson,
           h.DaysJson                                                    AS DiscountDaysJson,
           ISNULL(h.IsItemWiseDiscount, 0)                               AS IsItemWiseDiscount,
           ISNULL(h.IsPercentage, 0)                                     AS IsPercentage,
           ISNULL(h.IsUpload, 0)                                         AS IsUpload,
           h.PropertyId,
           @ModeId                                                       AS ValidationModeID,
           ISNULL(h.CreatedUserId, 0)                                    AS CreatedUserId,
           h.CreatedDateTime,
           ISNULL(h.UpdatedUserId, 0)                                    AS UpdatedUserId,
           h.UpdatedDateTime,
           ISNULL(h.IsApplyAllItems, 0)                                  AS IsApplyAllItems,
           ISNULL(h.MinInvoiceAmount, 0)                                AS MinInvoiceAmount,
           ISNULL(h.MaxDiscountAmount, 0)                                AS MaxDiscountAmount,
           ISNULL(h.BuyQuantity, 0)                                      AS BuyQuantity,
           ISNULL(h.FreeQuantity, 0)                                     AS FreeQuantity,
           (SELECT
                (SELECT x.Section, x.Code, JSON_QUERY(x.Fields) AS Fields
                   FROM (
                         SELECT 'ITEMS' AS Section, LTRIM(RTRIM(d.MenuItemID)) AS Code,
                                CAST(NULL AS NVARCHAR(MAX)) AS Fields, 1 AS Ord, CAST(d.Id AS BIGINT) AS RowId
                           FROM dbo.DiscountDetails d
                          WHERE d.Code = h.Code AND d.PropertyId = h.PropertyId AND @HasBuyNGetN = 0
                         UNION ALL
                         SELECT 'BUYNGETN', LTRIM(RTRIM(d.MenuItemID)),
                                (SELECT CAST(d.IsBuyItem AS BIT)          AS ISBUY,
                                        CAST(d.IsDiscountItem AS BIT)     AS ISDISC,
                                        d.DiscountPercentage              AS PCT,
                                        d.DiscountValue                   AS VALUE
                                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
                                2, CAST(d.Id AS BIGINT)
                           FROM dbo.DiscountDetails d
                          WHERE d.Code = h.Code AND d.PropertyId = h.PropertyId AND @HasBuyNGetN = 1
                         UNION ALL
                         SELECT 'ITEMTYPES', LTRIM(RTRIM(it.ItemTypeCode)), NULL, 3, 0
                           FROM dbo.DiscountItemType it
                          WHERE it.Code = h.Code AND (it.PropertyId = h.PropertyId OR it.PropertyId IS NULL)
                         UNION ALL
                         SELECT 'PAYTYPES', LTRIM(RTRIM(p.PayType)), NULL, 4, 0
                           FROM dbo.DiscountPayment p
                          WHERE p.Code = h.Code AND (p.PropertyId = h.PropertyId OR p.PropertyId IS NULL)
                         UNION ALL
                         SELECT 'CATEGORIES', c.CategoryCode, NULL, 5, c.Id
                           FROM dbo.INV_DiscountItemCategory c
                          WHERE c.DiscountId = h.Id AND c.PropertyId = h.PropertyId
                         UNION ALL
                         SELECT 'BINNUMBERS', b.BinNumber, NULL, 6, b.Id
                           FROM dbo.INV_DiscountBinNumbers b
                          WHERE b.DiscountId = h.Id AND b.PropertyId = h.PropertyId
                         UNION ALL
                         SELECT 'MEMBERS', m.MemberCode, NULL, 7, m.Id
                           FROM dbo.INV_DiscountMember m
                          WHERE m.DiscountId = h.Id AND m.PropertyId = h.PropertyId
                         UNION ALL
                         SELECT 'CUSTGROUPS', CAST(g.CustomerGroupId AS VARCHAR(20)), NULL, 8, g.Id
                           FROM dbo.INV_DiscountCustomerGroup g
                          WHERE g.DiscountId = h.Id AND g.PropertyId = h.PropertyId
                        ) x
                  ORDER BY x.Ord, x.RowId
                    FOR JSON PATH) AS [Rows],
                (SELECT sf.Section, sf.Field, sf.Value
                   FROM (VALUES ('BUYNGETN', 'BUYQTY',  CONVERT(VARCHAR(50), CONVERT(DECIMAL(18,2), ISNULL(h.BuyQuantity, 0)))),
                                ('BUYNGETN', 'FREEQTY', CONVERT(VARCHAR(50), CONVERT(DECIMAL(18,2), ISNULL(h.FreeQuantity, 0))))
                        ) sf (Section, Field, Value)
                  WHERE @HasBuyNGetN = 1
                    FOR JSON PATH) AS SectionFields
               FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)                     AS TargetsJson
      FROM dbo.DiscountHeader h
     WHERE h.Id = @Id AND h.PropertyId = @PropertyId;
END

GO

