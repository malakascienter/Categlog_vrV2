 --[dbo].[SP_GetPRFillDataForInv2] 1,1,1
 --go
CREATE PROCEDURE [dbo].[SP_GetPRFillDataForInv2] --1,1,2
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT ,
    @Categoryid INT,
	@UserId INT = -999

    WITH RECOMPILE
AS
    BEGIN
	IF @UserId IS NULL
		SET @UserId = -999

        DECLARE @Locationid2 INT= @Locationid ,
            @Propertyid2 INT= @Propertyid ,
            @Categoryid2 INT = @Categoryid,
			@ViewAccess BIT,
			@QuotationManageAttId INT

		SELECT @QuotationManageAttId = QuotationManageByHOAttributeId  FROM CommonSettings 

		CREATE TABLE #TempAccess(
			FormId INT,
			ViewAccess BIT,
			InsertAccess BIT,
			UpdateAccess BIT,
			DeleteAccess BIT,
			PrintAccess BIT,
			OverrideDefault BIT
		)
	   IF(@UserId <> -999)
		INSERT INTO #TempAccess  EXEC  [dbo].[SP_S_GetFinalSecuritySet] @UserId 

	   SELECT @ViewAccess = ViewAccess FROM #TempAccess WHERE FormID = 152

      	IF(@UserId = -999 OR @ViewAccess = 1 )
		BEGIN
		
			SELECT DISTINCT dbo.StockItemHeaders.Id ,
				 dbo.StockItemHeaders.StockItemCode+'/'+dbo.StockItemHeaders.Name AS Name,
				 ROUND(dbo.StockItemDetails.AveragePrice,2)  AveragePrice
                
			FROM    dbo.StockItemDetails
					INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
			--WHERE   ( dbo.StockItemDetails.LocationID = CASE WHEN  @Locationid2 = -999 THEN dbo.StockItemDetails.LocationID  ELSE  @Locationid2  END) -- Commented by Isuru 2026-05-11 to fix duplicate locationwise item loading
			WHERE   ( dbo.StockItemDetails.LocationID = CASE WHEN  @Locationid2 = -999 THEN (SELECT TOP (1) ID FROM Locations WHERE PropertyId = @Propertyid AND IsMainStore = 1) ELSE  @Locationid2  END)	
				AND ( dbo.StockItemDetails.PropertyID = CASE WHEN @Propertyid2 = -999 THEN dbo.StockItemDetails.PropertyID ELSE @Propertyid2 END )
					AND ( dbo.StockItemHeaders.CategoryID = CASE WHEN @Categoryid2 = -999 THEN  dbo.StockItemHeaders.CategoryID ELSE @Categoryid2 END) AND dbo.StockItemDetails.IsActive=1

			ORDER BY Name
		END
		IF( @ViewAccess = 0)
		BEGIN
		
			SELECT DISTINCT dbo.StockItemHeaders.Id ,
			dbo.StockItemHeaders.StockItemCode+'/'+dbo.StockItemHeaders.Name AS Name,
			 ROUND(dbo.StockItemDetails.AveragePrice,2)  AveragePrice
			FROM    dbo.StockItemDetails
					INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
			WHERE   ( dbo.StockItemDetails.LocationID = CASE WHEN  @Locationid2 = -999 THEN dbo.StockItemDetails.LocationID  ELSE  @Locationid2  END)
					AND ( dbo.StockItemDetails.PropertyID = CASE WHEN @Propertyid2 = -999 THEN dbo.StockItemDetails.PropertyID ELSE @Propertyid2 END )
					AND ( dbo.StockItemHeaders.CategoryID = CASE WHEN @Categoryid2 = -999 THEN  dbo.StockItemHeaders.CategoryID ELSE @Categoryid2 END) 
					AND dbo.StockItemDetails.IsActive=1 
			EXCEPT
			SELECT DISTINCT dbo.StockItemHeaders.Id ,
			dbo.StockItemHeaders.StockItemCode+'/'+dbo.StockItemHeaders.Name AS Name,
			 ROUND(dbo.StockItemDetails.AveragePrice,2)  AveragePrice
			FROM    dbo.StockItemDetails
					INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
					LEFT JOIN StockItemWiseAttributes SIT ON SIT.StockItemHeaderID = dbo.StockItemHeaders.Id
			WHERE   ( dbo.StockItemDetails.LocationID = CASE WHEN  @Locationid2 = -999 THEN dbo.StockItemDetails.LocationID  ELSE  @Locationid2  END)
					AND ( dbo.StockItemDetails.PropertyID = CASE WHEN @Propertyid2 = -999 THEN dbo.StockItemDetails.PropertyID ELSE @Propertyid2 END )
					AND ( dbo.StockItemHeaders.CategoryID = CASE WHEN @Categoryid2 = -999 THEN  dbo.StockItemHeaders.CategoryID ELSE @Categoryid2 END) 
					AND dbo.StockItemDetails.IsActive=1 AND SIT.StockItemAttributeID = @QuotationManageAttId AND SIT.IsActive = 1
			ORDER BY Name

		END
		  

    END

GO

