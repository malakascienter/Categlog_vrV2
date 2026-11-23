-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-05
-- Description:	Save Procurement Evaluation Approval
-- [dbo].[SP_ApproveSupplierEvaluation] '<ArrayOfSupplierEvaluationMarks xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><SupplierEvaluationMarks><ProcurementID>1</ProcurementID><LocationID>1</LocationID><SupplierID>1</SupplierID><SupplierQuotationID>1</SupplierQuotationID><EvaluationTemplateName>TEST</EvaluationTemplateName><Criteria>spped</Criteria><MaxMarks>80</MaxMarks><AssignedScore>55</AssignedScore><CriteriaID>1</CriteriaID><EvaluationTemplateID>2</EvaluationTemplateID><UserID>4168</UserID><QuotationFile /></SupplierEvaluationMarks><SupplierEvaluationMarks><ProcurementID>1</ProcurementID><LocationID>1</LocationID><SupplierID>1</SupplierID><SupplierQuotationID>1</SupplierQuotationID><EvaluationTemplateName>TEST</EvaluationTemplateName><Criteria>Quality</Criteria><MaxMarks>90</MaxMarks><AssignedScore>55</AssignedScore><CriteriaID>2</CriteriaID><EvaluationTemplateID>2</EvaluationTemplateID><UserID>4168</UserID><QuotationFile /></SupplierEvaluationMarks><SupplierEvaluationMarks><ProcurementID>1</ProcurementID><LocationID>1</LocationID><SupplierID>1</SupplierID><SupplierQuotationID>1</SupplierQuotationID><EvaluationTemplateName>TEST</EvaluationTemplateName><Criteria>Time</Criteria><MaxMarks>95</MaxMarks><AssignedScore>55</AssignedScore><CriteriaID>3</CriteriaID><EvaluationTemplateID>2</EvaluationTemplateID><UserID>4168</UserID><QuotationFile /></SupplierEvaluationMarks></ArrayOfSupplierEvaluationMarks>'


-- =============================================
CREATE PROCEDURE [dbo].[SP_ApproveSupplierEvaluation]
 @XMLData AS XML
AS
BEGIN
	DECLARE @iDocID INT;
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

		DECLARE @SupplierQuotationID INT,@ProcurementID INT,@UserID INT,@SupplierID INT,@NewId INT,@CompanyID INT
		,@XMLRequestItemString XML,@LocationId INT,@ItemID INT,@IsContractedSupplier BIT

		DECLARE @InvoiceError VARCHAR(500)




		IF OBJECT_ID('tempdb..#TempAllDetails') IS NOT NULL
            DROP TABLE #TempAllDetails;
		
		

		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;

		  SELECT ProcurementID, LocationID, SupplierID, SupplierQuotationID, EvaluationTemplateName, Criteria, MaxMarks,AssignedScore,
		  CriteriaID,EvaluationTemplateID,UserID
        INTO #TempAllDetails
        FROM OPENXML(@iDocID, '/ArrayOfSupplierEvaluationMarks/SupplierEvaluationMarks', 2)
        WITH (
            ProcurementID INT,
            LocationID INT,
            SupplierID INT,
            SupplierQuotationID INT,
            EvaluationTemplateName VARCHAR(200),
            Criteria VARCHAR(200),
            MaxMarks INT,
			AssignedScore INT,
			CriteriaID INT,
			EvaluationTemplateID INT,
			UserID INT
        );

		SELECT TOP (1)  @ProcurementID= ProcurementID,@SupplierID=  SupplierID,@UserID= UserID,@SupplierQuotationID =SupplierQuotationID
		,@UserID = UserID,@LocationId = LocationId
		FROM #TempAllDetails

		select *
		from #TempAllDetails

		SELECT @CompanyID = CompanyID,@XMLRequestItemString  =XMLRequestItem,@ItemID = ItemID
		FROM ProcurementRequest
		WHERE ID = @ProcurementID

		SELECT @IsContractedSupplier =IsContractedSupplier
		FROM Companies
		WHERE CompanyID = @CompanyID


		UPDATE ProcurementRequest
		SET StatusID =2 -- Updating Status as Complete, refer ProcurementStatus table
		WHERE ID = @ProcurementID



		UPDATE SupplierQuotation
		SET StatusID = 3 -- Updating Status as Complete, refer SupplierQuotationStatus table
		,ApprovedUserID = @UserID
		WHERE ID = @SupplierQuotationID



		UPDATE SupplierQuotation
		SET StatusID = 4 -- Updating Status as Rejected, refer SupplierQuotationStatus table
		,ApprovedUserID = @UserID
		WHERE ProcurementID = @ProcurementID
		AND ID NOT IN (@SupplierQuotationID)
		AND StatusID <>3

		--If already exist item
		IF EXISTS(SELECT 1 FROM ProcurementRequest PR INNER JOIN StockItemHeaders SH ON PR.ItemID = SH.Id WHERE PR.ID = @ProcurementID)
		BEGIN

		select @SupplierID SupplierID,@LocationId  LocationId,@ItemID ItemID
		--INSERT INTO SupplierWiseItemDetails
		SELECT * FROM SupplierWiseItemDetails WHERE SupplierID = @SupplierID AND LocationId = @LocationId AND StockItemID = @ItemID

		IF NOT EXISTS(SELECT 1 FROM SupplierWiseItemDetails WHERE SupplierID = @SupplierID AND LocationId = @LocationId AND StockItemID = @ItemID)
		BEGIN
			UPDATE SupplierWiseItemDetails
			SET IsDefaultSupplier = 0,IsContractedSupplier = 0
			WHERE  LocationId = @LocationId AND StockItemID = @ItemID 

			INSERT INTO  SupplierWiseItemDetails(CompanyId, LocationId, SupplierID, StockItemID, PurchaseUnitID, CostPrice, IsDefaultSupplier, CreatedUserID, LastModUserID, 
						CreatedDate, LastModDate, IPAddress, TBPHeaderID, TaxGroupID, Validfrom, ValidTo, IsContractedSupplier)

			SELECT PR.CompanyID,PR.LocationID,SQ.SupplierID,PR.ItemID StockItemID,PR.UnitID PurchaseUnitID,SQ.Price CostPrice,1 IsDefaultSupplier,@UserID CreatedUserID,@UserID LastModUserID,
			GETDATE() CreatedDate,GETDATE() LastModDate,'' IPAddress,0 TBPHeaderID,SQ.TaxGroupId,NULL Validfrom,NULL ValidTo
			,CASE WHEN @IsContractedSupplier = 1 THEN 1 ELSE 0 END AS IsContractedSupplier
			FROM ProcurementRequest PR
			INNER JOIN SupplierQuotation SQ ON PR.ID = SQ.ProcurementID
			WHERE PR.ID = @ProcurementID AND SQ.ID = @SupplierQuotationID
			AND PR.StatusID =2
			AND SQ.StatusID=3

			SELECT SCOPE_IDENTITY() AS Id
			SET @NewId = SCOPE_IDENTITY()

			EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @NewId, 'INV', 'SWDI', 'I', @UserID,@CompanyID, '', ''

			--Added by Isuru 2025-05-15
			EXEC  [dbo].[SendSupplierQuotationEmail] @ProcurementID,@SupplierID,@ItemID,@CompanyID
			--End
		END
		ELSE
		BEGIN
		DECLARE @CostPrice DECIMAL(18,6),@TaxGroupID INT,@PurchaseUnitID INT,@SupplierWiseItemID INT

		UPDATE SupplierWiseItemDetails
		SET IsDefaultSupplier = 0,IsContractedSupplier = 0
		WHERE  LocationId = @LocationId AND StockItemID = @ItemID 

		SELECT @CostPrice = SQ.Price ,@TaxGroupID = SQ.TaxGroupId,@PurchaseUnitID = PR.UnitID
		FROM ProcurementRequest PR
		INNER JOIN SupplierQuotation SQ ON PR.ID = SQ.ProcurementID
		WHERE PR.ID = @ProcurementID AND SQ.ID = @SupplierQuotationID
		AND PR.StatusID =2
		AND SQ.StatusID=3

		SELECT @SupplierWiseItemID = Id
		FROM SupplierWiseItemDetails
		WHERE SupplierID = @SupplierID AND LocationId = @LocationId AND StockItemID = @ItemID 

		UPDATE SupplierWiseItemDetails
		SET CostPrice = @CostPrice,TaxGroupID = @TaxGroupID,PurchaseUnitID = @PurchaseUnitID ,IsDefaultSupplier = 1,
		IsContractedSupplier = CASE WHEN @IsContractedSupplier = 1 THEN 1 ELSE 0 END
		,LastModUserID = @UserID,LastModDate = GETDATE()
		WHERE SupplierID = @SupplierID AND LocationId = @LocationId AND StockItemID = @ItemID 

		EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @SupplierWiseItemID, 'INV', 'SWDU', 'U', @UserID,@CompanyID, '', ''

			

		END
		END
		ELSE
		BEGIN
		
		DECLARE @OutputInsertedID INT
		EXEC [dbo].[SP_InsertStockItemrequest] @XMLRequestItemString, 1, @OutputInsertedID OUTPUT;

		select @OutputInsertedID OutputInsertedID

		IF(@OutputInsertedID IS NOT NULL)
		BEGIN
		UPDATE ProcurementRequest
		SET StockItemRequestID = @OutputInsertedID
		WHERE Id = @ProcurementID
		END

		END

   
        EXEC sp_xml_removedocument @iDocID;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        ROLLBACK TRANSACTION;

        IF @iDocID IS NOT NULL
            EXEC sp_xml_removedocument @iDocID;

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END

GO

