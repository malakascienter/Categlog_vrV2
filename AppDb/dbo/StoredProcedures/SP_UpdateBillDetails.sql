
--[dbo].[SP_UpdateBillDetails] '<ArrayOfWorkDoneloadingViewModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><WorkDoneloadingViewModel><ProjectID>0</ProjectID><Id>3</Id><BOQID>2</BOQID><WorkDoneID>1</WorkDoneID><MainworkId>2</MainworkId><MainWorkName>Section 1</MainWorkName><WorkId>0</WorkId><WorkName>Work 1</WorkName><AccessValue>0</AccessValue><BAmount>0</BAmount><TaxGroupId>0</TaxGroupId><amount>23</amount></WorkDoneloadingViewModel><WorkDoneloadingViewModel><ProjectID>0</ProjectID><Id>4</Id><BOQID>2</BOQID><WorkDoneID>2</WorkDoneID><MainworkId>2</MainworkId><MainWorkName>Section 1</MainWorkName><WorkId>0</WorkId><WorkName>Work 1</WorkName><AccessValue>0</AccessValue><BAmount>0</BAmount><TaxGroupId>0</TaxGroupId><amount>45</amount></WorkDoneloadingViewModel><WorkDoneloadingViewModel><ProjectID>0</ProjectID><Id>5</Id><BOQID>2</BOQID><WorkDoneID>3</WorkDoneID><MainworkId>2</MainworkId><MainWorkName>Section 1</MainWorkName><WorkId>0</WorkId><WorkName>Work 1</WorkName><AccessValue>0</AccessValue><BAmount>0</BAmount><TaxGroupId>0</TaxGroupId><amount>65</amount></WorkDoneloadingViewModel></ArrayOfWorkDoneloadingViewModel>'

CREATE PROCEDURE [dbo].[SP_UpdateBillDetails]
    @XMLDetails AS XML
    
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @iDocID INT;

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

		SELECT *
        FROM
        OPENXML(@iDocID, '/ArrayOfWorkDoneloadingViewModel/WorkDoneloadingViewModel', 2)
        WITH BillDetails;





		COMMIT TRAN; -- Transaction Success!
    END TRY
    BEGIN CATCH
        RETURN ERROR_MESSAGE(); -- CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN; --RollBack in case of Error
    END CATCH;

END;

GO

