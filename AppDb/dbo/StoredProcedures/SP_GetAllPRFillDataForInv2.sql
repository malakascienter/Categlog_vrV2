--  [dbo].[SP_GetAllPRFillDataForInv2] 1,1

CREATE PROCEDURE [dbo].[SP_GetAllPRFillDataForInv2] --1,1,2
	-- [dbo].[SP_GetAllPRFillDataForInv2] 1,1 Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT,
	@UserId INT = -999
    WITH RECOMPILE
AS
    BEGIN
	IF @UserId IS NULL
		SET @UserId = -999

        DECLARE @Locationid2 INT= @Locationid ,
            @Propertyid2 INT= @Propertyid,
			@ViewAccess BIT,
			@QuotationManageAttId INT ,@CurrentDate DATE = GETDATE()

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
		-- print 545
		
		

		
		--COMMENTED BY iSURU 2025-08-22 TO FIX  item looading issue with table valued function
		 --   SELECT DISTINCT dbo.StockItemHeaders.Id ,
   --             dbo.StockItemHeaders.StockItemCode + '/'
			--		+ dbo.StockItemHeaders.Name AS Name,
			--		CASE WHEN @Locationid2 = -999 THEN 0 ELSE ROUND(dbo.StockItemDetails.AveragePrice,2) END AS  AveragePrice,
			--		CASE WHEN @Locationid2 = -999 THEN 0 ELSE [dbo].[GetBalance](@CurrentDate,dbo.StockItemHeaders.Id, dbo.StockItemDetails.LocationID,0, 0) END AS QuantityInHand
			--FROM    dbo.StockItemDetails
			--		inner JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
			--WHERE   ( dbo.StockItemDetails.LocationID =   CASE WHEN  @Locationid2 = -999  THEN  dbo.StockItemDetails.LocationID ELSE @Locationid2 END )
			--		AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 )
			--		AND dbo.StockItemDetails.IsActive = 1
			--ORDER BY Name

			 SELECT DISTINCT dbo.StockItemHeaders.Id ,
                ISNULL(dbo.StockItemHeaders.StockItemCode,'') + '/'+ ISNULL(dbo.StockItemHeaders.Name,'') AS Name,
					CASE WHEN @Locationid2 = -999 THEN 0 ELSE ROUND(dbo.StockItemDetails.AveragePrice,2) END AS  AveragePrice,
					--CASE WHEN @Locationid2 = -999 THEN 0 ELSE ISNULL(Balance.BalanceQty,0) END AS QuantityInHand --commented by Isuru 2026-05-11 to fix timeout issue to fix item loading
					CASE WHEN @Locationid2 = -999 THEN 0 ELSE ISNULL(dbo.StockItemDetails.QuantityInHand,0) END AS QuantityInHand
			FROM    dbo.StockItemDetails WITH (NOLOCK)
					inner JOIN dbo.StockItemHeaders WITH (NOLOCK) ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				--	OUTER APPLY dbo.GetBalanceTVF(@CurrentDate, dbo.StockItemHeaders.Id,CASE WHEN @Locationid2 = -999 THEN dbo.StockItemDetails.LocationID ELSE @Locationid2 END, 0, 0) AS Balance
			WHERE   ( dbo.StockItemDetails.LocationID =   CASE WHEN  @Locationid2 = -999  THEN  dbo.StockItemDetails.LocationID ELSE @Locationid2 END )
					AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 )
					AND dbo.StockItemDetails.IsActive = 1
			ORDER BY Name
		END
		IF( @ViewAccess = 0)
		BEGIN
		select 12
			SELECT DISTINCT dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.StockItemCode + '/'
					+ dbo.StockItemHeaders.Name AS Name,
					ROUND(dbo.StockItemDetails.AveragePrice,2)  AveragePrice,
					[dbo].[GetBalance](@CurrentDate,dbo.StockItemHeaders.Id, dbo.StockItemDetails.LocationID,0, 0) AS QuantityInHand
			FROM    dbo.StockItemDetails
					inner JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
			WHERE   ( dbo.StockItemDetails.LocationID =   CASE WHEN  @Locationid2 = -999  THEN  dbo.StockItemDetails.LocationID ELSE @Locationid2 END )
					AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 )
					AND dbo.StockItemDetails.IsActive = 1
			
			EXCEPT 

			SELECT DISTINCT dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.StockItemCode + '/'
					+ dbo.StockItemHeaders.Name AS Name,
					ROUND(dbo.StockItemDetails.AveragePrice,2)  AveragePrice,
					[dbo].[GetBalance](@CurrentDate,dbo.StockItemHeaders.Id, dbo.StockItemDetails.LocationID,0, 0) AS QuantityInHand
			FROM    dbo.StockItemDetails
					INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
					LEFT JOIN StockItemWiseAttributes SIT ON SIT.StockItemHeaderID = dbo.StockItemHeaders.Id
			WHERE   ( dbo.StockItemDetails.LocationID =   CASE WHEN  @Locationid2 = -999  THEN  dbo.StockItemDetails.LocationID ELSE @Locationid2 END )
					AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 )
					AND dbo.StockItemDetails.IsActive = 1  AND SIT.StockItemAttributeID = @QuotationManageAttId AND SIT.IsActive = 1
			ORDER BY Name
		END

    


		-- SELECT Id,  dbo.StockItemHeaders.StockItemCode+'/'+dbo.StockItemHeaders.Name AS Name FROM dbo.StockItemHeaders 
    END

GO

