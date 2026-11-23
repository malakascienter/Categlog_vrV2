-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-12-24
-- Description:	Update Pending GRN Details
-- [dbo].[SP_UpdatePendingGRNDetails] ''
-- =============================================
CREATE PROCEDURE [dbo].[SP_UpdatePendingGRNDetails]
	@XMLDetails XML

AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION
	SET NOCOUNT ON;

	DECLARE @iDocID INT,@iDocIDORG INT, @HeaderId INT, @CreatedUserID INT, @Remarks VARCHAR(250), @Status CHAR(2), 
	@GRNXML VARCHAR(MAX), @NEWGRNXML XML,@NEWGRNXML2 XML, @NEWGRNXML3 XML,@ItemId INT,@ItemId2 INT,@UnitPrice DECIMAL(18,6), @TxnType CHAR(2), @Quantity DECIMAL(18,6),@Quantity2 DECIMAL(18,6),
	@TempRowCount INT, @TempRowCount2 INT, @TempDocNo nvarchar(30), @TempPropertyID INT,
        @ReferenceId INT,@ApprovalLevelID INT , @PropertyID INT, @LocationID INT, @UnitPriceSH decimal(18,6) , @UnitPriceGRN decimal(18,6),@IsMailNotification BIT, @headerOut INT, @documentNumber VARCHAR(MAX)
		,@QuantityGRN DECIMAL(18,6),@QuantitySH DECIMAL(18,6),@TxnUnitIdSH INT
		,@TxnUnitIdGRN INT,@IsGRNApprovalModification BIT,@ApprovalDocNO VARCHAR(30)
    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

		 SELECT * INTO #TempGRNHeader FROM
        OPENXML(@iDocID, 'StockTransactionHeader2', 2)
        WITH
        (
            CreatedUserID INT,
            SupplierID INT,
            LocationID INT,
            ReferenceID INT
        );


		SELECT * INTO #TempGRNDetails FROM
		OPENXML(@iDocID, '/StockTransactionHeader2/StockDetailList/StockTransactionDetail2', 2)
			WITH ([StockTransactionHeaderID] [int],
	[StockItemID] [int] ,
	[Quantity] [decimal](18, 6),
	[UnitPrice] [decimal](18, 6) ,
	[TxnUnitID] [int] ,
	[MasterUnitID] [int] ,
	[MasterUnitConversion] [decimal](18, 6) ,
	[ReportUnitID] [int] ,
	[ReportUnitConversion] [decimal](18, 6),
	[DiscountValue] [decimal](18, 6),
	[DiscountPercentage] [decimal](18, 6),
	[TimeStamp] [nvarchar](256) ,
	[StockMasterQuantity] [decimal](18, 6),
	[StockMasterAveragePrice] [decimal](18, 6),
	[NewQuantity] [decimal](18, 6),
	[NewAveragePrice] [decimal](18, 6),
	[Remarks] [nvarchar](max) ,
	[UserProfileId] [int],
	[CostTransactionAccountID] [int],
	[PurchaseTransactionAccountID] [int],
	[TxnType] [nvarchar](1),
	[BalanceQuantity] [decimal](18, 6),
	[ReturnQuantity] [decimal](18, 6),
	[ItemUnitPriceInSuppCurrency] [decimal](18, 6),
	[IPAddress] [nvarchar](max) ,
	[CreatedUserID] [int],
	[LastModUserID] [int] ,
	[CreatedDate] [datetime],
	[LastModDate] [datetime] ,
	[TBPHeaderId] [int],
	[Isserialadded] [bit],
	[SkipGL] [bit] ,
	[BalVal] [decimal](38, 8) ,
	[AccName] [nvarchar](250) ,
	[RequestedGenericItemId] [int] ,
	[PhysicalQuantity] [decimal](18, 6) ,
	[IssuedQuantity] [decimal](18, 6) ,
	[SellingPrice] [decimal](18, 6),
	ItemName VARCHAR(250),
	IsItemEdited BIT
	);

		

		SELECT @HeaderId =ReferenceID,@CreatedUserID = CreatedUserID,@LocationID = LocationID
		FROM #TempGRNHeader


		SELECT @GRNXML = XMLDetails, @TxnType = TransactionType ,@ApprovalDocNO = ApprovalDocNo,@PropertyID= CompanyId
		FROM  [dbo].[GRNApprovalLog] WHERE Id = @HeaderId
		AND LocationId = @LocationID

		SET @NEWGRNXML = CONVERT(XML,@GRNXML)

		

		EXEC sp_xml_preparedocument @iDocIDORG OUTPUT, @NEWGRNXML;

		SELECT * INTO #TempDetails FROM
		OPENXML(@iDocIDORG, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2)
		WITH ([StockTransactionHeaderID] [int],
	[StockItemID] [int] ,
	[Quantity] [decimal](18, 6),
	[UnitPrice] [decimal](18, 6) ,
	[TxnUnitID] [int] ,
	[MasterUnitID] [int] ,
	[MasterUnitConversion] [decimal](18, 6) ,
	[ReportUnitID] [int] ,
	[ReportUnitConversion] [decimal](18, 6),
	[DiscountValue] [decimal](18, 6),
	[DiscountPercentage] [decimal](18, 6),
	[TimeStamp] [nvarchar](256) ,
	[StockMasterQuantity] [decimal](18, 6),
	[StockMasterAveragePrice] [decimal](18, 6),
	[NewQuantity] [decimal](18, 6),
	[NewAveragePrice] [decimal](18, 6),
	[Remarks] [nvarchar](max) ,
	[UserProfileId] [int],
	[CostTransactionAccountID] [int],
	[PurchaseTransactionAccountID] [int],
	[TxnType] [nvarchar](1),
	[BalanceQuantity] [decimal](18, 6),
	[ReturnQuantity] [decimal](18, 6),
	[ItemUnitPriceInSuppCurrency] [decimal](18, 6),
	[IPAddress] [nvarchar](max) ,
	[CreatedUserID] [int],
	[LastModUserID] [int] ,
	[CreatedDate] [datetime],
	[LastModDate] [datetime] ,
	[TBPHeaderId] [int],
	[Isserialadded] [bit],
	[SkipGL] [bit] ,
	[BalVal] [decimal](38, 8) ,
	[AccName] [nvarchar](250) ,
	[RequestedGenericItemId] [int] ,
	[PhysicalQuantity] [decimal](18, 6) ,
	[IssuedQuantity] [decimal](18, 6) ,
	[SellingPrice] [decimal](18, 6))


		
	
	INSERT INTO  #TempDetails(StockTransactionHeaderID, StockItemID, Quantity, UnitPrice, TxnUnitID, MasterUnitID, MasterUnitConversion, ReportUnitID, ReportUnitConversion, DiscountValue, DiscountPercentage, TimeStamp, 
    StockMasterQuantity, StockMasterAveragePrice, NewQuantity, NewAveragePrice, Remarks, UserProfileId, CostTransactionAccountID, PurchaseTransactionAccountID, TxnType, BalanceQuantity, ReturnQuantity, 
    ItemUnitPriceInSuppCurrency, IPAddress, CreatedUserID, LastModUserID, CreatedDate, 
	LastModDate, TBPHeaderId, Isserialadded, SkipGL, BalVal, AccName, RequestedGenericItemId, PhysicalQuantity, IssuedQuantity, SellingPrice)

	SELECT StockTransactionHeaderID, StockItemID, Quantity, UnitPrice, TxnUnitID, MasterUnitID, MasterUnitConversion, ReportUnitID, ReportUnitConversion, DiscountValue, DiscountPercentage, TimeStamp, 
                  StockMasterQuantity, StockMasterAveragePrice, NewQuantity, NewAveragePrice, Remarks, UserProfileId, CostTransactionAccountID, PurchaseTransactionAccountID, TxnType, BalanceQuantity, ReturnQuantity, 
                  ItemUnitPriceInSuppCurrency, IPAddress, CreatedUserID,
				  LastModUserID, CreatedDate, LastModDate, TBPHeaderId, Isserialadded, SkipGL, BalVal, AccName, RequestedGenericItemId, PhysicalQuantity, IssuedQuantity, SellingPrice
	FROM #TempGRNDetails
	WHERE StockItemID NOT IN (SELECT StockItemID
	FROM #TempDetails)


		SELECT *
		FROM #TempDetails


		SELECT *
		INTO #ModifiedGRNDetails
		FROM #TempGRNDetails
		WHERE IsItemEdited = 1


		SELECT MT.Quantity,TD.Quantity,MT.UnitPrice,TD.UnitPrice
		FROM #ModifiedGRNDetails MT
		INNER JOIN #TempDetails TD ON MT.StockItemID = TD.StockItemID

		UPDATE TD
		SET TD.Quantity = MT.Quantity,TD.UnitPrice = MT.UnitPrice
		FROM #ModifiedGRNDetails MT
		INNER JOIN #TempDetails TD ON MT.StockItemID = TD.StockItemID

		declare @StockItemID INT,@ItemName VARCHAR(MAX),@OriginalItemName VARCHAR(MAX),@IsTransactionExists BIT
		WHILE EXISTS(SELECT 1 FROM #ModifiedGRNDetails)
		BEGIN
			SELECT TOP (1) @StockItemID =StockItemID,@ItemName = ItemName
			FROM #ModifiedGRNDetails


			SELECT @OriginalItemName = Name
			FROM StockItemHeaders
			WHERE ID = @StockItemID
			SELECT @IsTransactionExists =[dbo].[fn_IsTransactionExistsItemWise] (@StockItemID)

			SELECT @IsTransactionExists IsTransactionExists,@StockItemID StockItemID

			IF(@ItemName <> @OriginalItemName)
			BEGIN
				IF(@IsTransactionExists = 0)
				BEGIN
					SELECT 'UPDATED'
					UPDATE StockItemHeaders
					SET Name = @ItemName,LastModUserID = @CreatedUserID,LastModDate = GETDATE()
					WHERE ID = @StockItemID

					EXEC Inventry_AuditTail_WriteToLog 'StockItemHeaders', @StockItemID, 'INV', 'SIHD', 'U', @CreatedUserID,@PropertyID, '', ''
				END

			END

			DELETE TOP (1) FROM #ModifiedGRNDetails
		END

		

		select '#TempDetails ',
		* from #TempDetails 

        DECLARE @newFeatures4 xml;  
        set  @newFeatures4  =(select * from #TempDetails FOR XML PATH('StockTransactionDetail'))
		select @newFeatures4 newFeatures4
        SET @NEWGRNXML.modify('delete /StockTransactionHeader/StockDetailList/StockTransactionDetail')
        SET @NEWGRNXML.modify('            
        insert sql:variable("@newFeatures4")            
        into (/StockTransactionHeader/StockDetailList)[1] ')     
		IF EXISTS (SELECT * FROM [dbo].[GRNApprovalLog] WHERE ApprovalDocNo=@ApprovalDocNO  AND LocationId = @LocationID)
		BEGIN
			select 222222,XMLDetails from [GRNApprovalLog] WHERE ApprovalDocNo=@ApprovalDocNO  AND LocationId = @LocationID

			
			UPDATE [dbo].[GRNApprovalLog]
			SET XMLDetails = (select convert(varchar(max),  @NEWGRNXML))
			WHERE ApprovalDocNo=@ApprovalDocNO  AND LocationId = @LocationID

			select 1111111,XMLDetails from [GRNApprovalLog] WHERE ApprovalDocNo=@ApprovalDocNO  AND LocationId = @LocationID
							
		END

   
COMMIT TRANSACTION
END TRY
BEGIN CATCH
 


	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH			

END

GO

