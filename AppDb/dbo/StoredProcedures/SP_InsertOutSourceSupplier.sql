CREATE PROCEDURE [dbo].[SP_InsertOutSourceSupplier] @XMLDetails AS XML,
                                                   @docID      VARCHAR(MAX) OUTPUT,
                                                   @headerid   INT OUTPUT
AS
     BEGIN
         BEGIN TRY
             BEGIN TRANSACTION;
             DECLARE @iDocID INT;
             EXEC sp_xml_preparedocument
                  @iDocID OUTPUT,
                  @XMLDetails;
             DECLARE @OutSourceID INT, @LocationID INT, @PropertyID INT, @DocumentNo VARCHAR(MAX), @RequestType VARCHAR(3), @TransactionTypeID INT;
             SELECT @RequestType = TransactionType,
                    @LocationID = LocationID,
                    @PropertyID = PropertyID
             FROM OPENXML(@iDocID, '/BillHeader', 2) WITH(TransactionType VARCHAR(3), LocationID INT, PropertyID INT);


--handling Document numbers *************************************************************************
             SELECT @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @RequestType);
             IF @DocumentNo IS NULL
                 BEGIN
                     INSERT INTO TransactionTypeWiseNextNumbers
(PropertyID,
 LocationID,
 TransactionType,
 NextNumber,
 LengthOfFormatting
)
                     VALUES
(@PropertyID,
 @LocationID,
 @RequestType,
 1,
 6
);
                     SELECT @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @RequestType);
                 END;
             UPDATE TransactionTypeWiseNextNumbers
               SET
                   NextNumber = NextNumber + 1
             WHERE locationid = @LocationID
                   AND transactionType = @RequestType;
             SELECT @TransactionTypeID = Id
             FROM TransactionTypes
             WHERE code = @RequestType;
             INSERT INTO [dbo].[CustomerSuppliedStockHeaders]
					([TxnNumber],
					 [TxnDate],
					 [ProjectID],
					 [CustID],
					 [BOQID],
					 [deptID],
					 [TotalValue],
					 [Status],
					 [Completed],
					 [Billed],
					 [BillNumber],
					 [invoiced],
					 [invoiceNo]
					)
                    SELECT [TxnNumber],
                           [TxnDate],
                           [ProjectID],
                           [CustID],
                           [BOQID],
                           [deptID],
                           [TotalValue],
                           [Status],
                           [Completed],
                           [Billed],
                           [BillNumber],
                           [invoiced],
                           [invoiceNo]
                    FROM OPENXML(@iDocID, '/BillHeader', 2) WITH CustomerSuppliedStockHeaders;

             SELECT @OutSourceID = SCOPE_IDENTITY();

INSERT INTO CustomerSuppliedStockDetails
           ([HeaderID]
           ,[ItemID]
           ,[unitID]
           ,[UnitPrice]
           ,[Qunatity]
           ,[TotalValue])
		   SELECT 
		   [HeaderID]
           ,[ItemID]
           ,[unitID]
           ,[UnitPrice]
           ,[Qunatity]
           ,[TotalValue]
             FROM OPENXML(@iDocID, '/BillHeader/BillDetails/BillDetail', 2) WITH CustomerSuppliedStockDetails
	
-- INSERT GRN

--Assiugn Header and Doc No
             SET @docID = @DocumentNo;
             SET @headerid = @OutSourceID;
             EXEC dbo.SP_InsertApprovalLevelForRequest
                  @PropertyID,
                  @LocationID,
                  @TransactionTypeID,
                  @OutSourceID;
             COMMIT TRAN; -- Transaction Success!
         END TRY
         BEGIN CATCH
             RETURN CAST(ERROR_NUMBER() AS VARCHAR(10))+' - '+ERROR_MESSAGE()+' - On Line '+CAST(ERROR_LINE() AS VARCHAR(10));
             IF @@TRANCOUNT > 0
                 ROLLBACK TRAN; --RollBack in case of Error
         END CATCH;
     END;

GO

