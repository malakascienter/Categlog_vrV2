
--SP_Invoice_SerialCheck2 '',-1

CREATE PROCEDURE [dbo].[SP_Invoice_SerialCheck2]
    @InvoiceSrial VARCHAR(MAX) ,
    @result INT OUTPUT
AS
    BEGIN
		DECLARE 
			@sum INT
	IF(@InvoiceSrial <> NULL OR @InvoiceSrial <> '' )
	begin
       SELECT @sum=COUNT(Id)
	   FROM dbo.InvoiceSerials ISS
	   WHERE ISS.SerialNumber=@InvoiceSrial 
	   IF @sum >= 1
			SET @result=1
		ELSE
			SET @result=0

	END
    ELSE
    BEGIN
		SET @result=0
	end
   SELECT @result


    END

GO

