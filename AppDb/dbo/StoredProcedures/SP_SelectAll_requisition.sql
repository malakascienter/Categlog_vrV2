/**
 exec [dbo].[SP_SelectAll_requisition] 13,'RT',2,'s',-999

 exec [dbo].[SP_SelectAll_requisition] 1,'RT',5150,'s',7


**/

--go
CREATE Procedure [dbo].[SP_SelectAll_requisition]
(

@LocationID int,
@RequestType char(2),
@RequestHeaderID int,
@Operation char(1),
@ToLocation INT = -999
)
as


DECLARE @propertyID INT 
DECLARE @DecimalPlace int,@IsCUSDECSelection BIT

SELECT @propertyID = CompanyID FROM Locations 
WHERE Id= @LocationID

SELECT @DecimalPlace = DecimalPlaces,@IsCUSDECSelection = ISNULL(IsCUSDECSelection,0)
FROM Companies
WHERE CompanyID = @propertyId

BEGIN
    BEGIN TRY 
	BEGIN TRANSACTION

if	(@Operation='A')
 BEGIN
	SELECT        RequestHeaders.Id
				, RequestDetails.Id
				, StockItemHeaders.StockItemCode
				, StockItemHeaders.Name AS ItemName
				, Units.Code AS UnitCode
				, RequestDetails.UnitPrice
				, RequestHeaders.DocumentNo
				, RequestDetails.RequestedQuantity
				,[dbo].[FN_GetStockInHand_Reatils](StockItemHeaders.CompanyId,StockItemDetails.LocationID,StockItemHeaders.Id) AS QuantityInHand
				--, StockItemDetails.QuantityInHand
				, RequestHeaders.RequestDate
				, RequestDetails.Remarks
				, RequestHeaders.DocumentStatus
				, StockItemHeaders.Id
				, Units.Id
				, RequestDetails.ApprovedQuantity
				--, StockItemDetails.QuantityInHand
				, StockItemHeaders.IsExpiryDateApplicable
				,StockItemHeaders.BrandedItem
				,dbo.StockItemHeaders.GenericItemCode AS GenericCode
	FROM          RequestHeaders INNER JOIN RequestDetails    ON RequestHeaders.Id = RequestDetails.RequestHeaderID 
							        INNER JOIN Units      ON RequestDetails.UnitID = Units.Id
							        INNER JOIN StockItemDetails ON RequestHeaders.LocationID = StockItemDetails.LocationID 
																	AND RequestDetails.StockItemID = StockItemDetails.Id
							        INNER JOIN StockItemHeaders  ON StockItemDetails.StockItemID = StockItemHeaders.Id
	WHERE        (RequestHeaders.LocationID = @LocationID) AND (RequestHeaders.RequestType = @RequestType) AND (RequestHeaders.IsApproved = 1) AND 
				 (RequestHeaders.Id= @RequestHeaderID) AND 
		       --(INV_RequestHeader.RequestHeaderID = @RequestHeaderID) AND (INV_RequestHeader.RequestDate = @RequestDate) AND 
				 (RequestHeaders.DocumentStatus = 'P')
 END
 --SELECT * FROM StockItemDetails


 if	(@Operation='R')
 begin
/*I(NV_RequestHeader.RequestDate = @RequestDate) AND (INV_RequestHeader.DocumentStatus = 'P')*/

SELECT DISTINCT RequestHeaders.Id, RequestHeaders.DocumentNo
FROM            RequestHeaders INNER JOIN
                         RequestDetails ON RequestHeaders.Id = RequestDetails.RequestHeaderID
WHERE        (RequestHeaders.LocationID = @LocationID) 
AND			(RequestHeaders.RequestType = @RequestType) 
AND			(RequestHeaders.IsApproved = 1)  
AND (RequestHeaders.DocumentStatus = 'P')
AND (RequestDetails.ApprovedQuantity - RequestDetails.IssuedQuantity ) > 0

end

if	(@Operation='P') -- concider pick note qtys
BEGIN
	SELECT RequestHeaderId, RequestDetailId, StockItemCode, ItemName, UnitCode, UnitPrice, DocumentNo, RequestedQuantity, QuantityInHand,
			RequestDate, Remarks, DocumentStatus, StockItemHeaderId, UnitId, ApprovedQuantity,/*IssuedQuantity,*/ IsExpiryDateApplicable--, (PickNoteQty - IssuedQuantity) AS PickNoteQty
	FROM (
	SELECT        RequestHeaders.Id AS RequestHeaderId
				, RequestDetails.Id AS RequestDetailId
				, StockItemHeaders.StockItemCode
				, StockItemHeaders.Name AS ItemName
				, Units.Code AS UnitCode
				, RequestDetails.UnitPrice
				, RequestHeaders.DocumentNo
				, RequestDetails.RequestedQuantity
				,[dbo].[FN_GetStockInHand_Reatils](StockItemHeaders.CompanyId,StockItemDetails.LocationID,StockItemHeaders.Id) AS QuantityInHand
				--, StockItemDetails.QuantityInHand
				, RequestHeaders.RequestDate
				, RequestDetails.Remarks
				, RequestHeaders.DocumentStatus
				, StockItemHeaders.Id AS StockItemHeaderId
				, Units.Id AS UnitId
				, RequestDetails.ApprovedQuantity
			--, CASE WHEN (SELECT ReferenceID from INV_PickNoteHeader WHERE ReferenceID   = RequestHeaders.Id) IS NULL THEN 
			--	  0
			--	  ELSE
			--	  (SELECT Quantity from INV_PickNoteDetail WHERE PickNoteHeaderID  in (select PickNoteID from INV_PickNoteHeader where ReferenceID = @RequestHeaderID and DocumentStatus ='P')) END AS IssuedQuantity
				--, INV_StockItemDetails.QuantityInHand
				, StockItemHeaders.IsExpiryDateApplicable
				--, isnull(dbo.INV_GetPickNotePendingQuanities(@LocationID,INV_RequestDetail.StockItemID),0) as PickNoteQty
	FROM          RequestHeaders INNER JOIN RequestDetails    ON RequestHeaders.Id = RequestDetails.RequestHeaderID 
							        INNER JOIN Units      ON RequestDetails.UnitID = Units.Id
							        INNER JOIN StockItemDetails ON RequestHeaders.LocationID = StockItemDetails.LocationID 
																	AND RequestDetails.StockItemID = StockItemDetails.StockItemID 
							        INNER JOIN StockItemHeaders  ON StockItemDetails.StockItemID = StockItemHeaders.Id
	WHERE        (RequestHeaders.LocationID = @LocationID) AND (RequestHeaders.RequestType = @RequestType) AND (RequestHeaders.IsApproved = 1) AND 
				 (RequestHeaders.Id = @RequestHeaderID) AND 
		       --(INV_RequestHeader.RequestHeaderID = @RequestHeaderID) AND (INV_RequestHeader.RequestDate = @RequestDate) AND 
				 (RequestHeaders.DocumentStatus = 'P')
	) AS d

 END
 --SELECT * FROM StockItemHeaders
 -- select request items for Pick Note

 if	(@Operation='Q')
 begin
/*I(NV_RequestHeader.RequestDate = @RequestDate) AND (INV_RequestHeader.DocumentStatus = 'P')*/

SELECT DISTINCT RequestHeaders.Id, RequestHeaders.DocumentNo 
---	case when (select ReferenceID from INV_PickNoteHeader where ReferenceID = RequestHeaders.Id) is null then '' else ' - Picked' end as DocumentNo
FROM            RequestHeaders INNER JOIN
                         RequestDetails ON RequestHeaders.Id= RequestDetails.RequestHeaderID
WHERE        (RequestHeaders.LocationID = @LocationID) 
AND			(RequestHeaders.RequestType = @RequestType) 
AND			(RequestHeaders.IsApproved = 1)  
AND (RequestHeaders.DocumentStatus = 'P')
AND (RequestDetails.ApprovedQuantity - RequestDetails.IssuedQuantity ) > 0

end

if	(@Operation='T') -- show only Pick note prepaird requests
 begin
/*I(NV_RequestHeader.RequestDate = @RequestDate) AND (INV_RequestHeader.DocumentStatus = 'P')*/

SELECT DISTINCT RequestHeaders.Id, RequestHeaders.DocumentNo,RequestHeaders.RequestDate
FROM         RequestHeaders INNER JOIN RequestDetails ON RequestHeaders.Id= RequestDetails.RequestHeaderID
WHERE      (RequestHeaders.LocationID = @LocationID) 
AND		  (RequestHeaders.TransferLocation = CASE WHEN @ToLocation = -999 THEN RequestHeaders.TransferLocation ELSE @ToLocation END)
AND		  (RequestHeaders.RequestType = @RequestType) 
AND		   (RequestHeaders.IsApproved = 1)  
AND (RequestHeaders.DocumentStatus = 'P' )
AND (RequestDetails.ApprovedQuantity - RequestDetails.IssuedQuantity ) >= 0
ORDER BY RequestHeaders.RequestDate DESC 

end
--SELECT * FROM RequestHeaders
if	(@Operation='S') -- concider pick note qtys to Transfer Note In
BEGIN
	
	
	DECLARE @TransferLocation INT,@IsBrandItem BIT
	SELECT @TransferLocation =TransferLocation
	FROM RequestHeaders
	WHERE ID=@RequestHeaderID

	--Checking transfering between outlet to outlet
	IF EXISTS ( SELECT COUNT(DISTINCT StockLocationID)   FROM Location_Ref   WHERE StockLocationID IN (@LocationID, @TransferLocation) 
		HAVING COUNT(DISTINCT StockLocationID) >= 2
	)
	BEGIN
		SET @IsBrandItem = 0

	END
	ELSE
	BEGIN
		SET @IsBrandItem = 1
	END

	--end

	SELECT  RequestHeaderId , RequestDetailsId , StockItemCode, ItemName, UnitCode, UnitPrice, DocumentNo, RequestedQuantity,ROUND(QuantityInHand,@DecimalPlace) AS QuantityInHand,
			RequestDate, Remarks, DocumentStatus,StockItemDetailsID, StockItemHeaderId , UnitId , ApprovedQuantity,BrandedItem,GenericCode,IsBranded
			,IsExpiryDateApplicable
			/*, IssuedQuantity, IsExpiryDateApplicable*/---,(PickNoteQty - IssuedQuantity) AS PickNoteQty
			INTO #TempAllData
	FROM (
	SELECT       RequestHeaders.Id AS RequestHeaderId
				, StockItemDetails.Id AS StockItemDetailsID
				, RequestDetails.Id AS RequestDetailsId
				, StockItemHeaders.StockItemCode
				, StockItemHeaders.Name AS ItemName
				, Units.Name AS UnitCode
				, StockItemDetails.AveragePrice UnitPrice
				, RequestHeaders.DocumentNo
				, RequestDetails.RequestedQuantity
				,[dbo].[FN_GetStockInHand_Reatils](StockItemHeaders.CompanyId,StockItemDetails.LocationID,StockItemHeaders.Id) 
				* dbo.FN_GetUnitConvertionRate(@propertyID,StockItemDetails.MasterUnitID,RequestDetails.UnitID)  AS QuantityInHand
				--, StockItemDetails.QuantityInHand
				, RequestHeaders.RequestDate
				, RequestDetails.Remarks
				, RequestHeaders.DocumentStatus
				, StockItemHeaders.Id AS StockItemHeaderId
				, Units.Id AS UnitId
				, StockItemHeaders.BrandedItem 
				--, StockItemHeaders.GenericItemCode AS GenericCode -- COMMENTED BY ISURU 2023-08-14
				--ADDED BY ISURU 2023-08-14 FOR GENERIC ITEM
				,(select SH.StockItemCode 
				from RequestHeaders RH
				INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
				 INNER JOIN StockItemHeaders SH ON SH.Id = RD.StockItemID
				WHERE SH.StockItemCode in (select GenericItemCode from StockItemHeaders)
				AND RH.Id = @RequestHeaderID AND SH.StockItemCode=StockItemHeaders.StockItemCode) AS GenericCode
				--END
				,(RequestDetails.ApprovedQuantity - RequestDetails.IssuedQuantity) AS ApprovedQuantity
				--,0 AS IsBranded -- COMMENTED BY ISURU 2023-08-04

				--ADDED BY ISURU 2023-08-14 FOR GENERIC ITEM 
				,(select 1 
				from RequestHeaders RH
				INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
				 INNER JOIN StockItemHeaders SH ON SH.Id = RD.StockItemID
				WHERE SH.StockItemCode in (select GenericItemCode from StockItemHeaders)
				AND RH.Id = @RequestHeaderID AND SH.StockItemCode=StockItemHeaders.StockItemCode) AS IsBranded
				, StockItemHeaders.IsExpiryDateApplicable
				-- END
				FROM		RequestHeaders INNER JOIN RequestDetails    ON RequestHeaders.Id= RequestDetails.RequestHeaderID 
				INNER JOIN Units      ON RequestDetails.UnitID = Units.Id
				INNER JOIN StockItemDetails ON RequestHeaders.LocationID = StockItemDetails.LocationID 
												AND RequestDetails.StockItemID = StockItemDetails.StockItemID 
				INNER JOIN StockItemHeaders  ON StockItemDetails.StockItemID = StockItemHeaders.Id
	WHERE        (RequestHeaders.LocationID = @LocationID) AND (RequestHeaders.RequestType = @RequestType) AND (RequestHeaders.IsApproved = 1) AND 
				 (RequestHeaders.Id = @RequestHeaderID) AND 
				 (RequestDetails.ApprovedQuantity - RequestDetails.IssuedQuantity) <> 0 AND
		       --(INV_RequestHeader.RequestHeaderID = @RequestHeaderID) AND (INV_RequestHeader.RequestDate = @RequestDate) AND 
				 (RequestHeaders.DocumentStatus = 'P')
	) AS d

	--select *
	--from #TempAllData

		DECLARE @StockItemId INT, @Quantity DECIMAL, @Branded BIT, @GenericCode VARCHAR(500), @ItemName VARCHAR(500),@NotInError VARCHAR(500),
		@ToLocationId INT, @StockItemCode VARCHAR(500)
		
		select RD.*, SH.Name AS ItemName, SH.StockItemCode into #tempReqDetails 
		from RequestDetails RD
		inner join StockItemHeaders SH
		on SH.Id = RD.StockItemID
		where RD.RequestHeaderID = @RequestHeaderID

	

		SELECT Tt.* INTO #TempNot
		FROM #tempReqDetails Tt
		WHERE Tt.StockItemID NOT IN (	SELECT SID.StockItemHeaderID 
											FROM StockItemDetails  SID 
											WHERE SID.LocationID = @LocationID 
											and SID.StockItemId = Tt.StockItemID )

		--SELECT * FROM #TempNot

		if((SELECT COUNT(*) FROM #TempAllData) = 0 AND (SELECT COUNT(*) FROM #TempNot) = 0)
		BEGIN
			SET @NotInError =   'Items not exist !'
			RAISERROR ( @NotInError, 16, 1 );  
			ROLLBACK TRANSACTION
								
		end


		IF((SELECT COUNT(*) FROM #TempNot) = 0)
		BEGIN
				SELECT RequestHeaderId , RequestDetailsId , StockItemCode, ItemName, UnitCode, UnitPrice, DocumentNo, RequestedQuantity,ROUND(QuantityInHand,@DecimalPlace) AS QuantityInHand,
			RequestDate, Remarks, DocumentStatus,StockItemDetailsID, StockItemHeaderId , UnitId , ApprovedQuantity,BrandedItem,
			CASE WHEN @IsBrandItem = 0 THEN '' ELSE  GenericCode END AS GenericCode,
			CASE WHEN @IsBrandItem = 0 THEN 0 ELSE  IsBranded END AS IsBranded
			,IsExpiryDateApplicable
			, ISNULL(C.CUSDECList,'') CUSDECList
			FROM #TempAllData T
			CROSS APPLY dbo.fn_GetCUSDECList(@LocationID,T.StockItemHeaderId,-999,@propertyId,@IsCUSDECSelection) C
			WHERE ApprovedQuantity >0
			ORDER BY StockItemCode,ItemName --RequestHeaderId, RequestDetailsId
		END
		ELSE
		BEGIN
			 
			IF EXISTS (SELECT TOP 1 ItemName FROM #TempNot tn
					LEFT OUTER JOIN StockItemHeaders H ON H.GenericItemCode= tn.StockItemCode
					LEFT OUTER JOIN StockItemDetails D ON D.StockItemHeaderID = h.Id
					AND D.LocationId  = @LocationID
					WHERE D.LocationId is null )

			BEGIN
	

					SELECT TOP 1 @ItemName=ItemName FROM #TempNot tn
					LEFT OUTER JOIN StockItemHeaders H ON H.GenericItemCode= tn.StockItemCode
					LEFT OUTER JOIN StockItemDetails D ON D.StockItemHeaderID = h.Id
					AND D.LocationId  = @LocationID
					WHERE D.LocationId is null 


					SET @NotInError =  @ItemName + ' - Not exists in this location !'
					RAISERROR ( @NotInError, 16, 1 );  
					ROLLBACK TRANSACTION
								
			END 

			DECLARE @BrandTable AS TABLE (ItemID INT, Qty MONEY, UnitID INT )
			DECLARE @SelectedBrandTable AS TABLE (ItemID INT, Qty MONEY)

			
			
			DECLARE @CurItemID int, @CurQTY MONEY, @BalQTY MONEY, @BrandItemID INT, @UnitID INT ,@CurQTYFrom INT,@CurQTYTo INT

			WHILE (SELECT COUNT(*) FROM #TempNot) > 0
			BEGIN
				
				SELECT TOP 1 @CurItemID= t.StockItemID , @CurQTY= ApprovedQuantity,@CurQTYFrom = ApprovedQuantity, @UnitID= t.UnitId
				FROM #TempNot T
                
				INSERT INTO @BrandTable (ItemID , Qty, UnitID)
				SELECT H.ID , 
				--D.QuantityInHand, 
				[dbo].[FN_GetStockInHand_Reatils](H.CompanyId,D.LocationID,H.Id) AS QuantityInHand,
				D.MasterUnitID
				FROM #TempNot T
				INNER JOIN StockItemHeaders H ON H.GenericItemCode= t.StockItemCode
				INNER JOIN StockItemDetails D ON D.StockItemHeaderID = h.Id
				WHERE D.LocationId  = @LocationID  and t.StockItemID = @CurItemID

			
                
				SELECT @CurQTYTo = dbo.FN_GetUnitConvertionRate(@propertyID,@UnitID,UnitID) 
				FROM @BrandTable


				SET @CurQTYTo = @CurQTYTo * @CurQTYFrom 
                
				WHILE EXISTS(SELECT  TOP 1 1 FROM @BrandTable) AND @CurQTYTo > 0
				BEGIN


					SELECT	TOP (1) @BrandItemID =  ItemID, 
							@BalQTY =   CASE WHEN Qty >  @CurQTYTo THEN @CurQTYTo ELSE Qty END 
					FROM @BrandTable
					ORDER BY Qty DESC

					SET @CurQTYTo -= @BalQTY

					INSERT INTO @SelectedBrandTable (ItemID , Qty)
					VALUES (@BrandItemID,@BalQTY)
					
					DELETE FROM @BrandTable WHERE  ItemID = @BrandItemID

				END 

				UPDATE TOP (1) @SelectedBrandTable
				SET Qty+= @CurQTYTo

				UPDATE #TempAllData
				SET ApprovedQuantity = 0
				WHERE StockItemHeaderId = @CurItemID


				DELETE FROM #TempNot
				WHERE StockItemID = @CurItemID
				
			END 
		

			INSERT INTO #TempAllData (RequestHeaderId,RequestDetailsId,RequestedQuantity,QuantityInHand,RequestDate,
									  StockItemDetailsID,
									  StockItemCode, ItemName, UnitCode, UnitPrice, Remarks, StockItemHeaderId , UnitId , ApprovedQuantity,BrandedItem,GenericCode,IsBranded,IsExpiryDateApplicable)
			SELECT 0,0,0,
			--D.QuantityInHand,
			[dbo].[FN_GetStockInHand_Reatils](H.CompanyId,D.LocationID,H.Id) AS QuantityInHand,
			GETDATE(),0,  StockItemCode, H.NAME ItemName, U.Code UnitCode, D.AveragePrice UnitPrice, '' Remarks, t.ItemID , U.ID UnitId , t.Qty,H.BrandedItem,H.GenericItemCode,1
			, H.IsExpiryDateApplicable
			FROM @SelectedBrandTable T
			INNER JOIN StockItemHeaders H ON H.ID = T.ItemID 
			INNER JOIN StockItemDetails D ON D.StockItemHeaderID = T.ItemID 
			INNER JOIN Units U ON U.Id = D.MasterUnitID
			LEFT JOIN RequestHeaders rh ON rh.Id = @RequestHeaderID
			WHERE D.LocationID = @LocationID AND rh.DocumentStatus = 'P'


			SELECT RequestHeaderId , RequestDetailsId , StockItemCode, ItemName, UnitCode, UnitPrice, DocumentNo, RequestedQuantity,ROUND(QuantityInHand,@DecimalPlace) AS QuantityInHand,
			RequestDate, Remarks, DocumentStatus,StockItemDetailsID, StockItemHeaderId , UnitId , ApprovedQuantity,BrandedItem,
			CASE WHEN @IsBrandItem = 0 THEN '' ELSE  GenericCode END AS GenericCode,
			CASE WHEN @IsBrandItem = 0 THEN 0 ELSE  IsBranded END AS IsBranded
			,IsExpiryDateApplicable
			, ISNULL(C.CUSDECList,'') CUSDECList
			FROM #TempAllData T
			CROSS APPLY dbo.fn_GetCUSDECList(@LocationID,T.StockItemHeaderId,-999,@propertyId,@IsCUSDECSelection) C
		WHERE ApprovedQuantity >0
		ORDER BY StockItemCode,ItemName --RequestHeaderId, RequestDetailsId
		END


 END

 --SELECT * FROM StockItemHeaders

 if	(@Operation='U') -- show only Transfer Out details for Transfer IN
 begin

SELECT DISTINCT RequestHeaders.Id, RequestHeaders.DocumentNo   --, INV_PickNoteHeader.DocumentNo as PickNoteNo
FROM            RequestHeaders INNER JOIN RequestDetails ON RequestHeaders.Id= RequestDetails.RequestHeaderID
				---INNER JOIN INV_PickNoteHeader ON INV_RequestHeader.RequestHeaderID = INV_PickNoteHeader.ReferenceID
WHERE        (RequestHeaders.LocationID = @LocationID) 
AND			(RequestHeaders.RequestType = @RequestType) 
AND			(RequestHeaders.IsApproved = 1)  
AND (RequestHeaders.DocumentStatus = 'P' )---and INV_PickNoteHeader.DocumentStatus = 'P')
--AND (INV_RequestDetail.ApprovedQuantity - INV_RequestDetail.IssuedQuantity ) > 0

end


IF(@Operation = 'C')
BEGIN
	SELECT PH.ID RequestHeaderId , PD.ID RequestDetailsId ,SH.StockItemCode StockItemCode,SH.Name ItemName,UN.Name UnitCode,SD.AveragePrice UnitPrice, 
	PH.DocumentNo DocumentNo,(PD.ConvertedQuanity- ISNULL(PD.RecievedQuantity,0)) RequestedQuantity
	,dbo.FN_GetUnitConvertionRate(@PropertyID,SD.MasterUnitID,PD.MasterUnitID) *ROUND(SD.QuantityInHand,@DecimalPlace) AS QuantityInHand2,
	ROUND(SD.QuantityInHand,@DecimalPlace) AS QuantityInHand,
	PH.RequestedDate RequestDate,'' Remarks,PH.Status DocumentStatus,SD.Id StockItemDetailsID,SH.Id StockItemHeaderId ,UN.Id UnitId ,(PD.ConvertedQuanity- ISNULL(PD.RecievedQuantity,0)) ApprovedQuantity
	, SH.BrandedItem,'' GenericCode, 0 IsBranded
	,SD.MasterUnitID stock, PD.MasterUnitID
	,dbo.FN_GetUnitConvertionRate(@PropertyID,SD.MasterUnitID,PD.MasterUnitID) Rate
	,IsExpiryDateApplicable	
	INTO #TEMP
	FROM ProductionConsolidateHeader PH
	INNER JOIN ProductionConsolidateRecipeSummary PD ON PH.ID = PD.ProductionConsolidateHeaderID
	INNER JOIN StockItemHeaders SH ON PD.RecipeItemID = SH.Id
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID AND SD.LocationID = @LocationID
	INNER JOIN Units UN ON UN.Id = SD.MasterUnitID
	WHERE PH.ID = @RequestHeaderID
	--AND PH.RequestedDate = CONVERT(DATE,GETDATE()) commented by isuru 2025-06-03
	AND (PD.ConvertedQuanity- ISNULL(PD.RecievedQuantity,0)) >0

	SELECT  RequestHeaderId , RequestDetailsId , StockItemCode,ItemName,UnitCode, UnitPrice, 
	DocumentNo,RequestedQuantity,QuantityInHand2, QuantityInHand,
	RequestDate, Remarks, DocumentStatus,StockItemDetailsID, StockItemHeaderId ,UnitId 
	, BrandedItem, GenericCode,  IsBranded
	, stock, MasterUnitID, Rate
	,IsExpiryDateApplicable	
	,dbo.FN_GetUnitConvertionRate(@PropertyID,MasterUnitID,stock) *ApprovedQuantity AS ApprovedQuantity
	,dbo.FN_GetUnitConvertionRate(@PropertyID,MasterUnitID,stock) *ApprovedQuantity AS RequestedQuantity
	FROM #TEMP




END


COMMIT TRAN
END TRY

BEGIN CATCH
ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);



    END CATCH;
END

GO

