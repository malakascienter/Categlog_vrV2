--EXEC  [PrintInvoice_DJ] 186 190  
CREATE PROCEDURE [dbo].[PrintInvoice_DJ](@InvoiceHeaderID INT)
AS 

SET NOCOUNT ON

DECLARE @temp AS TABLE (ID INT,TextLine VARCHAR(MAX))
DECLARE @Itemtemp AS TABLE (Row INT NOT NULL IDENTITY(1,1),ID INT,TextLine VARCHAR(MAX))

INSERT INTO @temp
EXEC PrintInvoiceheaderInfo_DJ @InvoiceHeaderID

DECLARE @HeaderLineCount INT
SELECT @HeaderLineCount=COUNT(ID) FROM @temp

	INSERT INTO @temp 
	VALUES(@HeaderLineCount+1,'{12CPI}')

INSERT INTO @itemtemp  (ID,TextLine)
EXEC PrintInvoiceDetails_DJ @InvoiceHeaderID

DECLARE @itemLineCount INT
SELECT @itemLineCount=COUNT(row) FROM @Itemtemp

IF (@itemLineCount)>15
BEGIN
	
	INSERT INTO @temp
	SELECT TOP (16) ID,TextLine FROM @Itemtemp
	ORDER BY row
	
	DECLARE @x int =16
	
	SET @x+=1
	INSERT INTO @temp 
	VALUES(@x,'{NEWPAGE}')

	INSERT INTO @temp 
	VALUES(@x+1,'{10CPI}')
	
	IF 	@x<=@itemLineCount
	INSERT INTO @temp
	EXEC PrintInvoiceheaderInfo_DJ @InvoiceHeaderID

	SET @x+=1
	INSERT INTO @temp 
	VALUES(@x,'')

	DECLARE @r INT =0

	    INSERT INTO @temp 
		VALUES(@x+1,'{12CPI}')

	WHILE @x<=@itemLineCount
	BEGIN

		INSERT INTO @temp
		SELECT ID,TextLine FROM @Itemtemp
		WHERE row=@x

		SET @x+=1
		SET @r+=1
		IF (@r % 15)=0 AND @r>0 AND @x<@itemLineCount
		BEGIN
			SET @r=1
			INSERT INTO @temp 
			VALUES(@x+1,'{NEWPAGE}')

			INSERT INTO @temp 
		    VALUES(@x+1,'{10CPI}')
			
			PRINT 	  '{NEWPAGE}' + CONVERT(varchar,@x)
			
			INSERT INTO @temp
			EXEC PrintInvoiceheaderInfo_DJ @InvoiceHeaderID
			SET @x+=1
			INSERT INTO @temp 
			VALUES(@x,'')

			INSERT INTO @temp 
		    VALUES(@x+1,'{12CPI}')
        END
	END 

END 
ELSE
BEGIN

	INSERT INTO @temp
	SELECT ID,TextLine 
	FROM @Itemtemp
	ORDER BY row 

END 

IF @itemLineCount %15<> 0
BEGIN
	DECLARE @bal INT =0
	WHILE @bal <= 15 -(@itemLineCount %15)
	BEGIN
		INSERT INTO @temp
		VALUES (@bal,'')
		SET @bal+=1
	END 
	--INSERT INTO @temp 
	--VALUES(@x+1,'{10CPI}')
END

INSERT INTO @temp
EXEC PrintInvoiceFooter_DJ @InvoiceHeaderID
	   

SELECT * FROM @temp

GO

