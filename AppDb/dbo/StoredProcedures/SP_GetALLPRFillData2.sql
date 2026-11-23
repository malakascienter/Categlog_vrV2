--  [dbo].[SP_GetALLPRFillData2]  1,1,2
CREATE PROCEDURE [dbo].[SP_GetALLPRFillData2] 
	-- [dbo].[SP_GetALLPRFillData2] 1,1 Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT,
	@DeptId INT = -999
    WITH RECOMPILE
AS
    BEGIN
		IF @DeptId IS NULL SET @DeptId = -999
			
        DECLARE @Locationid2 INT= @Locationid ,
            @Propertyid2 INT = @Propertyid,
			@IsDeptWiseItem BIT,
			@CompanySeparator NVARCHAR(10),
			@ComCode NVARCHAR(50),
			@DeptCode NVARCHAR(150)

			SELECT @IsDeptWiseItem = IsDepartmentWiseItems, @CompanySeparator = CompanySeparator FROM Companies WHERE CompanyID = @Propertyid
			SELECT @ComCode = Code FROM  Companies WHERE CompanyID = @PropertyId
			SELECT @DeptCode = Code FROM Departments WHERE Id = @DeptId

			--select @DeptCode,@ComCode

			IF(@IsDeptWiseItem = 1 AND @DeptId <> -999)
			BEGIN

			
				IF(@CompanySeparator = 'JT')
				BEGIN	
					SELECT DISTINCT
					dbo.StockItemHeaders.Id ,
					dbo.StockItemHeaders.StockItemCode+ '/'+
					dbo.StockItemHeaders.Name as Name,StockItemHeaders.IsExpiryDateApplicable,QuantityInHand,
					dbo.StockItemDetails.AveragePrice UnitPrice
					--c.name as category, C.Code catCode,SC.Code subCatCode, @DeptCode depCode
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
							INNER JOIN Categories C ON C.Id = dbo.StockItemHeaders.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = dbo.StockItemHeaders.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = dbo.StockItemHeaders.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
							--INNER JOIN Departmentwiseitems D ON D.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @Locationid2 )
							AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.Level1 = @DeptCode AND DI.GLCompCode = @ComCode AND DI.BlockCode = 'ISN'
							

					ORDER BY Name
				END					
				ELSE
				BEGIN
					SELECT DISTINCT
					dbo.StockItemHeaders.Id ,
					dbo.StockItemHeaders.StockItemCode+ '/'+
					dbo.StockItemHeaders.Name as Name,StockItemHeaders.IsExpiryDateApplicable,QuantityInHand,
					dbo.StockItemDetails.AveragePrice UnitPrice

					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @Locationid2 )
							AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.DepartmentId =  CASE WHEN @DeptId = -999 THEN  DI.DepartmentId ELSE @DeptId END

					ORDER BY Name
				END

				
			END
			ELSE
			BEGIN
			    SELECT 
                dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.StockItemCode+ '/'+
                dbo.StockItemHeaders.Name as Name,StockItemHeaders.IsExpiryDateApplicable,QuantityInHand

				FROM    dbo.StockItemDetails
						INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				WHERE   ( dbo.StockItemDetails.LocationID = @Locationid2 )
						AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 ) AND (dbo.StockItemDetails.IsActive = 1)

				ORDER BY Name
			END


    END

GO

