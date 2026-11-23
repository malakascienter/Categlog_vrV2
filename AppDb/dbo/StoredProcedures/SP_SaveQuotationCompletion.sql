-- =============================================
-- Author:		Nivesh
-- Create date: 2025-05-28
-- Description:	Save quotation completion
-- =============================================
-- SP_SaveQuotationCompletion '{"PropertyID":1,"PRID":12,"UserID":4168,"List":[{"ItemID":3914,"SupplierID":159,"Remark":""}]}'

CREATE PROCEDURE [dbo].[SP_SaveQuotationCompletion] 
	-- Add the parameters for the stored procedure here
	@JSONDetails NVARCHAR(MAX),
	@OutTable NVARCHAR(MAX) output
AS
BEGIN
	
	SET NOCOUNT ON;
BEGIN TRY 
BEGIN TRANSACTION
	-- Declare variables for PropertyID and PRID
	DECLARE @PropertyID INT, @PRID INT, @LocationID INT, @UserID INT, @XMLData XML, @docNo VARCHAR(MAX) ,
    @headerid INT ;

	--JSON Header data
	SELECT 
		@PropertyID = JSONData.PropertyID,
		@PRID = JSONData.PRID,
		@UserID = JSONData.UserID
	FROM OPENJSON(@JSONDetails)
	WITH (
		PropertyID INT,
		PRID INT,
		UserID INT
	) AS JSONData;

	CREATE TABLE #TempQuotationList(
		ItemID INT,
		SupplierID INT,
		Remark NVARCHAR(MAX)
	)

	--JSON Detail data
	INSERT INTO #TempQuotationList
	SELECT *
	FROM OPENJSON(@JSONDetails, '$.List')
	WITH (
		ItemID INT,
		SupplierID INT,
		Remark NVARCHAR(MAX)
	) AS ItemList;

	-------------------------Insert data for PO------------------------
	SELECT @LocationID= LocationID 
	FROM RequestHeaders rh 
	WHERE rh.RequestType ='RP' AND rh.Id =@PRID

	DECLARE @PoHeader TABLE (
		PoHeaderID INT,
		PropertyID INT,
		LocationID INT,
		PoNo NVARCHAR(50),
		SupplierID INT,
		CreatedUserID INT,
		LastModUserID INT,
		CreatedDate DATETIME,
		LastModDate DATETIME,
		UserProfileID INT,
		DocumentStatus NVARCHAR(10),
		IsDirectPo BIT,
		isApproved BIT,
		DeliveryDate DATE,
		PaymentTermsDetailID INT,
		CurrencyId INT,
		POTypeId INT,
		NetTotal DECIMAL(18,2),
		GrossTotal DECIMAL(18,2),
		TotalDiscount DECIMAL(18,2),
		TaxTotal DECIMAL(18,2),
		POType INT,
		IsForeign BIT,
		isModificationComplete BIT,
		Remarks VARCHAR(MAX)
	)

	--Insert PO data
	INSERT INTO @PoHeader VALUES (
		0, @PropertyID, @LocationID, 'no', 1, @UserID, @UserID, getdate(), getdate(),
		@UserID, 'PO', 0, 1, convert(date, getdate()), 0, 1, 1, 0, 0, 0, 0, 1, 0, 0,'Quotation-wise'
	)

	-- Temporary detail rows
	DECLARE @PoDetail TABLE (
		PoHeaderID INT,
		StockItemID INT,
		StockName NVARCHAR(100),
		UnitID INT,
		UnitName NVARCHAR(50),
		UnitPrice DECIMAL(18,2),
		RequestedQuantity DECIMAL(18,2),
		ApprovedQuantity DECIMAL(18,2),
		ReceivedQuantity DECIMAL(18,2),
		Remarks NVARCHAR(200),
		DiscountValue DECIMAL(18,2),
		DiscountPercentage DECIMAL(18,2),
		LocationID INT,
		SupplierID INT,
		RequestHeaderID INT,
		TaxValue DECIMAL(18,2),
		TBPHeaderId INT,
		CurrentStock DECIMAL(18,2),
		ItemTotal DECIMAL(18,2)
	)

		-- Sample detail row
	INSERT INTO @PoDetail
	SELECT
		0, rd.StockItemID, sih.Name, rd.UnitID, u.Name, ISNULL(sq.Price,0), rd.ApprovedQuantity, rd.ApprovedQuantity, rd.ApprovedQuantity, '', ISNULL(sq.DiscountValue,0), ISNULL(sq.DiscountPercentage,0), rh.LocationID, t.SupplierID, rh.Id,
		(ISNULL(sq.TaxAmount,0)* ISNULL(sq.Price,0)/100),
		0, 0, 0
		FROM RequestHeaders rh
	INNER JOIN RequestDetails rd ON rd.RequestHeaderID = rh.Id
	INNER JOIN StockItemHeaders sih ON sih.id = rd.StockItemID
	INNER JOIN Units U ON U.Id = rd.UnitID
	INNER JOIN #TempQuotationList T ON t.ItemID =rd.StockItemID
	INNER JOIN QuotationRequestHeader qh ON qh.PurchaseRequestID = rh.id 
	INNER JOIN SupplierQuotationUploadDetail sq ON sq.QuotationHeaderID = qh.Id AND sq.ItemID = rd.StockItemID AND sq.SupplierID = t.SupplierID
	WHERE rh.RequestType ='RP' AND rh.Id =@PRID AND  rh.PropertyID =@PropertyID

	-----------------------------------------------------------------------
	SELECT * INTO #TempQuotationList2 FROM #TempQuotationList

	WHILE EXISTS (SELECT 1 FROM #TempQuotationList2)
	BEGIN
		DECLARE @ItemID INT, @SupplierID INT, @Remark NVARCHAR(MAX), @UnitID INT, @Price MONEY, @TaxGroupID INT, @TaxPercentage MONEY, @ItemDetailID INT
		
		SELECT TOP 1 @ItemID =ItemID, @SupplierID =SupplierID, @Remark= Remark  FROM #TempQuotationList2
		
		SELECT @LocationID= rh.LocationID,@UnitID= rd.UnitID,@Price = sq.Price, @TaxPercentage = ISNULL(sq.TaxAmount,0) FROM RequestHeaders rh
		INNER JOIN RequestDetails rd ON rd.RequestHeaderID = rh.Id
		INNER JOIN QuotationRequestHeader qh ON qh.PurchaseRequestID = rh.id 
		INNER JOIN SupplierQuotationUploadDetail sq ON sq.QuotationHeaderID = qh.Id AND sq.ItemID = @ItemID
		WHERE rh.RequestType ='RP' AND rh.Id =@PRID AND StockItemID =@ItemID AND rh.PropertyID =@PropertyID AND sq.SupplierID =@SupplierID

		SELECT TOP 1 @TaxGroupID = TG.TaxGroupId FROM TaxGroupDetails  TG
		INNER JOIN TaxDetails TD ON TD.TaxTypeId = TG.TaxTypeId WHERE TG.ChargeRate = @TaxPercentage

		UPDATE SQ
		SET Remark = @Remark
		--SELECT * 
		FROM
		 SupplierQuotationUploadDetail sq
		 INNER JOIN QuotationRequestHeader qh ON qh.PurchaseRequestID =SQ.QuotationHeaderID AND QH.PurchaseRequestID =@PRID AND QH.PropertyID =@PropertyID
		 WHERE SQ.SupplierID =@SupplierID AND SQ.ItemID =@ItemID -- Update Quotation wise supplier remark

	----- Insert Supplierwise item detail --------------
		IF(EXISTS
		(
			SELECT 1
			FROM SupplierWiseItemDetails
			WHERE CompanyId = @PropertyID
					AND StockitemID = @ItemID and SupplierID =@SupplierID AND LocationId = @LocationID
		))
		BEGIN
				-------------------------------------------Log SupplierWiseItemDetails Delete-2024-02-22-----------------
			 SELECT @ItemDetailID = Id
			FROM SupplierWiseItemDetails
			WHERE CompanyId = @PropertyID
					AND StockitemID = @ItemID and SupplierID =@SupplierID AND LocationId = @LocationID		
			
			UPDATE SupplierWiseItemDetails
			SET CostPrice = @Price, LastModUserID = @UserID, LastModDate = GETDATE(),
			TaxGroupID = @TaxGroupID, IsQuotation =1, QuotationStatus = 'U'
			WHERE CompanyId = @PropertyID
			AND StockitemID = @ItemID AND SupplierID =@SupplierID AND LocationId = @LocationID

			EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @ItemDetailID, 'INV', 'SWDU', 'U', @UserID,@PropertyID, 'SP_InsertSupplierWiseItems', ''
		END
		ELSE
		BEGIN
				
			INSERT INTO SupplierWiseItemDetails
			(
				CompanyId,
				LocationId,
				SupplierID,
				StockItemID,
				PurchaseUnitID,
				CostPrice,
				IsDefaultSupplier,
				CreatedUserID,
				LastModUserID,
				CreatedDate,
				LastModDate,
				IPAddress,
				TaxGroupID,
				IsContractedSupplier
				,Validfrom
				,ValidTo,
				IsQuotation,
				QuotationStatus
			)
			VALUES( @PropertyID,
					@LocationID,
					@SupplierId,
					@ItemID,
					@UnitID ,
					@Price,
					1,
					@UserID,
					@UserID,
					GETDATE(),
					GETDATE(),
					'',
					@TaxGroupID,
					0,
					NULL ,
					NULL ,
					1,
					'I')

			SET @ItemDetailID =  SCOPE_IDENTITY()
			EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @ItemDetailID, 'INV', 'SWDI', 'I', @UserID,@PropertyID, 'SP_InsertSupplierWiseItems', ''
		END
		DELETE TOP (1)  FROM #TempQuotationList2
	END
	------------------------------------------------------
	SELECT @XMLData=
    (
        SELECT 
            '::1' AS [IPAddress],
            h.CreatedUserID,
            h.LastModUserID,
            h.CreatedDate,
            h.LastModDate,
            0 AS [Id],
            CAST(0 AS BIT) AS [Isprint],
            h.PoHeaderID,
            h.PropertyID,
            h.LocationID,
            h.PoNo,
            h.SupplierID,
            h.CreatedDate AS [DocumentDate],
            h.Remarks,
            h.DocumentStatus,
            h.UserProfileID,
            CAST(h.IsDirectPo AS BIT) AS [IsDirectPo],
            CAST(h.isApproved AS BIT) AS [isApproved],
            h.DeliveryDate,
            h.PaymentTermsDetailID,
            h.CurrencyId,
            h.POTypeId,
            h.NetTotal,
            h.GrossTotal,
            h.TotalDiscount,
            h.TaxTotal,
            h.POType,
            CAST(h.IsForeign AS BIT) AS [IsForeign],
            CAST(h.isModificationComplete AS BIT) AS [isModificationComplete],
            0 AS [tempPOHeaderID],
            
            -- Nested DetailList
            (
                SELECT
                    '232' AS [IPAddress],
                    h.UserProfileID AS [CreatedUserID],
                    h.UserProfileID AS [LastModUserID],
                    GETUTCDATE() AS [CreatedDate],
                    GETUTCDATE() AS [LastModDate],
                    0 AS [Id],
                    d.PoHeaderID,
                    0 AS [PoDetailID],
                    d.StockItemID,
                    d.StockName,
                    d.UnitID,
                    d.UnitName,
                    d.UnitPrice,
                    d.RequestedQuantity,
                    d.ApprovedQuantity,
                    d.ReceivedQuantity,
                    d.Remarks,
                    d.DiscountValue,
                    d.DiscountPercentage,
                    d.LocationID,
                    d.SupplierID,
                    d.RequestHeaderID,
                    d.TaxValue,
                    d.TBPHeaderId,
                    d.CurrentStock,
                    d.ItemTotal
                FROM @PoDetail d
                WHERE d.PoHeaderID = h.PoHeaderID
                FOR XML PATH('PoDetail'), TYPE, ROOT('DetailList')
            ),
            '' AS [AdditionalCharges]
        FROM @PoHeader h
        FOR XML PATH('PoHeader'), TYPE
    ).query('/*')

	EXEC Categlog_vrV2.[dbo].[SP_InsertPurchaseOrder] @XMLData ,@docNo OUTPUT, @headerid OUTPUT,1 -- Insert PO

	UPDATE RequestHeaders
	SET QuotationStatus = 'C'
	WHERE RequestType ='RP' AND Id=@PRID AND PropertyID= @PropertyID

	UPDATE QuotationRequestHeader
	SET Status = 'C'
	WHERE PurchaseRequestID = @PRID AND PropertyID = @PropertyID
	

	SET @OutTable =  (select distinct ph.Id id, ph.PoNo text FROM
	PoHeaders ph 
	INNER JOIN PoWisePRs pw ON ph.Id = pw.PoHeaderID
	WHERE pw.RequestHeaderID =@PRID FOR JSON PATH) -- Get Inserted PO doc Nos

	--SELECT @OutTable OutTable

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
	ROLLBACK TRANSACTION
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
END

GO

