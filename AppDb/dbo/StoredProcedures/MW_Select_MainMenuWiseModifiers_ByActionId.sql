
CREATE PROCEDURE [dbo].[MW_Select_MainMenuWiseModifiers_ByActionId]  
@ActionId INT,  
@MainMenuCode NVARCHAR(MAX),
@PropertyId INT,
@Outlet VARCHAR(MAX)
AS  
BEGIN  

    DECLARE @DefaultProceType INT, @DefaultScanDineShowPriceTypeId INT
	SELECT @DefaultProceType = DefaultPriceTypeId,@DefaultScanDineShowPriceTypeId = DefaultScanDineShowPriceTypeId   FROM Location_Ref WHERE PropertyId = @PropertyId AND code = @Outlet

	DECLARE @ScanDineResNetVal DECIMAL(18,6)
	SELECT @ScanDineResNetVal = ScanDineResNetVal FROM Companies WHERE CompanyID = @PropertyId


	IF( ISNULL(@ScanDineResNetVal,0) = 0 )
	BEGIN

	 SET @ScanDineResNetVal = 1

	END


	CREATE TABLE #TempMenuItemWiseModifier
    (
        ID                 INT,
        MainMenuCode       VARCHAR(6),
        ModifierMenuCode   VARCHAR(6),
        SeqNo              INT,
        ActionID           INT,
        PropertyId         INT,
        IsUpload           BIT,
        CreatedUserId      NCHAR(10),
        CreatedDateTime    DATETIME,
        UpdatedUserId      INT,
        UpdatedDateTime    DATETIME,

        -- extra columns from SELECT
        ModifierMenuName   VARCHAR(255),
        Price              DECIMAL(18,2),
        ShowPrice          DECIMAL(18,2)
    );


    CREATE TABLE #TempMenuItemWiseModifierShowPrice
    (
        ID                 INT,
        MainMenuCode       VARCHAR(MAX),
        ModifierMenuCode   VARCHAR(MAX),
        SeqNo              INT,
        ActionID           INT,
        PropertyId         INT,
        IsUpload           BIT,
        CreatedUserId      NCHAR(10),
        CreatedDateTime    DATETIME,
        UpdatedUserId      INT,
        UpdatedDateTime    DATETIME,

        -- extra columns from SELECT
        ModifierMenuName   VARCHAR(MAX),
        Price              DECIMAL(18,2),
        ShowPrice          DECIMAL(18,2)
    );


    INSERT INTO #TempMenuItemWiseModifier
    (
        ID,
        MainMenuCode,
        ModifierMenuCode,
        SeqNo,
        ActionID,
        PropertyId,
        IsUpload,
        CreatedUserId,
        CreatedDateTime,
        UpdatedUserId,
        UpdatedDateTime,
        ModifierMenuName,
        Price,
        ShowPrice
    )
	SELECT MD.[ID]
          ,MD.[MainMenuCode]
          ,MD.[ModifierMenuCode]
          ,MD.[SeqNo]
          ,MD.[ActionID]
          ,MD.[PropertyId]
          ,MD.[IsUpload]
          ,MD.[CreatedUserId]
          ,MD.[CreatedDateTime]
          ,MD.[UpdatedUserId]
          ,MD.[UpdatedDateTime]
          ,MM.Description AS ModifierMenuName,(OP.Price * ISNULL(@ScanDineResNetVal,1) ) AS Price,(OP.Price * ISNULL(@ScanDineResNetVal,1) ) AS ShowPrice
	FROM MenuItemWiseModifier  MD INNER JOIN MainMenu MM ON MD.ModifierMenuCode = MM.ItemCode AND MD.PropertyId = MM.PropertyId
	INNER JOIN POS_OutletWiseMenuItems OM ON MM.ItemCode = OM.MenuCode AND MM.PropertyId = OM.PropertyId
	INNER JOIN POS_OutletWiseMenuItemPrice OP ON OP.MenuItemCode = OM.MenuCode AND OP.OutletCode = OM.OutletCode AND OP.PropertyId = OM.PropertyId
	WHERE ActionID = @ActionId AND MainMenucode = @MainMenuCode  
	AND MM.PropertyId = @PropertyId AND OM.OutletCode = @Outlet AND OP.PriceTypeID = @DefaultProceType


    INSERT INTO #TempMenuItemWiseModifierShowPrice
    (
        ID,
        MainMenuCode,
        ModifierMenuCode,
        SeqNo,
        ActionID,
        PropertyId,
        IsUpload,
        CreatedUserId,
        CreatedDateTime,
        UpdatedUserId,
        UpdatedDateTime,
        ModifierMenuName,
        Price,
        ShowPrice
    )
	SELECT MD.[ID]
          ,MD.[MainMenuCode]
          ,MD.[ModifierMenuCode]
          ,MD.[SeqNo]
          ,MD.[ActionID]
          ,MD.[PropertyId]
          ,MD.[IsUpload]
          ,MD.[CreatedUserId]
          ,MD.[CreatedDateTime]
          ,MD.[UpdatedUserId]
          ,MD.[UpdatedDateTime]
          ,MM.Description AS ModifierMenuName,(OP.Price * ISNULL(@ScanDineResNetVal,1) ) AS Price,(OP.Price * ISNULL(@ScanDineResNetVal,1) ) AS ShowPrice
	FROM MenuItemWiseModifier  MD INNER JOIN MainMenu MM ON MD.ModifierMenuCode = MM.ItemCode AND MD.PropertyId = MM.PropertyId
	INNER JOIN POS_OutletWiseMenuItems OM ON MM.ItemCode = OM.MenuCode AND MM.PropertyId = OM.PropertyId
	INNER JOIN POS_OutletWiseMenuItemPrice OP ON OP.MenuItemCode = OM.MenuCode AND OP.OutletCode = OM.OutletCode AND OP.PropertyId = OM.PropertyId
	WHERE ActionID = @ActionId AND MainMenucode = @MainMenuCode  
	AND MM.PropertyId = @PropertyId AND OM.OutletCode = @Outlet AND OP.PriceTypeID = @DefaultScanDineShowPriceTypeId



    UPDATE A
	SET A.ShowPrice = B.ShowPrice
	FROM #TempMenuItemWiseModifier A
    INNER JOIN #TempMenuItemWiseModifierShowPrice B
        ON  A.ID               = B.ID
        AND A.MainMenuCode     = B.MainMenuCode
        AND A.ModifierMenuCode = B.ModifierMenuCode
        AND A.SeqNo            = B.SeqNo
        AND A.ActionID         = B.ActionID
        AND A.PropertyId       = B.PropertyId;

	UPDATE T1
	SET T1.ShowPrice = T1.Price
	FROM #TempMenuItemWiseModifier T1 
	WHERE T1.Price > 0 AND T1.ShowPrice = 0


	select
	ID,
    MainMenuCode,
    ModifierMenuCode,
    SeqNo,
    ActionID,
    PropertyId,
    IsUpload,
    CreatedUserId,
    CreatedDateTime,
    UpdatedUserId,
    UpdatedDateTime,
    ModifierMenuName,
    Price,
    ShowPrice
	from #TempMenuItemWiseModifier


	drop table #TempMenuItemWiseModifier
	drop table #TempMenuItemWiseModifierShowPrice


END

GO

