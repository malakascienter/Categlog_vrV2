-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-03
-- Description:	Saving Supplier Evaluation 

-- [dbo].[SP_SaveSupplierEvaluationCriteria] '<ArrayOfSupplierEvaluationMarks xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><SupplierEvaluationMarks><ProcurementID>1</ProcurementID><LocationID>1</LocationID><SupplierID>1284</SupplierID><SupplierQuotationID>3</SupplierQuotationID><EvaluationTemplateName>TEST</EvaluationTemplateName><Criteria>spped</Criteria><MaxMarks>80</MaxMarks><AssignedScore>10</AssignedScore><CriteriaID>1</CriteriaID><EvaluationTemplateID>2</EvaluationTemplateID><UserID>4168</UserID></SupplierEvaluationMarks><SupplierEvaluationMarks><ProcurementID>1</ProcurementID><LocationID>1</LocationID><SupplierID>1284</SupplierID><SupplierQuotationID>3</SupplierQuotationID><EvaluationTemplateName>TEST</EvaluationTemplateName><Criteria>Quality</Criteria><MaxMarks>90</MaxMarks><AssignedScore>50</AssignedScore><CriteriaID>2</CriteriaID><EvaluationTemplateID>2</EvaluationTemplateID><UserID>4168</UserID></SupplierEvaluationMarks><SupplierEvaluationMarks><ProcurementID>1</ProcurementID><LocationID>1</LocationID><SupplierID>1284</SupplierID><SupplierQuotationID>3</SupplierQuotationID><EvaluationTemplateName>TEST</EvaluationTemplateName><Criteria>Time</Criteria><MaxMarks>95</MaxMarks><AssignedScore>60</AssignedScore><CriteriaID>3</CriteriaID><EvaluationTemplateID>2</EvaluationTemplateID><UserID>4168</UserID></SupplierEvaluationMarks></ArrayOfSupplierEvaluationMarks>'

-- =============================================
CREATE PROCEDURE [dbo].[SP_SaveSupplierEvaluationCriteria]
 @XMLData AS XML
 
AS
BEGIN
	DECLARE @iDocID INT;
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

		DECLARE @SupplierQuotationID INT,@ProcurementID INT

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

		SELECT TOP (1) @SupplierQuotationID = SupplierQuotationID,@ProcurementID =ProcurementID
		FROM #TempAllDetails

		UPDATE SupplierQuotation
		SET StatusID =2 -- Updating Status as Evaluated, refer SupplierQuotationStatus table
		WHERE ID = @SupplierQuotationID

		INSERT  INTO ProcurementEvaluation(ProcurementID, SupplierID, EvaluationCriteriaID, AssignedScore, Criteria, MaxMarks,UserID)
		SELECT ProcurementID,SupplierID,CriteriaID,AssignedScore,Criteria,MaxMarks,UserID
		FROM #TempAllDetails

		SELECT *
		FROM #TempAllDetails

		IF NOT EXISTS(SELECT 1 FROM SupplierQuotation WHERE ProcurementID = @ProcurementID AND StatusID =1)
		BEGIN
			
			UPDATE ProcurementRequest
			SET StatusID =4 -- Updating Status as Evaluated, refer ProcurementStatus table
			WHERE ID = @ProcurementID

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

