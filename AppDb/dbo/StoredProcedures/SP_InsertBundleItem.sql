CREATE Procedure [dbo].[SP_InsertBundleItem] (@XMLDetails as XML , @docID VARCHAR(MAX) OUTPUT)
AS 
DECLARE @iDocID INT 



BEGIN TRY
BEGIN TRANSACTION
EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;


--DECLARE @InvoiceHeaderID INT,
--        @DocumentNo VARCHAR(6),
--        @PropertyID INT,
--		@LocationID INT,
--		@DepartmentID INT,
--		@CreatedUserID INT,
--		@TempInvoiceHeaderId INT,
--		@TempInvoiceDetailId INT  = -1,
--		@StockTransactionHeaderID INT,
--		@TempItemId INT,
--		@TempQty DECIMAL(18, 2),
--		@TempunitID INT,
--		@TempAveragePrice money = 0   


--SELECT  @InvoiceHeaderID=InvoiceHeaderID
--	   FROM     OPENXML (@iDocID,'ArrayOfInvoicePaymentsDetails/InvoicePaymentsDetails',2)
--WITH  (InvoiceHeaderID INT)

--SELECT  @PropertyID=PropertyID,@LocationID=Location,@DepartmentID=DepartmentID,@CreatedUserID=CreatedUserID FROM Temp_InvoiceHeader	WHERE ID = @InvoiceHeaderID

--SELECT @DocumentNo = dbo.FN_GetNextDocumentNumber (@PropertyID,@LocationID,'II')
--UPDATE  dbo.TransactionTypeWiseNextNumbers SET NextNumber = NextNumber+1 
--WHERE PropertyID = @PropertyID AND LocationID = @LocationID
--SET @iDocID=1


DECLARE @BundleStockItemHeaderId INT


SELECT  @BundleStockItemHeaderId=BundleStockItemHeaderId
	   FROM     OPENXML (@iDocID,'ArrayOfBundleItems/BundleItems',2)
WITH  (BundleStockItemHeaderId INT)


IF EXISTS(Select * from BundleItems where BundleStockItemHeaderId=@BundleStockItemHeaderId)
  delete  from BundleItems where BundleStockItemHeaderId=@BundleStockItemHeaderId






INSERT  INTO BundleItems  
      (
     
	   BundleStockItemHeaderId,
	   DetailStockItemHeaderId,
	   Quantity,
	   IPAddress,
	   CreatedUserID,
	   LastModUserID,
	   CreatedDate,
	   LastModDate
	   )

select 
       
	   BundleStockItemHeaderId,
	   DetailStockItemHeaderId,
	   Quantity,
	   IPAddress,
	   CreatedUserID,
	   LastModUserID,
	   CreatedDate,
	   LastModDate
	   FROM  OPENXML (@iDocID,'ArrayOfBundleItems/BundleItems',2) 
	  
--with (InvoiceNumber VARCHAR(max),
--InoviceDetailId INT,
--       stockItemId INT ,
--       RequestQuantity DECIMAL,
--       LocationId INT,
--       PropertyId INT,
--	   InventoryDate DATE,
--	   SerialNumber NVARCHAR(MAX),
--       IPAddress NVARCHAR(MAX),
--       CreatedUserID INT,
--       LastModUserID INT,
--       CreatedDate DATE,
--       LastModDate DATE);



--select 
--       InvoiceNumber,
--       InoviceDetailId,
--       stockItemId,
--       RequestQuantity,
--       LocationId,
--       PropertyId,
--	   InventoryDate,
--	   SerialNumber,
--       IPAddress,
--       CreatedUserID,
--       LastModUserID,
--       CreatedDate,
--       LastModDate
--	   INTO #TEMP
--	   FROM     OPENXML (@iDocID,'ArrayOfInvoiceSerial/InvoiceSerial',2)
	  
with BundleItems

--SELECT * FROM #TEMP

EXEC  sp_xml_removedocument @iDocID

COMMIT TRAN 
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN 
END CATCH

GO

