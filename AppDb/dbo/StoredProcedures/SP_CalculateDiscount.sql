 --EXEC  [SP_CalculateDiscount] '<TotalDiscount xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><DiscountType>0</DiscountType><IsPercentage>false</IsPercentage><Value>10.0</Value><Discount>0.0</Discount><ItemDiscountInformation><ItemDiscountInformation><StockItemHeaderId>16</StockItemHeaderId><Quantity>1</Quantity><UnitPrice>2560.00</UnitPrice><LineTotal>2560.00</LineTotal><DiscountType>0</DiscountType><IsPercentage>false</IsPercentage><Value>10.0</Value><Discount>0.0</Discount><DiscountApplicable>true</DiscountApplicable></ItemDiscountInformation><ItemDiscountInformation><StockItemHeaderId>2</StockItemHeaderId><Quantity>1</Quantity><UnitPrice>340.00</UnitPrice><LineTotal>340.00</LineTotal><DiscountType>0</DiscountType><IsPercentage>false</IsPercentage><Value>0.0</Value><Discount>0.0</Discount><DiscountApplicable>false</DiscountApplicable></ItemDiscountInformation></ItemDiscountInformation></TotalDiscount>'
CREATE  PROCEDURE [dbo].[SP_CalculateDiscount]
    (
      @DiscountXml AS XML 
    )
AS
BEGIN
    BEGIN TRY
         BEGIN TRANSACTION

declare @TotalDiscount as table (DiscountType int,IsPercentage bit,Value decimal (18,2), Discount decimal (18,2))
declare @ItemDiscountInformation as table (StockItemHeaderId int, Quantity decimal(18,2), UnitPrice decimal(18,2), LineTotal decimal(18,2), DiscountType int, IsPercentage bit, Value  decimal(18,2),Discount  decimal(18,2),DiscountApplicable bit)

declare @iDocID int
EXEC sp_xml_preparedocument @iDocID OUTPUT,@DiscountXml

insert into @TotalDiscount (DiscountType,IsPercentage,Value, Discount )
select  DiscountType,IsPercentage,Value, Discount 
FROM     OPENXML (@iDocID,'TotalDiscount',2)
with (DiscountType int,IsPercentage bit,Value decimal (18,2), Discount decimal (18,2))


insert into @ItemDiscountInformation 
select  StockItemHeaderId , Quantity , UnitPrice , LineTotal , DiscountType , IsPercentage , Value ,Discount ,DiscountApplicable 
FROM     OPENXML (@iDocID,'TotalDiscount/ItemDiscountInformation/ItemDiscountInformation',2)
with (StockItemHeaderId int, Quantity decimal(18,2), UnitPrice decimal(18,2), LineTotal decimal(18,2), DiscountType int, IsPercentage bit, Value  decimal(18,2),Discount  decimal(18,2),DiscountApplicable bit)

update @ItemDiscountInformation
set Discount = case IsPercentage when 0 then Value else LineTotal * Value /100 end 


declare @GrossTotal decimal(18,2)
select @GrossTotal = sum(LineTotal - Discount) 
from @ItemDiscountInformation


update @TotalDiscount  
set Discount = case IsPercentage when 0 then Value else @GrossTotal * Value /100 end 

select * from @TotalDiscount
select * from @ItemDiscountInformation
SELECT 1 PaymentTypeId,100 GrossTotal,1 DiscountType,0 IsPercentage,100 Value, 200 Discount 


		 COMMIT TRANSACTION 
    END TRY
   BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION 
   END CATCH
END

GO

