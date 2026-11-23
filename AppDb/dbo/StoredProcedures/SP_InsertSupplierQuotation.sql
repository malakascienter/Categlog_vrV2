--[dbo].[SP_InsertSupplierQuotation] '<SupplierQuotation xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id xsi:nil="true" /><CompanyId>1</CompanyId><CategoryId>0</CategoryId><IsActive>true</IsActive><LeadTimeExpire>2</LeadTimeExpire><QuotationNo>43</QuotationNo><ReferenceNo>32</ReferenceNo><Remarks>3242</Remarks><SupplierId>1110</SupplierId><ValidFrom>2020-09-24T00:00:00</ValidFrom><ValidTo>2020-10-10T00:00:00</ValidTo><SupplierName>TEST ALL 003</SupplierName><CompanyName>HOTEL DOLPHIN</CompanyName><PropertyList><GridSelect><id>1</id><text>HOTEL DOLPHIN</text></GridSelect><GridSelect><id>2</id><text>HOTEL SIGIRIYA</text></GridSelect></PropertyList><Itemdetails><QuotationItemDetais><ItemId>1</ItemId><UnitNme>KILOGRAM</UnitNme><UnitId>2</UnitId><UnitPrice>200</UnitPrice><TaxGroup>1013</TaxGroup><TaxGroupName>VAT15</TaxGroupName><ItemName>CHICKEN 1KG</ItemName><ItemCode>FOOD/001</ItemCode></QuotationItemDetais></Itemdetails></SupplierQuotation>'
--go
CREATE PROCEDURE [dbo].[SP_InsertSupplierQuotation]( @XMLDetails XML, @DocNo VARCHAR(100) = '' OUT  )
AS
DECLARE @iDocID INT,@QuotationHeaderId INT 
BEGIN

	BEGIN TRY 
	BEGIN TRANSACTION
	  EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

	  	SELECT * INTO #TempProperties
		FROM 
		OPENXML(@iDocID, '/SupplierQuotation/PropertyList/GridSelect', 2)
		WITH(id INT,text VARCHAR(200))

		select * from #TempProperties

		SELECT * INTO #TempQuotationHeader
        FROM
        OPENXML(@iDocID, '/SupplierQuotation', 2)
		WITH (CompanyId INT ,CategoryId INT , IsActive BIT ,LeadTimeExpire INT ,QuotationNo VARCHAR( 250) , 
		ReferenceNo VARCHAR( 250) , Remarks VARCHAR( 250) , SupplierId INT ,ValidFrom DATE , ValidTo DATE ,
		CategoryName VARCHAR( 250), SupplierName VARCHAR( 250),CompanyName VARCHAR( 250), IsDefaultSupplier BIT,UserId INT)

		SELECT * INTO #TempQuotationDetails
        FROM
        OPENXML(@iDocID, '/SupplierQuotation/Itemdetails/QuotationItemDetais', 2)
		WITH (ItemId INT ,UnitNme VARCHAR( 250), UnitId INT , UnitPrice DECIMAL (18,6),	TaxGroup INT ,TaxGroupName VARCHAR( 250),
		ItemName VARCHAR( 250),PropertyId INT)

		INSERT INTO [dbo].[SupplierQuotationHeader]([SupplierId],[QuotationNo],[ReferenceNo],
		[ValidFrom],[ValidTo],[IsActive],[Status],[Remarks],[LeadTimeExpireDays],[IsDefaultSupplier],[CreatedUserId])
		SELECT SupplierId,QuotationNo,ReferenceNo,ValidFrom,ValidTo,IsActive,'P',Remarks,LeadTimeExpire,IsDefaultSupplier,UserId
		FROM #TempQuotationHeader

		SET @QuotationHeaderId = SCOPE_IDENTITY()
		
		DECLARE @PropertyId INT
			WHILE (SELECT COUNT(*) FROM #TempProperties)>0
			BEGIN
				SELECT TOP(1)@PropertyId = id FROM #TempProperties

				INSERT INTO [dbo].[QuotationWiseProperties] VALUES(@QuotationHeaderId,@PropertyId)

				DELETE TOP(1)FROM #TempProperties
			END
			


				INSERT INTO [dbo].[SupplierQuotationDetails] ([QuotationHeaderId],[ItemId],[UnitId],[UnitPrice],[TaxGroupId],[PropertyId])
				SELECT @QuotationHeaderId, ItemId, UnitId, UnitPrice,TaxGroup,PropertyId FROM #TempQuotationDetails


	---------------------Generate Quotaton No-----------------------------
	DECLARE @DocumentNo VARCHAR(50),@LocationID INT = -999, @Prefix CHAR(5)
				SET @DocumentNo = dbo.FN_GetNextDocumentNumber(2, @LocationID, 'QO');
		
				IF @DocumentNo IS NULL
				BEGIN

					INSERT INTO TransactionTypeWiseNextNumbers
					(
						PropertyID,
						LocationID,
						TransactionType,
						NextNumber,
						LengthOfFormatting
					)
					VALUES
					(2, @LocationID, 'QO', 1, 6);

					SET @DocumentNo = dbo.FN_GetNextDocumentNumber(2, @LocationID, 'QO');

				END;

				SET @Prefix = 'SQ'
				SET @DocumentNo = @Prefix + '/' + @DocumentNo;
				SET @DocNo = @DocumentNo

				UPDATE TransactionTypeWiseNextNumbers
				SET NextNumber = NextNumber + 1
				WHERE LocationID = @LocationID
				AND TransactionType =  'QO';

				UPDATE [dbo].[SupplierQuotationHeader]
				SET QuotationNo = @DocumentNo
				WHERE Id = @QuotationHeaderId
----------------Generate Quotation No---------------------

	COMMIT TRANSACTION
	END TRY 
	BEGIN CATCH 
		ROLLBACK TRANSACTION 
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  
		PRINT 'hhhh'
		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
    
END

GO

