 --[dbo].[SP_GetPRFillData3] 30,1,6,5
 --go
 -- [dbo].[SP_GetPRFillData3] 1,1,5,33
CREATE PROCEDURE [dbo].[SP_GetPRFillData3] --1,1,2
	-- [dbo].[SP_GetPRFillData3] 1,1,2 Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT ,
    @Categoryid INT,
	@DeptId INT = -999

    WITH RECOMPILE
AS
    BEGIN
		IF @DeptId IS NULL SET @DeptId = -999

        DECLARE @Locationidnew INT= @Locationid ,
            @Propertyidnew INT= @Propertyid ,
            @Categoryidnew INT = @Categoryid,	
			@IsDeptWiseItem BIT,
			@CompanySeparator NVARCHAR(10),
			@ComCode NVARCHAR(50),
			@DeptCode NVARCHAR(150)

			SELECT @IsDeptWiseItem = IsDepartmentWiseItems, @CompanySeparator = CompanySeparator FROM Companies WHERE CompanyID = @Propertyid
			SELECT @ComCode = Code FROM  Companies WHERE CompanyID = @PropertyId
			SELECT @DeptCode = Code FROM Departments WHERE Id = @DeptId

		  	IF(@IsDeptWiseItem = 1 AND @DeptId <> -999)
			BEGIN
			IF(@CompanySeparator = 'JT')
				BEGIN
					SELECT  DISTINCT dbo.StockItemHeaders.Id ,
					dbo.StockItemHeaders.Name,
					StockItemHeaders.IsExpiryDateApplicable,QuantityInHand
                
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
							--INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
							INNER JOIN Categories C ON C.Id = dbo.StockItemHeaders.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = dbo.StockItemHeaders.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = dbo.StockItemHeaders.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] D ON D.Level2 = C.Code AND D.Level3 = SC.Code AND D.Level4 = SC2.Code
					WHERE   ( dbo.StockItemDetails.LocationID = @Locationidnew )
							AND ( dbo.StockItemDetails.PropertyID = @Propertyidnew )
							AND ( dbo.StockItemHeaders.CategoryID = @Categoryidnew ) AND dbo.StockItemDetails.IsActive=1
							--AND DI.DepartmentId =  CASE WHEN @DeptId = -999 THEN  DI.DepartmentId ELSE @DeptId END
							AND D.Level1 = @DeptCode AND D.GLCompCode = @ComCode  AND D.BlockCode = 'ISN'
					ORDER BY dbo.StockItemHeaders.Name
				END
			ELSE
				BEGIN
					SELECT  dbo.StockItemHeaders.Id ,
					dbo.StockItemHeaders.Name,
					StockItemHeaders.IsExpiryDateApplicable,QuantityInHand
                
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @Locationidnew )
							AND ( dbo.StockItemDetails.PropertyID = @Propertyidnew )
							AND ( dbo.StockItemHeaders.CategoryID = @Categoryidnew ) AND dbo.StockItemDetails.IsActive=1
							AND DI.DepartmentId =  CASE WHEN @DeptId = -999 THEN  DI.DepartmentId ELSE @DeptId END
					ORDER BY dbo.StockItemHeaders.Name
				END
				
			END

			ELSE
			BEGIN
				SELECT  dbo.StockItemHeaders.Id ,
				dbo.StockItemHeaders.Name,
				StockItemHeaders.IsExpiryDateApplicable,QuantityInHand
                
				FROM    dbo.StockItemDetails
						INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				WHERE   ( dbo.StockItemDetails.LocationID = @Locationidnew )
						AND ( dbo.StockItemDetails.PropertyID = @Propertyidnew )
						AND ( dbo.StockItemHeaders.CategoryID = @Categoryidnew ) AND dbo.StockItemDetails.IsActive=1
				ORDER BY dbo.StockItemHeaders.Name
			END

     
    END

GO

