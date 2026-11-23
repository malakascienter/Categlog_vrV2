-- Last Modified by : Nivesh
-- Modified date	: 2025-07-23
--   [dbo].[Get_ALL_StockTransferOUT] 9495,7,0,1, '2025-10-02'

CREATE PROCEDURE [dbo].[Get_ALL_StockTransferOUT]
    @Id INT,
    @LocationID INT,
    @IsAheader INT,
	@PropertyID INT = 0,
	@DeliveryDate DATE = NULL
AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION

DECLARE @StockItemId INT, @Quantity DECIMAL, @Branded BIT, @GenericCode VARCHAR(500), @ItemName VARCHAR(500),@NotInError VARCHAR(500),
		@ToLocationId INT, @IsFranchise bit =0, @IsDeliverydateforRequest BIT,@DisplayOriginalTRQty BIT,@IsModifyTransferIn BIT

		SELECT @PropertyID = PropertyId
		FROM Locations
		WHERE ID = @LocationID

	SELECT @IsDeliverydateforRequest = IsDeliverydateforRequest ,@DisplayOriginalTRQty = DisplayOriginalTRQty,@IsModifyTransferIn = IsModifyTransferIn
	FROM Companies WHERE CompanyID = @PropertyID

--CREATE TABLE #TEMPD(
--	[Id] [INT]  NOT NULL,
--	[StockTransactionHeaderID] [INT] NOT NULL,
--	[StockItemID] [INT] NOT NULL,
--	[Quantity] [DECIMAL](18, 2) NOT NULL,
--	[UnitPrice] [DECIMAL](18, 2) NOT NULL,
--	[TxnUnitID] [INT] NOT NULL,
--	[MasterUnitID] [INT] NOT NULL,
--	[MasterUnitConversion] [DECIMAL](18, 2) NOT NULL,
--	[ReportUnitID] [INT] NOT NULL,
--	[ReportUnitConversion] [DECIMAL](18, 2) NOT NULL,
--	[DiscountValue] [DECIMAL](18, 2) NOT NULL,
--	[DiscountPercentage] [DECIMAL](18, 2) NOT NULL,
--	[TimeStamp] [NVARCHAR](256) NULL,
--	[StockMasterQuantity] [DECIMAL](18, 2) NOT NULL,
--	[StockMasterAveragePrice] [DECIMAL](18, 2) NOT NULL,
--	[NewQuantity] [DECIMAL](18, 2) NOT NULL,
--	[NewAveragePrice] [DECIMAL](18, 2) NOT NULL,
--	[Remarks] [NVARCHAR](MAX) NULL,
--	[UserProfileId] [INT] NOT NULL,
--	[CostTransactionAccountID] [INT] NOT NULL,
--	[PurchaseTransactionAccountID] [INT] NOT NULL,
--	[TxnType] [NVARCHAR](1) NULL,
--	[BalanceQuantity] [DECIMAL](18, 2) NOT NULL,
--	[ReturnQuantity] [DECIMAL](18, 2) NOT NULL,
--	[ItemUnitPriceInSuppCurrency] [DECIMAL](18, 2) NOT NULL,
--	[IPAddress] [NVARCHAR](MAX) NULL,
--	[CreatedUserID] [INT] NOT NULL,
--	[LastModUserID] [INT] NOT NULL,
--	[CreatedDate] [DATETIME] NOT NULL,
--	[LastModDate] [DATETIME] NOT NULL,
--);

	Select @IsFranchise= IsFranchise from Locations where id =@LocationID

    IF (@IsAheader = 1)
    BEGIN
  --      SELECT S1.Id,s1.DocumentNo,s1.TransactionType,s1.TransactionDate,S1.PropertyID,
		--s1.LocationID,s1.ReferenceNo,s1.ReferenceNo,s1.SupplierID,s1.Remarks,s1.ReferenceID,s1.DepartmentID,
		--s1.UserProfileID,s1.TransferLocationID,s1.TimeStamp,s1.TransactionID,s1.Mode,s1.SuppCurrencyID,
		--s1.ExchangeRate,s1.IPAddress,s1.CreatedUserID,s1.LastModDate,s1.CreatedDate,s1.IsPrint,s1.IsApproved
	
	IF(ISNULL(@IsDeliverydateforRequest,0) = 1)
	BEGIN
		SELECT S1.[Id]
			  ,S1.DocumentNo  AS DocumentNo
			  ,CONCAT(S1.DocumentNo,' - ', CONVERT(VARCHAR, S1.[TransactionDate], 113))  AS DocumentNoString
			  ,S1.[TransactionType]
			  ,S1.[TransactionDate]
			  ,S1.[PropertyID]
			  ,S1.[LocationID]
			  ,S1.[ReferenceNo]
			  ,S1.[SupplierID]
			  ,S1.[Remarks]
			  ,S1.[ReferenceID]
			  ,S1.[DepartmentID]
			  ,S1.[UserProfileID]
			  ,S1.[TransferLocationID]
			  ,S1.[TimeStamp]
			  ,S1.[TransactionID]
			  ,S1.[Mode]
			  ,S1.[SuppCurrencyID]
			  ,S1.[ExchangeRate]
			  ,S1.[IPAddress]
			  ,S1.[CreatedUserID]
			  ,S1.[LastModUserID]
			  ,S1.[CreatedDate]
			  ,S1.[LastModDate]
			  ,S1.[IsPrint]
			  ,S1.[IsApproved]
			  ,S1.[IsTrasferIn]
			  ,S1.[InvoiceDate]
			  ,S1.[GLDATE]
			  ,S1.[IsDirectIssue]
			  ,S1.[GRNTypeID]
			  ,S1.[BudgetID]
			  ,S1.[PaidAmount]
			  ,S1.[SendMail]
			  ,S1.[IsProdGenerate]
			  ,S1.[IsProductionPlan]
			  ,S1.[FileName] 
        FROM dbo.StockTransactionHeaders AS S1
		LEFT JOIN RequestHeaders RH ON RH.Id = S1.ReferenceID
		WHERE
          S1.TransferLocationID = @LocationID
              AND S1.TransactionType = 'TO' AND IsTrasferIn=0
			  AND @DeliveryDate = CASE WHEN RH.Id IS NULL THEN S1.TransactionDate ELSE CONVERT( DATE,RH.DeliveryDate) END
	END
	ELSE
	BEGIN
		SELECT S1.[Id]
			  ,CONCAT(S1.DocumentNo,' - ', CONVERT(VARCHAR, S1.[TransactionDate], 113))  AS DocumentNoString
			  ,S1.[TransactionType]
			  ,S1.[TransactionDate]
			  ,S1.[PropertyID]
			  ,S1.[LocationID]
			  ,S1.[ReferenceNo]
			  ,S1.[SupplierID]
			  ,S1.[Remarks]
			  ,S1.[ReferenceID]
			  ,S1.[DepartmentID]
			  ,S1.[UserProfileID]
			  ,S1.[TransferLocationID]
			  ,S1.[TimeStamp]
			  ,S1.[TransactionID]
			  ,S1.[Mode]
			  ,S1.[SuppCurrencyID]
			  ,S1.[ExchangeRate]
			  ,S1.[IPAddress]
			  ,S1.[CreatedUserID]
			  ,S1.[LastModUserID]
			  ,S1.[CreatedDate]
			  ,S1.[LastModDate]
			  ,S1.[IsPrint]
			  ,S1.[IsApproved]
			  ,S1.[IsTrasferIn]
			  ,S1.[InvoiceDate]
			  ,S1.[GLDATE]
			  ,S1.[IsDirectIssue]
			  ,S1.[GRNTypeID]
			  ,S1.[BudgetID]
			  ,S1.[PaidAmount]
			  ,S1.[SendMail]
			  ,S1.[IsProdGenerate]
			  ,S1.[IsProductionPlan]
			  ,S1.[FileName] 
        FROM dbo.StockTransactionHeaders AS S1
		WHERE
          S1.TransferLocationID = @LocationID
              AND S1.TransactionType = 'TO' AND IsTrasferIn=0
	END

		
    END;
    ELSE

    BEGIN
		DECLARE @ReferenceID INT,@TransINID INT
		SELECT @ReferenceID=ReferenceID  
		FROM dbo.StockTransactionHeaders WHERE Id=@Id
		

		SELECT * INTO #TempTran from 
		(
        SELECT STD.Id,
               STD.StockTransactionHeaderID,
               STD.StockItemID,
               STD.Quantity,
               --STD.UnitPrice,
			   case When @IsFranchise = 0 then STD.UnitPrice else STD.SellingPrice End as UnitPrice , --Add By Uditha 2025-06-26 For Invoice Module
               STD.TxnUnitID,
               STD.MasterUnitID,
               STD.MasterUnitConversion,
               STD.ReportUnitID,
               STD.ReportUnitConversion,
               STD.DiscountValue,
               STD.DiscountPercentage,
               STD.TimeStamp,
               STD.StockMasterQuantity,
               STD.StockMasterAveragePrice,
               STD.NewQuantity,
               STD.NewAveragePrice,
               STD.Remarks,
               STD.UserProfileId,
               STD.CostTransactionAccountID,
               STD.PurchaseTransactionAccountID,
               STD.TxnType,
               STD.Quantity AS BalanceQuantity,
               STD.ReturnQuantity,
               STD.ItemUnitPriceInSuppCurrency,
               STD.IPAddress,
               STD.CreatedUserID,
               STD.LastModUserID,
               STD.CreatedDate,
               STD.LastModDate,
			   SH.Name AS ItemName,
			   SH.BrandedItem,
			   SH.GenericItemCode,
			   SH.StockItemCode,
			   SH.IsExpiryDateApplicable,
				STD.IssuedQuantity
				,STD.SelectedCUSDECID
        FROM dbo.StockTransactionDetails STD 
		INNER JOIN dbo.StockItemHeaders AS SH 
		ON STD.StockItemID=SH.Id  
		LEFT JOIN dbo.StockItemDetails sd
		ON sd.StockItemHeaderID = SH.Id AND sd.LocationID = @LocationID
		WHERE STD.StockTransactionHeaderID=@Id 
		AND isnull(SH.GenericItemCode,'') = ''

			UNION ALL
		  SELECT 0 Id,
               STD.StockTransactionHeaderID,
              STD.RequestedGenericItemId StockItemID,
               SUM(STD.Quantity * dbo.FN_GetUnitConvertionRate(sh.CompanyId, STD.TxnUnitID,g.MasterUnitID) ) Quantity,
              -- (sum(STD.UnitPrice * STD.Quantity * dbo.FN_GetUnitConvertionRate(sh.CompanyId, g.MasterUnitID,STD.TxnUnitID)  ) /  SUM(STD.Quantity  ) )AS UnitPrice,
               ROUND((sum(case When @IsFranchise = 0 then (STD.UnitPrice / dbo.FN_GetUnitConvertionRate(sh.CompanyId, g.MasterUnitID,STD.TxnUnitID))  
			   else (STD.SellingPrice / dbo.FN_GetUnitConvertionRate(sh.CompanyId, g.MasterUnitID,STD.TxnUnitID)) End * 
			   STD.Quantity * dbo.FN_GetUnitConvertionRate(sh.CompanyId, g.MasterUnitID,STD.TxnUnitID)  ) 
			   /  SUM(STD.Quantity  / dbo.FN_GetUnitConvertionRate(sh.CompanyId, g.MasterUnitID,STD.TxnUnitID)) ),5)AS UnitPrice,
			  
			  g.MasterUnitID TxnUnitID,
               sd.MasterUnitID,

               1 MasterUnitConversion,

               7 ReportUnitID,
              0 ReportUnitConversion,
               STD.DiscountValue,
               STD.DiscountPercentage,
               STD.TimeStamp,

               sd.QuantityInHand StockMasterQuantity,

               0 StockMasterAveragePrice,

               0 NewQuantity,

               0 NewAveragePrice,

               '' Remarks,
               STD.UserProfileId,
               STD.CostTransactionAccountID,
               STD.PurchaseTransactionAccountID,
               STD.TxnType,
               SUM(STD.Quantity * dbo.FN_GetUnitConvertionRate(sh.CompanyId, STD.TxnUnitID,g.MasterUnitID) ) AS BalanceQuantity,
              0 ReturnQuantity,
              0 ItemUnitPriceInSuppCurrency,
               '' IPAddress,
               0 CreatedUserID,
               0 LastModUserID,
              GETDATE() CreatedDate,
              GETDATE() LastModDate,
			   SH.Name AS ItemName,
			   SH.BrandedItem,
			   SH.GenericItemCode,
			   SH.StockItemCode,
			   SH.IsExpiryDateApplicable,
			   STD.IssuedQuantity
			   ,STD.SelectedCUSDECID
        FROM dbo.StockTransactionDetails STD 
		INNER JOIN dbo.StockItemHeaders AS SH 	ON STD.RequestedGenericItemId=SH.Id 
		LEFT JOIN dbo.StockItemDetails sd ON sd.StockItemHeaderID = SH.Id AND sd.LocationID = @LocationID
		INNER JOIN StockItemDetails G ON G.StockItemId = STD.RequestedGenericItemId and sd.LocationId = G.LocationID
		WHERE STD.StockTransactionHeaderID=@Id AND isnull(STD.RequestedGenericItemId,'') <> '' 
		group by 
               STD.StockTransactionHeaderID,
               STD.RequestedGenericItemId,
              sd.MasterUnitID,
               STD.DiscountValue,
               STD.DiscountPercentage,
               STD.TimeStamp,
                sd.QuantityInHand,
               STD.UserProfileId,
               STD.CostTransactionAccountID,
               STD.PurchaseTransactionAccountID,
               STD.TxnType,
			   SH.Name,
			   SH.BrandedItem,
			   SH.GenericItemCode,
			   SH.StockItemCode,g.MasterUnitID,
			   SH.IsExpiryDateApplicable,
			   STD.IssuedQuantity
			    ,STD.SelectedCUSDECID
			)x
			order by StockTransactionHeaderID, Id



		SELECT @ToLocationId = LocationId FROM StockTransactionHeaders WHERE Id = @Id

		--select * from #TempTran
		--select @ToLocationId '1111'
		
		SELECT Tt.* INTO #TempAllStockItems
		FROM #TempTran Tt
		INNER JOIN StockItemHeaders SIH
		ON Tt.StockItemID = SIH.Id
		INNER JOIN StockItemDetails SID
		ON SIH.Id = SID.StockItemHeaderID
		WHERE SID.LocationID = @LocationID

	

		SELECT * INTO #TempNot 
		FROM #TempTran
		EXCEPT 
		SELECT * FROM #TempAllStockItems
		
		
		IF((SELECT COUNT(*) FROM #TempNot) = 0)
		BEGIN
		
			SELECT   DISTINCT
			   T.Id,
               T.StockTransactionHeaderID,
               T.StockItemID,
               T.Quantity - T.IssuedQuantity Quantity,
               T.UnitPrice,
               T.TxnUnitID,
               T.MasterUnitID,
               T.MasterUnitConversion,
               T.ReportUnitID,
               T.ReportUnitConversion,
               T.DiscountValue,
               T.DiscountPercentage,
               T.TimeStamp,
               T.StockMasterQuantity,
               T.StockMasterAveragePrice,
               T.NewQuantity,
               T.NewAveragePrice,
               T.Remarks,
               T.UserProfileId,
               T.CostTransactionAccountID,
               T.PurchaseTransactionAccountID,
               T.TxnType,
               T.Quantity AS BalanceQuantity,
               T.ReturnQuantity,
               T.ItemUnitPriceInSuppCurrency,
               T.IPAddress,
               T.CreatedUserID,
               T.LastModUserID,
               T.CreatedDate,
               T.LastModDate,
			   T.ItemName,
			   T.BrandedItem,
			   T.GenericItemCode,
			   T.StockItemCode,
			   T.IsExpiryDateApplicable,
			   T.IssuedQuantity,
			   CASE WHEN (@IsModifyTransferIn = 0 AND @DisplayOriginalTRQty = 1) THEN RS.BalanceRequestedQty ELSE T.Quantity - T.IssuedQuantity END AS RemainQuantity,
			   U.Name TXNUnit 
			   ,STH.ReferenceNo CUSDECNO
			   ,T.SelectedCUSDECID
			   FROM #TempTran T
			LEFT JOIN Units U ON U.Id = T.TxnUnitID
			LEFT JOIN RequestionStatus RS ON RS.TransactionHeaderID = T.StockTransactionHeaderID  AND T.StockItemID = RS.StockItemID
			LEFT JOIN StockTransactionHeaders STH WITH(NOLOCK) ON T.SelectedCUSDECID = STH.ID AND STH.TransactionType = 'GR'
			WHERE T.Quantity - T.IssuedQuantity > 0
			order by t.StockTransactionHeaderID, t.Id
		END
		ELSE
		BEGIN

			IF EXISTS (SELECT TOP (1) 1 FROM #TempNot WHERE BrandedItem = 0)
			BEGIN

				SELECT TOP 1 @ItemName= StockItemcode + ' / ' + ItemName FROM #TempNot 
				WHERE BrandedItem = 0

				SET @NotInError =  @ItemName + ' - Not exists in this location !'
				RAISERROR ( @NotInError, 16, 1 );  
				ROLLBACK TRANSACTION
			END
		

			IF (SELECT COUNT(t.StockItemID) FROM #TempNot T 
						INNER JOIN StockItemHeaders H ON T.GenericItemCode = H.StockItemCode
						INNER  JOIN   StockItemDetails D ON D.StockItemHeaderID = H.ID 
						AND D.LocationID = @LocationID AND D.IsActive= 1) <> (SELECT COUNT(t.StockItemID) FROM #TempNot T)
			BEGIN

				SELECT  TOP (1) @ItemName= T.StockItemcode + ' / ' +ItemName FROM #TempNot T 
						INNER JOIN StockItemHeaders H ON T.GenericItemCode = H.StockItemCode
						LEFT  JOIN   StockItemDetails D ON D.StockItemHeaderID = H.ID 
						AND D.LocationID = @LocationID AND D.IsActive= 1
						WHERE D.LocationID is null 

				SET @NotInError =  @ItemName + ' - Not exists in this location !'
				RAISERROR ( @NotInError, 16, 1 );  
				ROLLBACK TRANSACTION
		
			END 
		
		SELECT 6678,*
		FROM #TempTran
			UPDATE A
			SET A.StockItemID = H.Id,  A.ItemName= H.Name,
				A.TxnUnitID = D.MasterUnitID,
				A.Quantity = A.Quantity * dbo.FN_GetUnitConvertionRate(D.CompanyID,A.TxnUnitID,D.MasterUnitID),
                A.UnitPrice= A.UnitPrice * dbo.FN_GetUnitConvertionRate(D.CompanyID,A.TxnUnitID,D.MasterUnitID),
				A.StockMasterQuantity = D.QuantityInHand, A.stockmasteraverageprice = D.AveragePrice,
				A.newquantity = D.QuantityInHand + (A.Quantity * dbo.FN_GetUnitConvertionRate(D.CompanyID,A.TxnUnitID,D.MasterUnitID)),
				A.balancequantity =  A.Quantity * dbo.FN_GetUnitConvertionRate(D.CompanyID,A.TxnUnitID,D.MasterUnitID)

			FROM #TempTran A
			INNER JOIN #TempNot T ON T.StockItemID = A.StockItemID
			INNER JOIN StockItemHeaders H ON H.StockItemCode = A.GenericItemCode
			INNER JOIN StockItemDetails D ON D.StockItemHeaderID = H.Id AND D.LocationID = @LocationID

			--SELECT * FROM #TempTran WHERE Quantity > 0

			--SELECT StockTransactionHeaderID,StockItemID,Quantity,UnitPrice,TxnUnitID,MasterUnitID,
			--ItemName,TxnType,BalanceQuantity, GenericItemCode,,
			--MasterUnitConversion FROM #TempTran 
			--WHERE Quantity > 0

			SELECT T.StockTransactionHeaderID,T.StockItemID,T.TxnUnitID,U.Name TXNUnit,T.MasterUnitID,T.TxnType,T.GenericItemCode AS ItemName, 
			SUM(T.Quantity)- SUM(T.IssuedQuantity) AS Quantity, SUM(T.BalanceQuantity) AS BalanceQuantity,SUM(T.IssuedQuantity) AS IssuedQuantity,SUM(T.Quantity)- SUM(T.IssuedQuantity) AS RemainQuantity, SUM(T.Quantity * T.UnitPrice)/SUM(T.Quantity) AS UnitPrice
			FROM #TempTran T
			LEFT JOIN Units U ON U.Id = T.TxnUnitID
			WHERE T.Quantity - T.IssuedQuantity > 0
			GROUP BY T.StockTransactionHeaderID, T.StockItemID,T.TxnUnitID,T.MasterUnitID,T.TxnType,T.GenericItemCode,U.Name
			order by t.StockTransactionHeaderID, t.Id

		END


    END;
COMMIT TRAN;
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
END CATCH

END;

GO

