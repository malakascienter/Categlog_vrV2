--EXEC PrintInvoiceFooter 190
CREATE PROCEDURE [dbo].[PrintInvoiceFooter](@InvoiceHeaderID int=1010)
AS

SET NOCOUNT ON

DECLARE @SubTotal VARCHAR(MAX), 
        @NunmberOfItems VARCHAR(MAX), 
		@Disocunt VARCHAR(MAX),
		@GrandTotal VARCHAR(MAX),
		@AmountReceived VARCHAR(MAX),
		@CashBalance VARCHAR(MAX),
		@CreditAmount VARCHAR(MAX)

SELECT  @SubTotal       = CAST((UnitPrice+ TaxValue) * QTY AS VARCHAR(MAX)) FROM [dbo].[InvoiceDetails] WHERE InvoiceHeaderID = @InvoiceHeaderID 
SELECT  @NunmberOfItems = 'NO OF ITEMS : '+CAST((SELECT COUNT(*) FROM dbo.InvoicePaymentsDetails WHERE InvoiceHeaderID = @InvoiceHeaderID) AS VARCHAR(MAX))
SELECT  @Disocunt       = CAST((SELECT TotalDiscount+ItemDiscountTotal FROM InvoiceHeaders WHERE ID = @InvoiceHeaderID ) AS VARCHAR(MAX)) 
SELECT  @GrandTotal     = CAST((SELECT GrossTotal FROM InvoiceHeaders WHERE ID = @InvoiceHeaderID) AS VARCHAR(MAX))
SELECT  @AmountReceived = CAST(SUM(TenderedAmount) AS VARCHAR(MAX)) FROM dbo.InvoicePaymentsDetails WHERE InvoiceHeaderID = @InvoiceHeaderID   
SELECT  @CashBalance    = CAST(ISNULL((SELECT BalanceAmount FROM dbo.InvoicePaymentsDetails WHERE InvoiceHeaderID = @InvoiceHeaderID AND PaymentTypeID = 4),0) AS VARCHAR(MAX)) 
SELECT  @CreditAmount   = CAST(ISNULL((SELECT BalanceAmount FROM dbo.InvoicePaymentsDetails WHERE InvoiceHeaderID = @InvoiceHeaderID AND PaymentTypeID = 1),0) AS VARCHAR(MAX)) 

DECLARE @InvoiceDetails AS TABLE (SEQ INT,LineTypeID INT, ID INT, Data VARCHAR(MAX))
DECLARE @PayTypesItems  AS TABLE (ID INT IDENTITY(1,1),Description VARCHAR(MAX),ActualAmount VARCHAR(MAX))

INSERT INTO @PayTypesItems (Description,ActualAmount)
SELECT UPPER(PT.Description),ActualAmount FROM dbo.InvoicePaymentsDetails IPD INNER JOIN dbo.PaymentTypes PT ON PT.ID = IPD.PaymentTypeID WHERE InvoiceHeaderID = @InvoiceHeaderID

INSERT INTO 	@InvoiceDetails VALUES (1,11,1,@NunmberOfItems)
INSERT INTO 	@InvoiceDetails VALUES (1,11,2,'SUB TOTAL : ')
INSERT INTO 	@InvoiceDetails VALUES (1,11,3,@SubTotal)

INSERT INTO 	@InvoiceDetails VALUES (2,11,1,'PAYMENT REFERENCE')
INSERT INTO 	@InvoiceDetails VALUES (2,11,2,'DISCOUNT : ')
INSERT INTO 	@InvoiceDetails VALUES (2,11,3,@Disocunt)

DECLARE         @ID INT  
               ,@Description VARCHAR(500)
			   ,@ActualAmount VARCHAR(500)
			   ,@SEQ INT = 3
                
WHILE EXISTS(SELECT TOP (1) ID FROM @PayTypesItems)
BEGIN

    SELECT TOP (1) @ID=ID,@Description=Description,@ActualAmount=ActualAmount
	FROM @PayTypesItems 

			INSERT INTO  @InvoiceDetails
	        VALUES (@SEQ,12,1,@Description)
	        
			INSERT INTO  @InvoiceDetails
	        VALUES (@SEQ,12,2,@ActualAmount)
	
		    INSERT INTO  @InvoiceDetails
	        VALUES (@SEQ,12,3,'')
	        SET @SEQ+=1

	DELETE FROM @PayTypesItems WHERE ID =@ID

END

--INSERT INTO 	@InvoiceDetails VALUES (3,12,4,'GRAND TOTAL : ')
--INSERT INTO 	@InvoiceDetails VALUES (3,12,5,@GrandTotal)

INSERT INTO 	@InvoiceDetails VALUES (@SEQ,11,1,'ABOVE ITEMS RECEIVED IN WORKING/GOOD CONDITION')
INSERT INTO 	@InvoiceDetails VALUES (@SEQ,11,2,'AMOUNT RECEIVED : ')
INSERT INTO 	@InvoiceDetails VALUES (@SEQ,11,3,@AmountReceived)
SET @SEQ+=1
INSERT INTO 	@InvoiceDetails VALUES (@SEQ,11,1,'SIGNATURE:....................................')
INSERT INTO 	@InvoiceDetails VALUES (@SEQ,11,2,'CASH BALANCE : ')
INSERT INTO 	@InvoiceDetails VALUES (@SEQ,11,3,@CashBalance)
SET @SEQ+=1
INSERT INTO 	@InvoiceDetails VALUES (@SEQ,11,1,'DISPATCH VEHICLE NO :')
INSERT INTO 	@InvoiceDetails VALUES (@SEQ,11,2,'CREDIT AMIUNT : ')
INSERT INTO 	@InvoiceDetails VALUES (@SEQ,11,3,@CreditAmount)

--SELECT * FROM @InvoiceDetails
--------------------------------------------------------------------------------
DECLARE @x AS XML =
(
SELECT SEQ , LineTypeID, (
							  SELECT ID,Data FROM @InvoiceDetails  PrintData 
							  WHERE Line.SEQ=PrintData.SEQ AND Line.ID=PrintData.ID
							  FOR XML AUTO,TYPE,ROOT('LineContent')
						 )FROM  @InvoiceDetails Line
FOR XML AUTO,ELEMENTS,ROOT('Bill')
)
--SELECT @x
EXEC [PrintMyBill] @x

GO

