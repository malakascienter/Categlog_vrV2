--EXEC PrintInvoiceFooter_DJ 186
CREATE PROCEDURE [dbo].[PrintInvoiceFooter_DJ](@InvoiceHeaderID int=1010)
AS

SET NOCOUNT ON

DECLARE @SubTotal VARCHAR(MAX), 
		@Cash VARCHAR(MAX),
		@Credit VARCHAR(MAX),
		@Balance VARCHAR(MAX)

SELECT  @SubTotal = CAST(SUM((UnitPrice+ TaxValue) * QTY) AS VARCHAR(MAX)) FROM [dbo].[InvoiceDetails] WHERE InvoiceHeaderID = @InvoiceHeaderID 
SET     @Cash =  CAST(ISNULL((SELECT ActualAmount FROM dbo.InvoicePaymentsDetails WHERE InvoiceHeaderID = @InvoiceHeaderID AND PaymentTypeID = 4),0) AS VARCHAR(MAX)) 
SET		@Credit = CAST(ISNULL((SELECT ActualAmount FROM dbo.InvoicePaymentsDetails WHERE InvoiceHeaderID = @InvoiceHeaderID AND PaymentTypeID = 1),0) AS VARCHAR(MAX)) 
SET		@Balance = CAST(ISNULL((SELECT BalanceAmount FROM dbo.InvoicePaymentsDetails WHERE InvoiceHeaderID = @InvoiceHeaderID AND PaymentTypeID = 4),0) AS VARCHAR(MAX))

DECLARE @InvoiceDetails AS TABLE (SEQ INT,LineTypeID INT, ID INT, Data VARCHAR(MAX))

INSERT INTO @InvoiceDetails VALUES (1,15,1,'')
INSERT INTO @InvoiceDetails VALUES (1,15,2,'')
INSERT INTO @InvoiceDetails VALUES (1,15,3,'Total')
INSERT INTO @InvoiceDetails VALUES (1,15,4,'')
INSERT INTO @InvoiceDetails VALUES (1,15,5,'')
INSERT INTO @InvoiceDetails VALUES (1,15,6,CAST(@SubTotal AS DECIMAL(10,2)))

INSERT INTO @InvoiceDetails VALUES (2,15,1,'')
INSERT INTO @InvoiceDetails VALUES (2,15,2,'')
INSERT INTO @InvoiceDetails VALUES (2,15,3,'Cash')
INSERT INTO @InvoiceDetails VALUES (2,15,4,'')
INSERT INTO @InvoiceDetails VALUES (2,15,5,'')
INSERT INTO @InvoiceDetails VALUES (2,15,6,CAST(@Cash AS DECIMAL(10,2)))

INSERT INTO @InvoiceDetails VALUES (3,15,1,'')
INSERT INTO @InvoiceDetails VALUES (3,15,2,'')
INSERT INTO @InvoiceDetails VALUES (3,15,3,'Credit')
INSERT INTO @InvoiceDetails VALUES (3,15,4,'')
INSERT INTO @InvoiceDetails VALUES (3,15,5,'')
INSERT INTO @InvoiceDetails VALUES (3,15,6,CAST(@Credit AS DECIMAL(10,2)))

INSERT INTO @InvoiceDetails VALUES (4,15,1,'')
INSERT INTO @InvoiceDetails VALUES (4,15,2,'')
INSERT INTO @InvoiceDetails VALUES (4,15,3,'Balance')
INSERT INTO @InvoiceDetails VALUES (4,15,4,'')
INSERT INTO @InvoiceDetails VALUES (4,15,5,'')
INSERT INTO @InvoiceDetails VALUES (4,15,6,CAST(@Balance AS DECIMAL(10,2)))
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

