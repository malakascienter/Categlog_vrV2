
-- =============================================

create PROCEDURE [dbo].[Api_Insert_OrderItem_UberEat] 
	@itemOrderDetailXml NVARCHAR(MAX),
	@PropertyId			INT,
	@Outlet				VARCHAR(5),
	@OrderType		    VARCHAR(1),
	@EventDetail        NVARCHAR(MAX),
	@AggregatorId		INT,
	@ChannelCode		VARCHAR(10)
AS
BEGIN TRY
BEGIN TRANSACTION
SET DATEFORMAT dmy

	SET NOCOUNT ON;	

	IF OBJECT_ID(N'tempdb..#TempOrderDetail') IS NOT NULL
	BEGIN
	DROP TABLE #TempOrderDetail
	END
	IF OBJECT_ID(N'tempdb..#TempItemDetail') IS NOT NULL
	BEGIN
	DROP TABLE #TempItemDetail
	END
	IF OBJECT_ID(N'tempdb..#TempOrder') IS NOT NULL
	BEGIN
	DROP TABLE #TempOrder
	END

	

	DECLARE @DocHandle INT 

	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@itemOrderDetailXml

	SELECT * INTO #TempOrderDetail
	FROM OPENXML(@DocHandle,'ArrayOfUberEatOrderDetail/UberEatOrderDetail')
	WITH(	
			OutsideOrderNo				VARCHAR(50)		    'OutsideOrderNo',
			id							VARCHAR(max)		'id',
			display_id					varchar(50)			'display_id',
			current_state				varchar(50)			'current_state',
			placed_at					DATETIME			'placed_at',
			type						VARCHAR(MAX)		'type',
			first_name					VARCHAR(MAX)		'eater/first_name',
			last_name					VARCHAR(MAX)		'eater/last_name',
			phone						VARCHAR(50)			'eater/phone'
			
	)

	SELECT * INTO #TempItemDetail
	FROM OPENXML(@DocHandle,'ArrayOfUberEatOrderDetail/UberEatOrderDetail/cart/items/itemsObj')
	WITH(	
			OutsideOrderNo				VARCHAR(50)		'OutsideOrderNo',
			ItemCode					VARCHAR(10)		'id',
			title						varchar(200)	'title',
			quantity					INT				'quantity',
			amount						INT				'price/unit_price/amount'
	
	)


	SELECT OutsideOrderNo 
	INTO #TempOrder 
	FROM #TempOrderDetail 
	GROUP BY OutsideOrderNo

DECLARE @OutsideOrderNo VARCHAR(20)

WHILE EXISTS ( SELECT 1 FROM #TempOrder )
BEGIN

 SELECT TOP(1) @OutsideOrderNo =  OutsideOrderNo  FROM #TempOrder

 	INSERT INTO [dbo].[POS_OutsideOrders]
           ([PropertyId]
           ,[OutletID]
           ,[OutsideOrderNo]
           ,[OrderType]
           ,[OrderDateTime]
           ,[MenuItemID]
           ,[Name]
           ,[Quantity]
           ,[Rate]
           ,[RefItemID]
           ,[ActionID]
           ,[IsModifier]
           ,[IsInstruction]
           ,[Remarks]
           ,[ItemSequence]
           ,[SortSeq]
           ,[ContactNo]
           ,[HotelReservationNo]
           ,[RoomID]
           ,[RoomName]
           ,[GuestProfileID]
           ,[GuestProfileName]
           ,[MealPlanID]
           ,[MealPlanName]
		   ,UberEatOrderId
		   ,AggregatorId
		   ,ChannelCode)
	SELECT @PropertyId,
		   @Outlet,
		   H.OutsideOrderNo,
		   @OrderType,
		   H.placed_at,
		   D.ItemCode,
		   D.title,
		   D.quantity,
		   CONVERT(MONEY,CONCAT(SUBSTRING(CONVERT(VARCHAR(MAX),D.amount), 1, LEN(CONVERT(VARCHAR(MAX),D.amount))-2),'.',SUBSTRING(CONVERT(VARCHAR(MAX),D.amount), LEN(CONVERT(VARCHAR(MAX),D.amount))-1, LEN(CONVERT(VARCHAR(MAX),D.amount))))),
		   D.ItemCode,
		   0,
		   0,
		   0,
		   '',
		    ROW_NUMBER() OVER(ORDER BY D.OutsideOrderNo),
		   1,
		   H.Phone,
		   '',
		   0,
		   '',
		   0,
		   '',
		   0,
		   '',
		   H.id,
		   @AggregatorId,
		   @ChannelCode
	FROM #TempOrderDetail H  INNER JOIN #TempItemDetail D ON H.OutsideOrderNo = D.OutsideOrderNo
	WHERE H.OutsideOrderNo = @OutsideOrderNo

 DELETE TOP(1) FROM #TempOrder

END



	
	--SELECT * FROM #TempOrderDetail
	

	IF OBJECT_ID(N'tempdb..#TempOrderDetail') IS NOT NULL
	BEGIN
	DROP TABLE #TempOrderDetail
	END
	IF OBJECT_ID(N'tempdb..#TempItemDetail') IS NOT NULL
	BEGIN
	DROP TABLE #TempItemDetail
	END
	IF OBJECT_ID(N'tempdb..#TempOrder') IS NOT NULL
	BEGIN
	DROP TABLE #TempOrder
	END
	
	

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	
	DECLARE @ErrorMessage VARCHAR(MAX)
	DECLARE @ErrorSeverity VARCHAR(MAX)
	DECLARE @ErrorState VARCHAR(MAX)

	SET @ErrorMessage  = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState    = ERROR_STATE()
	--INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
 --   VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH

GO

