-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- SP_UpdatePODetailsinPOApproval '<PODetailAddtionModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><PaymentMethodID>16</PaymentMethodID><PoNumber>MST/PO/000366</PoNumber><PoHeaderID>2390</PoHeaderID><AdditionalChargesList /><PropertyID>1</PropertyID><POType>2</POType></PODetailAddtionModel>'

CREATE PROCEDURE [dbo].[SP_UpdatePODetailsinPOApproval]
    @XMLDetails XML
    
AS
BEGIN
    BEGIN TRY
        DECLARE @iDocID INT;
        DECLARE @POHeaderID INT;
		DECLARE @PropertyID INT;
		DECLARE @IsPoModificationComponent INT;

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

        CREATE TABLE #POHeaderDetailsTemp (
            id INT IDENTITY(1,1),
            SupplierReferenceNo VARCHAR(50),
            PaymentMethodID INT,
            PoNumber VARCHAR(255),
            PoHeaderID INT,
			PropertyID INT,
			POType INT
        );

        CREATE TABLE #AdditionalCharges (
            Id INT,
            CompanyID INT,
            Name VARCHAR(255),
            IsAddToItemCost BIT,
            AccountID INT,
            IsActive BIT,
            CreatedUserID INT,
            LastModUserID INT,
            CreatedDate DATETIME,
            LastModDate DATETIME,
            Amount DECIMAL(18, 2)
        );

        INSERT INTO #POHeaderDetailsTemp (SupplierReferenceNo, PaymentMethodID, PoNumber, PoHeaderID,PropertyID,POType)
        SELECT SupplierReferenceNo,
               PaymentMethodID,
               PoNumber,
               PoHeaderID,
			   PropertyID,
			   POType
        FROM OPENXML (@iDocID, '/PODetailAddtionModel', 2)
        WITH (SupplierReferenceNo VARCHAR(50),
              PaymentMethodID INT,
              PoNumber VARCHAR(255),
              PoHeaderID INT,
			  PropertyID INT,
			  POType INT
			  );

        INSERT INTO #AdditionalCharges (Id, CompanyID, Name, IsAddToItemCost, AccountID, IsActive, CreatedUserID, LastModUserID, CreatedDate, LastModDate, Amount)
        SELECT Id, CompanyID,
               Name,
               IsAddToItemCost,
               AccountID,
               IsActive,
               CreatedUserID,
               LastModUserID,
               GETDATE(),
               GETDATE(),
               Amount
        FROM OPENXML (@iDocID, '/PODetailAddtionModel/AdditionalChargesList/AdditionalChargesDetails', 2)
        WITH (Id INT,
              CompanyID INT,
              Name VARCHAR(255),
              IsAddToItemCost BIT,
              AccountID INT,
              IsActive BIT,
              CreatedUserID INT,
              LastModUserID INT,
              CreatedDate VARCHAR(255),
              LastModDate VARCHAR(255),
              Amount DECIMAL(18, 2));

        SELECT @POHeaderID = PoHeaderID FROM #POHeaderDetailsTemp;

		SELECT @PropertyID = PropertyID FROM #POHeaderDetailsTemp;
        --SELECT @POHeaderID AS POHeaderID;

		set @IsPoModificationComponent = 
		(select IsPoModificationComponent from Companies where CompanyID = @PropertyID)


		--select @IsPoModificationComponent IsPoModificationComponent
		
        UPDATE PH
        SET PH.PaymentTermsDetailID = T.PaymentMethodID,
            PH.SupplierReferenceNo = T.SupplierReferenceNo,
			PH.POType = T.POType
        FROM PoHeaders PH
        INNER JOIN #POHeaderDetailsTemp T ON PH.id = T.PoHeaderID;

       -- SELECT Id FROM #AdditionalCharges;
       -- SELECT * FROM #AdditionalCharges;
	   if exists ( select * from POwiseCharges where POHeaderID = @POHeaderID)
	   begin
		delete from POwiseCharges where POHeaderID = @POHeaderID
	   end
	   
	
    --    INSERT INTO [dbo].[POwiseCharges]
    --    SELECT @PoHeaderID, Id, Amount 
    --    FROM #AdditionalCharges;

	 if NOT EXISTS (select * from POwiseCharges where POHeaderID = @POHeaderID)
	 begin
		INSERT INTO [dbo].[POwiseCharges]
        SELECT @PoHeaderID, Id, Amount 
        FROM #AdditionalCharges;

	 end

	 if(@IsPoModificationComponent =  1 )
	 begin
		update PoHeaders
		set isModificationComplete = 1 
		where id = @POHeaderID

	 end

	 else
	 begin
	 	update PoHeaders
		set isModificationComplete = 0 
		where id = @POHeaderID
	 end 

        DROP TABLE #POHeaderDetailsTemp;
		DROP TABLE #AdditionalCharges;

        EXEC sp_xml_removedocument @iDocID;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Send error message as output
        SELECT 
            ErrorMessage = @ErrorMessage,
            ErrorSeverity = @ErrorSeverity,
            ErrorState = @ErrorState;
    END CATCH;
END;

GO

