
CREATE procedure [dbo].[SP_Save_CopyStockItem]( @XMLDetails XML ='<CopyStockItem xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><FromLocationId>0</FromLocationId><ByCategory>true</ByCategory><FromCategoryId>1</FromCategoryId><ToCategoryId>2</ToCategoryId><ByItem>false</ByItem><FromItemId>0</FromItemId><ToItemId>0</ToItemId><UserId>2</UserId><ToLocationList><ToLocation><id>22</id></ToLocation><ToLocation><id>1</id></ToLocation></ToLocationList></CopyStockItem>')
as 
BEGIN
DECLARE @iDocID INT

DECLARE @FromLocationID INT,@ByCategory BIT, @FromCategoryId INT, @ToCategoryId INT, @ByItem BIT, @FromItemId INT, @ToItemId INT,
 @BySubCat2 BIT,@FromSubCat2 INT,@ToSubCat2 INT,@ToLocation INT, @userId INT

--insert into XMLDATALOG (XMLDATA) values (convert(varchar(max),@XMLDetails))

--Create table #LocationList
--(ToLocationID INT)
	BEGIN TRY 
		BEGIN TRANSACTION 
EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails




SELECT @FromLocationID =FromLocationID,@ByCategory =ByCategory, @FromCategoryId =FromCategoryId, @ToCategoryId =ToCategoryId, 
	   @ByItem =ByItem , @FromItemId =FromItemId,@ToItemId =ToItemId ,@BySubCat2=BySubCategory2,@FromSubCat2 = FromSubCategory2Id,
	   @ToSubCat2 =ToSubCategory2Id, @userId =userId
FROM     OPENXML (@iDocID,'/CopyStockItem',2)
WITH    (FromLocationId INT,ByCategory bit, FromCategoryId INT, ToCategoryId int, ByItem bit, FromItemId INT, ToItemId INT,
         BySubCategory2 BIT, FromSubCategory2Id INT, ToSubCategory2Id INT, UserId int)

SELECT   *
INTO #LocationList
FROM     OPENXML (@iDocID,'/CopyStockItem/ToLocationList/ToLocation',2)
WITH    ( id int)


-- TO PREVENT IN INSERTION OF USER ID = 0 
	IF(@userId = 0)
		BEGIN

			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END



INSERT INTO StockItemDetails
(
	   [PropertyID]
      ,[CompanyID]
      ,[LocationID]
      ,[StockItemHeaderID]
      ,[MasterUnitID]
      ,[PurchasingUnitID]
      ,[MinimumQuantity]
      ,[MaximumQuantity]
      ,[ReOrderLevel]
      ,[ReOrderQuantity]
      ,[ReOrderPeriod]
      ,[PurchaseAccountID]
      ,[CostOfSalesAccountID]
      ,[AveragePrice]
      ,[SellingPrice]
      ,[WholesalePrice]
      ,[IsActive]
      ,[ReportingUnitID]
      ,[QuantityInHand]
      ,[StockItemId]
      ,[IPAddress]
      ,[CreatedUserID]
      ,[LastModUserID]
      ,[CreatedDate]
      ,[LastModDate]
      ,[BatchNo]
      ,[ProfitMargin]
)
SELECT * FROM (
SELECT D.[PropertyID]
      ,D.[CompanyID]
      ,L.id
      ,D.[StockItemHeaderID]
      ,D.[MasterUnitID]
      ,D.[PurchasingUnitID]
      ,D.[MinimumQuantity]
      ,D.[MaximumQuantity]
      ,D.[ReOrderLevel]
      ,D.[ReOrderQuantity]
      ,D.[ReOrderPeriod]
      ,D.[PurchaseAccountID]
      ,D.[CostOfSalesAccountID]
      ,D.[AveragePrice]
      ,D.[SellingPrice]
      ,D.[WholesalePrice]
      ,D.[IsActive]
      ,D.[ReportingUnitID]
      ,0 AS  [QuantityInHand]
      ,D.[StockItemId]
      ,D.[IPAddress]
      --,51110 AS CreatedUserID--
	  ,D.[CreatedUserID]
      ,D.[LastModUserID]
      ,D.[CreatedDate]
      ,D.[LastModDate]
      ,D.[BatchNo]
      ,D.[ProfitMargin]
	  
FROM dbo.StockItemHeaders H
INNER JOIN dbo.StockItemDetails D ON H.id=D.StockItemHeaderID
cross JOIN #LocationList L
WHERE D.LocationID=@FromLocationID
AND
(
H.CategoryID >= CASE WHEN @ByCategory = 1 THEN @FromCategoryId ELSE H.CategoryID END  
AND 
H.CategoryID <= CASE WHEN @ByCategory = 1 THEN @ToCategoryId ELSE H.CategoryID END  
)
AND
(
H.id >= CASE WHEN @ByItem = 1 THEN @FromItemId ELSE H.id END  
AND 
H.id <= CASE WHEN @ByItem = 1 THEN @ToItemId ELSE H.id END  
)
AND
(
H.SubCategory2ID >= CASE WHEN @BySubCat2 = 1 THEN @FromSubCat2 ELSE H.SubCategory2ID END  
AND 
H.SubCategory2ID <= CASE WHEN @BySubCat2 = 1 THEN @ToSubCat2 ELSE H.SubCategory2ID END  
)
) X WHERE StockItemHeaderID NOT IN (SELECT StockItemHeaderID FROM StockItemDetails WHERE LocationID= X.Id AND StockItemHeaderID=x.StockItemHeaderID )

 COMMIT TRANSACTION

END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION
        	DECLARE @Message NVARCHAR(100)
		SET @Message = N'Error Occured: ' + ERROR_MESSAGE() 
        PRINT ERROR_MESSAGE()
		RAISERROR(@Message,16,1)
    END CATCH
END

GO

