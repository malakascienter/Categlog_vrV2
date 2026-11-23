CREATE PROCEDURE [dbo].[MW_Insert_OutsideOrder] 
	@itemOrderDetailXml NVARCHAR(MAX),
	@PropertyId			INT,
	@Outlet				VARCHAR(5),
	@OrderType		    VARCHAR(1),
	@EventDetail        NVARCHAR(MAX),
	@AggregatorId		INT,
	@ChannelCode		VARCHAR(10)
AS

INSERT INTO MW_OutsideOrder    (
ItemOrderDetailXml,
PropertyId,
Outlet,
OrderType,
EventDetail,
AggregatorId,
ChannelCode
)
VALUES
(
@itemOrderDetailXml,
@PropertyId,
@Outlet,
@OrderType,
@EventDetail,
@AggregatorId,
@ChannelCode
);


BEGIN TRY
BEGIN TRANSACTION
SET DATEFORMAT dmy
SET NOCOUNT ON;

DECLARE @ScanDineResNetVal DECIMAL(18,6)
SELECT @ScanDineResNetVal = ScanDineResNetVal FROM Companies WHERE CompanyID = @PropertyId

IF( ISNULL(@ScanDineResNetVal,0) = 0 )
BEGIN

	SET @ScanDineResNetVal = 1

END

DECLARE @OpenItemCode VARCHAR(20) 

SELECT TOP(1) @OpenItemCode = ItemCode
FROM MainMenu 
WHERE IsInstruction = 1 AND PropertyId = @PropertyId

-- Clean up temp tables if exist
IF OBJECT_ID(N'tempdb..#TempOrderDetail') IS NOT NULL DROP TABLE #TempOrderDetail
IF OBJECT_ID(N'tempdb..#TempItemDetail') IS NOT NULL DROP TABLE #TempItemDetail
IF OBJECT_ID(N'tempdb..#TempModifierDetail') IS NOT NULL DROP TABLE #TempModifierDetail

-- Prepare XML
DECLARE @DocHandle INT 
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @itemOrderDetailXml

-- Extract order level data
SELECT * INTO #TempOrderDetail
FROM OPENXML(@DocHandle, '/MW_Order')
WITH (
	OutsideOrderNo		VARCHAR(50)		'OutsideOrderNo',
	id					VARCHAR(50)		'id',
	display_id			VARCHAR(50)		'display_id',
	current_state		VARCHAR(10)		'current_state',
	placed_at			DATETIME		'placed_at',
	ContactNo			VARCHAR(50)		'ContactNo',
	CustomerName		VARCHAR(100)	'CustomerName',
	Email				VARCHAR(100)	'Email',
	Remark				VARCHAR(200)	'Remark',
	TableNo             VARCHAR(5)	    'TableNo'
)

-- Extract item level data
SELECT * INTO #TempItemDetail
FROM OPENXML(@DocHandle, '/MW_Order/Items/MW_Cart')
WITH (
	ItemCode			VARCHAR(20)		'ItemCode',
	Description			VARCHAR(200)	'Description',
	Price				MONEY			'Price',
	Qty					MONEY			'Qty',
	Action				VARCHAR(5)		'Action',
	ItemSeq				INT				'ItemSeq',
	SortSeq				INT				'SortSeq',
	RefItemCode			VARCHAR(20)		'RefItemCode',
	OutsideOrderNo		VARCHAR(50)		'OutsideOrderNo',
	IsOpenItem          BIT				'IsOpenItem'
)

-- Extract item level data
SELECT * INTO #TempModifierDetail
FROM OPENXML(@DocHandle, '/MW_Order/Items/MW_Cart/Modifier/MW_MenuItemWiseModifier')
WITH (
	MainMenuCode			VARCHAR(20)		'MainMenuCode',
	ModifierMenuCode		VARCHAR(20)		'ModifierMenuCode',
	ModifierMenuName		VARCHAR(200)	'ModifierMenuName',
	ActionID			    INT		        'ActionID',
	SeqNo			        INT	            'SeqNo',
	Price				    MONEY			'Price',
	Qty					    MONEY			'Qty',
	Action				    VARCHAR(5)		'Action',
	ItemSeq				    INT				'ItemSeq',
	SortSeq				    INT				'SortSeq',
	RefItemCode			    VARCHAR(20)		'RefItemCode',
	OutsideOrderNo		    VARCHAR(50)		'OutsideOrderNo',
	Remark		            VARCHAR(500)	'Remark'
)

IF( ISNULL(@OpenItemCode,'') = '' )
BEGIN

 DELETE FROM #TempItemDetail WHERE IsOpenItem = 1

END
ELSE
BEGIN

 UPDATE #TempItemDetail 
 SET ItemCode = @OpenItemCode
 WHERE IsOpenItem = 1

END

-- Insert order + item details
INSERT INTO [dbo].[POS_OutsideOrders]
(
	[PropertyId],
	[OutletID],
	[OutsideOrderNo],
	[OrderType],
	[OrderDateTime],
	[MenuItemID],
	[Name],
	[Quantity],
	[Rate],
	[RefItemID],
	[ActionID],
	[IsModifier],
	[IsInstruction],
	[Remarks],
	[ItemSequence],
	[SortSeq],
	[ContactNo],
	[HotelReservationNo],
	[RoomID],
	[RoomName],
	[GuestProfileID],
	[GuestProfileName],
	[MealPlanID],
	[MealPlanName],
	OutsideOrderId,
	AggregatorId,
	ChannelCode,
    TableNo,
    RefOrderNo,
    Email
)
SELECT 
	@PropertyId,
	@Outlet,
	O.OutsideOrderNo,
	@OrderType,
	O.placed_at,
	I.ItemCode,
	I.Description,
	I.Qty,
	(I.Price / @ScanDineResNetVal),
	I.RefItemCode,
	0, -- ActionID
	0, -- IsModifier
	(CASE WHEN ISNULL(@OpenItemCode,'') = I.ItemCode THEN 1 ELSE 0 END), -- IsInstruction
	O.Remark,
	I.ItemSeq,
	I.SortSeq,
	O.ContactNo,
	'', -- HotelReservationNo
	0,  -- RoomID
	'', -- RoomName
	0,  -- GuestProfileID
	O.CustomerName,
	0,  -- MealPlanID
	'', -- MealPlanName
	O.id,
	@AggregatorId,
	@ChannelCode,
    O.TableNo,
    O.OutsideOrderNo,
    O.Email
FROM #TempOrderDetail O
INNER JOIN #TempItemDetail I ON O.OutsideOrderNo = I.OutsideOrderNo

UNION ALL

SELECT 
	@PropertyId,
	@Outlet,
	O.OutsideOrderNo,
	@OrderType,
	O.placed_at,
	I.ModifierMenuCode,
	I.ModifierMenuName,
	I.Qty,
	(I.Price / @ScanDineResNetVal),
	I.RefItemCode,
	1, -- ActionID
	0, -- IsModifier
	0, -- IsInstruction
	O.Remark,
	I.ItemSeq,
	I.SortSeq,
	O.ContactNo,
	'', -- HotelReservationNo
	0,  -- RoomID
	'', -- RoomName
	0,  -- GuestProfileID
	O.CustomerName,
	0,  -- MealPlanID
	'', -- MealPlanName
	O.id,
	@AggregatorId,
	@ChannelCode,
	O.TableNo,
	O.OutsideOrderNo,
	O.Email
FROM #TempOrderDetail O
INNER JOIN #TempModifierDetail I ON O.OutsideOrderNo = I.OutsideOrderNo


-- Cleanup
IF OBJECT_ID(N'tempdb..#TempOrderDetail') IS NOT NULL DROP TABLE #TempOrderDetail
IF OBJECT_ID(N'tempdb..#TempItemDetail') IS NOT NULL DROP TABLE #TempItemDetail
IF OBJECT_ID(N'tempdb..#TempModifierDetail') IS NOT NULL DROP TABLE #TempModifierDetail

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage VARCHAR(MAX) = ERROR_MESSAGE()
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
	DECLARE @ErrorState INT = ERROR_STATE()

	-- Optionally log error here

	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
	ROLLBACK TRANSACTION
END CATCH

GO

