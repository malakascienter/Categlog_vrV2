
-- SP_GetItemInforation '<ArrayOfQuotationItemDetais xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><QuotationItemDetais><ItemId>0</ItemId><UnitNme>KG</UnitNme><UnitId>0</UnitId><UnitPrice>200.75</UnitPrice><TaxGroup>0</TaxGroup><TaxGroupName>VAT10</TaxGroupName><ItemName>z item2</ItemName><ItemCode>Z001</ItemCode><PropertyId xsi:nil="true" /><PropertyList><GridSelect><id>53</id><text>Company 01</text><isMainStore xsi:nil="true" /><UnitId xsi:nil="true" /></GridSelect><GridSelect><id>1</id><text>Jetwing Hotels</text><isMainStore xsi:nil="true" /><UnitId xsi:nil="true" /></GridSelect></PropertyList></QuotationItemDetais></ArrayOfQuotationItemDetais>',4168
--go
CREATE PROCEDURE [dbo].[SP_GetItemInforation] ( @XMLDetails XML, @UserId INT)

AS
BEGIN
	BEGIN TRY 

		CREATE TABLE #TempAccess(
			FormId INT,
			ViewAccess BIT,
			InsertAccess BIT,
			UpdateAccess BIT,
			DeleteAccess BIT,
			PrintAccess BIT,
			OverrideDefault BIT
		)

 
	DECLARE @iDocID INT,@QuotationHeaderId INT ,@propertyID INT, @PropertyName VARCHAR(200),@ViewAccess BIT,@QuotationManageAttId INT 
	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

		INSERT INTO #TempAccess  EXEC  [dbo].[SP_S_GetFinalSecuritySet] @UserId 

		SELECT @ViewAccess = ViewAccess FROM #TempAccess WHERE FormID = 152

		SELECT * INTO #TempProperties
		FROM 
		OPENXML(@iDocID, '/ArrayOfQuotationItemDetais/QuotationItemDetais/PropertyList/GridSelect', 2)
		WITH(id INT,text VARCHAR(200))

 		SELECT *   INTO #TempQuotation 
        FROM
        OPENXML(@iDocID, '/ArrayOfQuotationItemDetais/QuotationItemDetais', 2)
		WITH (ItemId INT ,UnitNme VARCHAR( 250), UnitId INT , UnitPrice DECIMAL (18,6),	TaxGroup INT ,TaxGroupName VARCHAR( 250),
		ItemCode VARCHAR( 250),ItemName VARCHAR(150)) 

		SELECT DISTINCT t.*,P.ID PropertyID,C.Name As PropertyName into #TempQuotationDetails
		FROM  #TempQuotation T, #TempProperties P
		LEFT JOIN Companies C On C.CompanyID = P.Id

		 --select * from  #TempQuotationDetails

		UPDATE T
		SET T.UnitId = (SELECT ID FROM dbo.Units u WHERE u.Name= T.UnitNme)
		FROM #TempQuotationDetails T

		UPDATE T
		SET T.ItemId = (SELECT TOP(1) U.ID FROM dbo.StockItemHeaders u INNER JOIN STOCKITEMDETAILS D on D.stockitemid= u.id and D.PropertyID= t.PropertyID WHERE u.StockItemCode= T.ItemCode   )
		FROM #TempQuotationDetails T

		UPDATE T
		SET T.TaxGroup = (SELECT u.TaxGroupId FROM dbo.TaxGroups u WHERE u.Name= T.TaxGroupName)
		FROM #TempQuotationDetails T

		DECLARE @itemCode VARCHAR(50), @msg VARCHAR(500)

		--select * from  #TempQuotationDetails

		--SELECT ItemCode, COUNT(*)
		--FROM #TempQuotationDetails
		--GROUP BY ItemCode

		IF EXISTS(SELECT ItemCode, COUNT(*)
		FROM #TempQuotationDetails
		GROUP BY ItemCode, PropertyID
		HAVING COUNT(*) > 1)
		BEGIN
			SET @itemCode =NULL
			SELECT @itemCode =ItemCode
			FROM #TempQuotationDetails
			GROUP BY ItemCode,  PropertyID
			HAVING COUNT(*) > 1

			SET @msg='Duplicate ItemCode exists : ' + @itemCode
			RAISERROR (@msg,16,1)
			RETURN;
		END  

		--------------added---------------------------
		SELECT * INTO #TempCheckUnit FROM #TempQuotationDetails

		DECLARE @ItemId INT , @MasterUnitId INT , @LocationId INT , @UnitId INT 

		CREATE TABLE #UnitTable 
		(
		  UnitID INT ,
		  Unitname VARCHAR(200),
		  Value DECIMAL
		)


		WHILE (SELECT COUNT(*) FROM #TempCheckUnit) > 0
		BEGIN
			SET @itemCode =NULL
			SELECT TOP(1) @ItemId = ItemId,@UnitId = UnitId ,@itemCode = ItemCode, @propertyID= propertyID FROM #TempCheckUnit

			
				SELECT @QuotationManageAttId = QuotationManageByHOAttributeId  FROM CommonSettings 

				---------check access-------------------------------
				IF(@ViewAccess = 0)
				BEGIN
					IF EXISTS(SELECT 1 FROM StockItemWiseAttributes WHERE StockItemHeaderID = @ItemId AND StockItemAttributeID = @QuotationManageAttId 
					AND IsActive = 1)
					BEGIN
						SET @msg='This user has not access for upload '+@itemCode +' item  '
						RAISERROR (@msg,16,1)
						RETURN;
					END

				END
				---------check access-------------------------------
		
			----------added-------------------------------------
			

				SELECT  TOP(1) @PropertyName = text FROM #TempProperties where id= @propertyID

				--IF NOT EXISTS( SELECT 1 FROM StockItemHeaders WHERE Id = @ItemId AND CompanyId = @propertyID)
				IF NOT EXISTS( SELECT 1 FROM StockItemHeaders WHERE StockItemCode = @itemCode AND CompanyId = @propertyID)
				BEGIN
					SET @msg=@itemCode +'Item not exists in '+ @PropertyName
					RAISERROR (@msg,16,1)
					RETURN;
				END  

				SELECT @MasterUnitId = MasterUnitID 
				FROM dbo.StockItemDetails SI
				inner join  locations L on L.Id = SI.LocationID
				WHERE  SI.CompanyID = @propertyID and SI.StockItemHeaderID = @ItemId and L.DefaultLocation = 1

				INSERT INTO #UnitTable
				EXEC [dbo].[SP_GetUnitCoversion] @MasterUnitId


				IF NOT EXISTS(SELECT 1 FROM #UnitTable WHERE UnitID = @UnitId)
					BEGIN
						SET @msg='Invalid Unit for Item in '+ @PropertyName+' :' + @itemCode
						RAISERROR (@msg,16,1)
						RETURN;
					END  

				TRUNCATE TABLE #UnitTable
				
			
			----------added-------------------------------------



			DELETE TOP(1) FROM #TempCheckUnit
        END
        
		--------------added---------------------------

		SELECT * FROM #TempQuotationDetails

		SELECT DISTINCT UnitNme,UnitId,UnitPrice,TaxGroup,TaxGroupName,ItemCode,ItemName FROM #TempQuotationDetails

		SET @itemCode =NULL


		SELECT TOP 1 @itemCode = ItemCode 
		FROM #TempQuotationDetails
		WHERE ItemId IS NULL OR ItemId= 0

		IF (@itemCode IS NOT NULL)
		BEGIN
			SET @msg='Invalid Item Code:' + @itemCode
			RAISERROR (@msg,16,1)
			RETURN;
		END  

		SET @itemCode =NULL
		SELECT TOP 1 @itemCode = ItemCode 
		FROM #TempQuotationDetails
		WHERE TaxGroup IS NULL OR TaxGroup = 0

		select '000000000000000000'
		select * from #TempQuotationDetails

		IF (@itemCode IS NOT NULL)
		BEGIN
			SET @msg='Invalid Tax Group Name For Item :' + @itemCode
			RAISERROR (@msg,16,1)
			RETURN;
		END  

		SET @itemCode =NULL
		SELECT TOP 1 @itemCode = ItemCode 
		FROM #TempQuotationDetails
		WHERE UnitId IS NULL OR UnitId= 0

		IF (@itemCode IS NOT NULL)
		BEGIN
			SET @msg='Invalid Unit Name For Item :' + @itemCode
			RAISERROR (@msg,16,1)
			RETURN;
		END  
 
		
	
 
	END TRY

	BEGIN CATCH 

		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH

END

GO

