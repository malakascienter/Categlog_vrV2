

--exec [dbo].[SP_Save_StockItemTemplateDetails] '<ArrayOfStockItemTemplateDetails xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><StockItemTemplateDetails><Id>7</Id><TemplateName>template 3</TemplateName><StockItemID>2</StockItemID><CategoryID>1</CategoryID><CategoryName>CABLE</CategoryName><StockName>1.5 sq.mm, 1C, Cu/PVC/PVC Brown KELANI</StockName><UnitID>1</UnitID><MasterUnitID>1</MasterUnitID><UnitName>METER</UnitName><Quantity>5</Quantity><IsActive>true</IsActive></StockItemTemplateDetails><StockItemTemplateDetails><Id>7</Id><TemplateName>template 3</TemplateName><StockItemID>4949</StockItemID><CategoryID>3</CategoryID><CategoryName>ELECTRICAL EQUIPMENT/SITE</CategoryName><StockName>20A 3P 15kA MCCB EZC 3P/3T 100AF SCH</StockName><UnitID>3</UnitID><MasterUnitID>1</MasterUnitID><UnitName>NUMBERS</UnitName><Quantity>3</Quantity><IsActive>true</IsActive></StockItemTemplateDetails><StockItemTemplateDetails><Id>7</Id><TemplateName>template 3</TemplateName><StockItemID>7404</StockItemID><CategoryID>15</CategoryID><CategoryName>AAAA</CategoryName><StockName>XXX</StockName><UnitID>6</UnitID><MasterUnitID>1</MasterUnitID><UnitName>BOX</UnitName><Quantity>10</Quantity><IsActive>true</IsActive></StockItemTemplateDetails></ArrayOfStockItemTemplateDetails>'
CREATE Procedure [dbo].[SP_Save_StockItemTemplateDetails] (@XML VARCHAR(max))
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

SET @XML = REPLACE(@XML, 'xsi:nil="true"', '');
DECLARE @XML_1 XML = @XML
SET @XML_1.modify('delete (/ArrayOfStockItemTemplateDetails/StockItemTemplateDetails/StockName)')
SET @XML = CONVERT(VARCHAR(MAX),@XML_1)

        DECLARE @iDocID INT,
                @HeaderID INT,
                @loggedUserId INT,
                @Operation VARCHAR(MAX),
                @TemplateHeaderID VARCHAR(MAX),
                @TemplateName VARCHAR(MAX);
				

        EXEC sp_xml_preparedocument @iDocID OUTPUT,@XML;

        SELECT  @TemplateHeaderID=Id,@loggedUserId=loggedUser,@Operation=Operation,@TemplateName = TemplateName
        FROM     OPENXML (@iDocID,'/ArrayOfStockItemTemplateDetails/StockItemTemplateDetails',2)
        WITH    (Id INT,loggedUser VARCHAR(MAX),Operation VARCHAR(MAX),TemplateName VARCHAR(MAX));

        IF EXISTS(SELECT 1 FROM RequestTemplateHeader WHERE TemplateHeaderID = @TemplateHeaderID )
        BEGIN
            EXEC InsertMasterFileChangeLog 'Stock Item Template',@loggedUserId,'U',@TemplateName;
        END
        ELSE
            EXEC InsertMasterFileChangeLog 'Stock Item Template',@loggedUserId,'I',@TemplateName;

        DELETE FROM RequestTemplateHeader WHERE TemplateHeaderID = @TemplateHeaderID;
        DELETE FROM RequestTemplateDetails WHERE TemplateHeaderID = @TemplateHeaderID;

        -- Fixing the syntax issue by adding a semicolon before the 'WITH' clause
        INSERT INTO RequestTemplateHeader (Name,IsActive,CreatedUserID,ModifiedUserID,PropertyId,TransactionTypeCode,LocationList)
        SELECT TOP 1 TemplateName,IsActive,@loggedUserId,@loggedUserId,PropertyId,TransactionType,MultipleLocationID
        FROM     OPENXML (@iDocID,'/ArrayOfStockItemTemplateDetails/StockItemTemplateDetails',2)
        WITH    ( TemplateName VARCHAR(MAX),IsActive BIT,PropertyId INT,TransactionType nvarchar(max),MultipleLocationID nvarchar(max));

       

        IF(@loggedUserId = 0)
        BEGIN
            RAISERROR('User ID Invalid, Please Log In Again',16,1);
            ROLLBACK TRANSACTION;
        END

		ELSE
	BEGIN
    SET @HeaderID = SCOPE_IDENTITY(); -- Set @HeaderID after successful INSERT
	END
		 --SET @HeaderID = scope_identity();

        INSERT INTO RequestTemplateDetails (TemplateHeaderID,StockItemHeaderID,UnitID,Qty,CreatedUserID,ModifiedUserID)
        SELECT   @HeaderID,StockItemID,UnitID,Quantity,@loggedUserId,@loggedUserId
        FROM     OPENXML (@iDocID,'/ArrayOfStockItemTemplateDetails/StockItemTemplateDetails',2)
        WITH    ( StockItemID INT,UnitID INT,Quantity DECIMAL);



        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @message VARCHAR(MAX);
        SET @Message = 'Error Occured: ' + ERROR_MESSAGE() 
        RAISERROR(@message,16,1);

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        --PRINT ERROR_MESSAGE();
    END CATCH;
END;

GO

