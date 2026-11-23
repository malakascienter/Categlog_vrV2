 --exec [PrintInvoiceSTC]  187
CREATE   procedure [dbo].[PrintInvoiceSTC](@InvoiceHeaderID INT)
AS 

SET NOCOUNT ON



DECLARE @temp AS TABLE (ID INT,TextLine VARCHAR(MAX))
DECLARE @Itemtemp AS TABLE (Row INT NOT null IDENTITY(1,1),ID INT,TextLine VARCHAR(MAX))


	--DECLARE @x int =1
	
	--WHILE @x<15
	--BEGIN
	--	INSERT INTO @temp 
	--	VALUES(@x,''+@x)

	--	SET @x+=1
	--end	

	--SET @x+=1
	--INSERT INTO @temp 
	-- VALUES(@x,'{NEWPAGE}')

	--WHILE @x<50
	--BEGIN
		
	--	INSERT INTO @temp 
	--	VALUES(@x,''+@x)

	--	SET @x+=1
	--end	

INSERT INTO @temp
EXEC PrintInvoiceheaderInfo @InvoiceHeaderID

INSERT INTO @itemtemp  (ID,TextLine)
EXEC PrintInvoiceDetails @InvoiceHeaderID

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
	
	IF 	@x<=@itemLineCount
	INSERT INTO @temp
	EXEC PrintInvoiceheaderInfo @InvoiceHeaderID

	SET @x+=1
	INSERT INTO @temp 
	VALUES(@x,'')

	DECLARE @r INT =0

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
			
			PRINT 	  '{NEWPAGE}' + CONVERT(varchar,@x)
			
			INSERT INTO @temp
			EXEC PrintInvoiceheaderInfo @InvoiceHeaderID
			SET @x+=1
			INSERT INTO @temp 
			VALUES(@x,'')
        END
	END 
END 
ELSE
BEGIN

	INSERT INTO @temp
	SELECT ID,TextLine FROM @Itemtemp
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

END

INSERT INTO @temp
EXEC PrintInvoiceFooter @InvoiceHeaderID
	   

SELECT * FROM @temp

GO

