--SP_FindRateanalysisdetails 5265,19,1,"P",-1
--select * from BOQRateanalysisallocationdetails
-- select * from Rateanalysisdetails
-- [dbo].[SP_FindRateanalysisdetails] 5495,1,2,"I",-1
CREATE procedure [dbo].[SP_FindRateanalysisdetails] @StockItemID INT,@RateHeaderID INT,@Action INT,@BOQID INT,@type VARCHAR(max),@count INT OUTPUT

As
BEGIN
declare @count2 INT

IF(@type='I')
begin

If (@Action =1)
	BEGIN
	

	select @count2=count(Id) from Rateanalysisdetails where ItemheaderID=@StockItemID and RateAnalysisHeaderID=@RateHeaderID AND ItemType='I'
	set @count = @count2
	
	END 

Else if (@Action =2)
	BEGIN
	select @count2=count(Id) from BOQRateanalysisallocationdetails where ItemID =@StockItemID and RateID=@RateHeaderID AND ItemType='I' AND BOQID=@BOQID
	set @count =@count2

	END
END 


ELSE IF(@type='L')
BEGIN

If (@Action =1)
	BEGIN
	
	select @count2=count(Id) from Rateanalysisdetails where ItemheaderID=@StockItemID and RateAnalysisHeaderID=@RateHeaderID AND ItemType='L'
	set @count = @count2
	
	END 

Else if (@Action =2)
	BEGIN
	select @count2=count(Id) from BOQRateanalysisallocationdetails where ItemID =@StockItemID and RateID=@RateHeaderID AND ItemType='L' AND BOQID=@BOQID
	set @count =@count2

	END
end

Else 
	BEGIN
	select @count2=count(Id) from BOQRateanalysisallocationdetails where PackID =@StockItemID and RateID=@RateHeaderID AND ItemType='P'
	Set @count=@count2
	END


END

GO

