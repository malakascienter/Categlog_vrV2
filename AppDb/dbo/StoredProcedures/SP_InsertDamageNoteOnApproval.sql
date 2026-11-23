
CREATE  Procedure [dbo].[SP_InsertDamageNoteOnApproval] --1,2,241 --1,2,156
@PropertyId int,
@locationId  int,
@DamgeRequestHeaderId int 
as

BEGIN
BEGIN TRY
SELECT 'SP_InsertDamageNoteOnApproval' 
DECLARE @POSTGL INT,@GLPostType CHAR(2),
				@RecipeItemID INT,
				@RecipeQuantity DECIMAL(18,8),
				@RecipeQuantityVariance DECIMAL(18,8),
				@RecipeUnitID INT,
				@CreatedUserID INT,
				@IsAutoProduction BIT
				,@IsBatchTransactionEnable BIT

SELECT @POSTGL=POSTGL, @GLPostType = CompanySeparator ,@IsAutoProduction = IsAutoProduction ,@IsBatchTransactionEnable = IsBatchTransactionEnable 
FROM Companies  C
where C.CompanyID= @propertyID






DECLARE @DocumentNo VARCHAR(MAX),@TransactionDate DATETIME, @StockTransactionHeaderID BIGINT, @StockItemName VARCHAR(500), @ItemId INT,
		@Quantity MONEY, @QuantityInHandError VARCHAR(500)

SELECT @ItemId = StockItemID, @Quantity= RequestedQuantity FROM RequestDetails WHERE RequestHeaderID = @DamgeRequestHeaderId

	SELECT @StockItemName = StockItemcode + ' / ' + Name  FROM StockItemHeaders
				WHERE ID= @ItemId

				IF EXISTS(	SELECT 1 FROM StockItemDetails SD 
							INNER JOIN StockItemHeaders SH ON SD.StockItemHeaderID = SH.ID
							WHERE sd.StockItemHeaderID = @ItemId 
							AND SD.QuantityInHand < @Quantity 
							AND SD.LocationID = @LocationID  AND SH.IsProductionItem=0
							)
				BEGIN
					SET @QuantityInHandError =  @StockItemName + ' - Cannot exceed quantity in hand!'
					RAISERROR ( @QuantityInHandError, 16, 1 );  
					ROLLBACK TRANSACTION
				END 


declare @TransactionType char(2),  @unitID int
Declare  @AveragePrice money, @StockItemID bigint, @unitPrice money, @ReferenceID bigint

SELECT @CreatedUserID = UserProfileID 
FROM RequestHeaders H
where H.RequestType ='RD' and H.Id =@DamgeRequestHeaderId

Create table #ItemList_DM
(StockItemID INT, Quantity DECIMAL(18,8), TxnUnitID int, UnitPrice money)

INSERT INTO #ItemList_DM(StockItemID,Quantity,TxnUnitID,UnitPrice)
SELECT StockItemID,RequestedQuantity,UnitID,UnitPrice
FROM RequestDetails 
WHERE RequestHeaderID = @DamgeRequestHeaderId

SELECT *
FROM #ItemList_DM

--Added by isuru 2024-09-03 for Production
			
				SELECT * 
				INTO #TempRecipeDetails_DM
				FROM #ItemList_DM
			----------
			DECLARE @ProductionOutHeaderID INT
			DECLARE @ProductionOutHeaderTable TABLE (
				ID INt
			)
			----------
			-- Commented by Isuru to stop auto production for Damage Notes as Dilmah instructed 2026-06-08
				--IF(@IsAutoProduction=1) 
				--BEGIN

				--	SELECT 'INSIDE SALES sp'

				--	WHILE EXISTS(SELECT 1 FROM #TempRecipeDetails_DM)
				--	BEGIN
				--		SELECT TOP (1) @RecipeItemID= StockItemID, @RecipeQuantity = Quantity,@RecipeUnitID =  TxnUnitID FROM #TempRecipeDetails_DM

				--		IF EXISTS(SELECT 1
				--			FROM StockItemHeaders SH 
				--			INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
				--			WHERE SH.Id = @RecipeItemID AND SD.LocationID = @LocationID AND SH.CompanyId = @PropertyID
				--			AND SH.IsProductionItem =1 AND SD.QuantityInHand < @RecipeQuantity)
				--		BEGIN
							
				--			SELECT @RecipeQuantityVariance = @RecipeQuantity - SD.QuantityInHand
				--			FROM StockItemHeaders SH 
				--			INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
				--			WHERE SH.Id = @RecipeItemID AND SD.LocationID = @LocationID AND SH.CompanyId = @PropertyID
				--			AND SH.IsProductionItem =1 AND SD.QuantityInHand < @RecipeQuantity

				--			SELECT 'QQ22'
				--			EXEC SaveProductionRecipeDetails  @LocationID,@RecipeItemID,@PropertyID ,@RecipeUnitID , @RecipeQuantityVariance , @CreatedUserId,null,1,@ProductionOutHeaderID OUTPUT
				--			SELECT 'QQ11'
				--		END
				--		DELETE TOP (1) FROM #TempRecipeDetails_DM
				--	END
				--END
			
			--End


set @TransactionDate= convert(datetime,GETDATE(),103)

set @DocumentNo= dbo.FN_GetNextDocumentNumber(@PropertyId,@locationId,'DN')

IF @DocumentNo IS NULL
BEGIN
	INSERT INTO TransactionTypeWiseNextNumbers
	(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,@LocationID,'DN',1,6)
END

select @DocumentNo= dbo.FN_GetNextDocumentNumber(@PropertyID,@LocationID,'DN')



update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1
where locationid=@LocationID and transactionType='DN'



--insert into StockTransactionHeaders
--		( DocumentNo, TransactionType, TransactionDate, LocationID, PropertyID, Remarks, ReferenceID,  UserProfileID,TransactionID)
--select	  @DocumentNo, 'DN' TransactionType, @TransactionDate, LocationID, PropertyID, Remarks, @DamgeRequestHeaderId ReferenceID,  UserProfileID,dbo.FN_GetTransactionID('DN')
--from RequestHeaders h
--where h.RequestType ='RD' and h.Id=@DamgeRequestHeaderId and h.IsApproved = 1	

INSERT INTO dbo.StockTransactionHeaders
			         ( DocumentNo , TransactionType ,TransactionDate ,PropertyID , LocationID ,ReferenceNo , SupplierID , Remarks , 
					 ReferenceID , DepartmentID , UserProfileID , TransferLocationID ,TransactionID , SuppCurrencyID, ExchangeRate,CreatedUserID,LastModUserID,CreatedDate,LastModDate,DamageCategoryID)
select	 h.DocumentNo, 'DN',ISNULL([dbo].[FN_GetCurrentDate](PropertyID,LocationID),GETDATE()),PropertyID, LocationID,0 ,0,Remarks, @DamgeRequestHeaderId,0,  UserProfileID,0,dbo.FN_GetTransactionID('DN'),0,0,h.UserProfileID, h.UserProfileID, GETDATE(), GETDATE(),DamageCategoryID
from RequestHeaders h
where h.RequestType ='RD' and h.Id=@DamgeRequestHeaderId and h.IsApproved = 1	


set @StockTransactionHeaderID= SCOPE_IDENTITY()

select @StockTransactionHeaderID
		----------------Transaction Type DN update PU ------------------
		-- Commented by Isuru to stop auto production for Damage Notes as Dilmah instructed 2026-06-08

		--IF(@IsAutoProduction =1 AND @StockTransactionHeaderID IS NOT NULL)
		--BEGIN
		--DECLARE @DamageNoteDocumentNo VARCHAR(50)
		--SELECT @DamageNoteDocumentNo =DocumentNo FROM StockTransactionHeaders WHERE Id = @StockTransactionHeaderID AND TransactionType = 'DN'
		--	IF EXISTS(SELECT 1 FROM @ProductionOutHeaderTable)
		--	BEGIN
		--		UPDATE sh
		--		SET ReferenceID = @StockTransactionHeaderID,
		--		ReferenceNo = @DamageNoteDocumentNo
		--		FROM
		--		StockTransactionHeaders SH
		--		INNER JOIN @ProductionOutHeaderTable P ON P.ID = SH.Id
		--		WHERE SH.TransactionType = 'PU'
		--	END
		--END
		----------------------------------
insert into dbo.StockTransactionDetails 
		(StockTransactionHeaderID, StockItemID, Quantity, UnitPrice, TxnUnitID, MasterUnitID, 
		MasterUnitConversion, ReportUnitID, ReportUnitConversion, StockMasterQuantity, StockMasterAveragePrice,
		NewQuantity, NewAveragePrice, Remarks, UserProfileId,   TXNTYPE,DiscountValue,DiscountPercentage,CostTransactionAccountID,
		PurchaseTransactionAccountID,BalanceQuantity, ReturnQuantity,ItemUnitPriceInSuppCurrency,CreatedUserID,LastModUserID,CreatedDate,LastModDate)

select		@StockTransactionHeaderID, StockItemID, r.ApprovedQuantity,dbo.FN_GetAveragePrice(@PropertyID,@LocationID, StockItemID, 'DN',0,UnitId,0), UnitID	,	
dbo.FN_GetMasterUnitID(@PropertyId,@locationId,r.StockItemID) MasterUnitID,
			dbo.FN_GetUnitConvertionRate(@PropertyID,UnitId,dbo.FN_GetMasterUnitID(@PropertyID,@LocationID, stockItemId)), 
			dbo.FN_GetReportingUnitID(@PropertyID,@LocationID, stockItemId),
			dbo.FN_GetUnitConvertionRate( @PropertyID,UnitId,dbo.FN_GetReportingUnitID(@PropertyID,@LocationID, stockItemId)), 
			dbo.FN_GetStockInHand(@PropertyID,@LocationID, stockItemId) StockMasterQuantity, 
			dbo.FN_GetAveragePrice(@PropertyID,@LocationID, stockItemId, 'DN',0,UnitId,0), 
			dbo.FN_GetStockInHand(@PropertyID,@LocationID, stockItemId) -r.ApprovedQuantity NewQuantity, 
			dbo.FN_GetAveragePrice(@PropertyID,@LocationID, stockItemId, 'DN',0,UnitId,0), 
			r.Remarks,UserProfileID,'M',0,0,0, 0,0,0,0,h.UserProfileID,h.UserProfileID,GETDATE(),GETDATE()
			from RequestHeaders h
inner join RequestDetails r on r.RequestHeaderID = h.Id 
where h.RequestType ='RD' and h.Id =@DamgeRequestHeaderId and h.IsApproved = 1


Create table #newItemList_DM
(StockItemID bigint, Quantity money, TxnUnitID int, UnitPrice money)

insert into #newItemList_DM (StockItemID, Quantity , TxnUnitID , UnitPrice)
SELECT   StockItemID, Quantity , TxnUnitID , UnitPrice
FROM     StockTransactionDetails
where StockTransactionHeaderID=@StockTransactionHeaderID

while (select COUNT(*) from #newItemList_DM)>0
begin 


select top (1) @StockItemId=StockItemId, @unitID =TxnUnitId, @Quantity = Quantity, @unitPrice=unitPrice from #newItemList_DM
order by StockItemId

set @AveragePrice= dbo.FN_GetAveragePrice(@PropertyID,@LocationID, @stockItemId,@TransactionType,@Quantity,@unitID, @unitPrice)

exec SP_UpdateStockItemBalance @PropertyID , @LocationID ,@StockItemID ,'DN', @Quantity, @unitID, @AveragePrice


-- Added by Isuru 2025-02-21 for updating DN note Batch transaction ID
IF (@IsBatchTransactionEnable =1)
BEGIN
	UPDATE StockItemWiseEXPDateIns
	SET TransactionID =@StockTransactionHeaderID, TransactionType = 'DN' 
	WHERE TransactionID = @DamgeRequestHeaderId
	AND TransactionType='RD'
END


--End


delete from #newItemList_DM
where StockItemId= @StockItemId
end 

IF @GLPostType='DJ' AND  @POSTGL= 1
BEGIN
	EXEC InsertDoubleEntree  @StockTransactionHeaderID, @LocationID
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

