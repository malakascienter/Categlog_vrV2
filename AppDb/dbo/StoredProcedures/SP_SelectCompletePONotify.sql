-- [dbo].[SP_SelectCompletePONotify]'C',4168,1,null,NULL,'2025-05-13', '2025-08-13', -999, -999

--go
CREATE PROCEDURE [dbo].[SP_SelectCompletePONotify] 
	@Type				VARCHAR(2) = 'S',
	@UserProfileId				int = 1,
	@PropertyID			INT = 0,
	@PoHeaderID			VARCHAR(100) = NULL,
	@PoDetailID			VARCHAR(100) = NULL,
	@FromDate			DATE = '',
	@ToDate				DATE = '',
	@SupplierID			INT = -999,
	@LocationID1			INT = -999
AS
BEGIN

BEGIN TRY 
Declare @T1 varchar(max),
			@T2 varchar(max),
			@T3 varchar(max),
			@Sql varchar(max),
			@IsPoModificationComponent bit

	IF(@UserProfileId = 0)
	BEGIN
		RAISERROR('User ID Invalid, Please Log In Again',16,1)
		ROLLBACK TRANSACTION
	END

	DECLARE @IsCentralLogin BIT,@DecimalPlaces INT
	
	SELECT	TOP (1) @IsCentralLogin = IsCentralLogin ,
	@DecimalPlaces = DecimalPlaces,
	@IsPoModificationComponent= IsPoModificationComponent
	FROM Companies
	WHERE CompanyID =  CASE WHEN @PropertyID = -999 THEN CompanyID ELSE @PropertyID END

	CREATE TABLE #TempNoGRNPO(
		ReferenceID INT
	)

	INSERT INTO #TempNoGRNPO
	SELECT ReferenceID FROM
	StockTransactionHeaders
	WHERE TransactionType = 'GR' AND ReferenceID <> 0
	GROUP BY ReferenceID
	
	IF(@Type = 'C')
	BEGIN
	
		IF(@IsCentralLogin = 1)
		BEGIN

			SELECT DISTINCT H.ID SN,
			   S.Name AS SupplierName,
			   H.SupplierID AS SupplierId,
		       H.PoNo ,
		       U.UserName ReqUserProf,
			   l.Name Location, 
			   h.DocumentDate ,
			   H.NetTotal POValue,
				ISNULL(H.Remarks,'') Remarks,
				C.name CompanyName,
				(SELECT COUNT(*) FROM POSendMailLog WHERE POHeaderID =  H.Id AND PropertyID = H.PropertyID AND IsSendMail =1) AS SuccessCount,
				(SELECT COUNT(*) FROM POSendMailLog WHERE POHeaderID =  H.Id AND PropertyID = H.PropertyID AND IsSendMail =0) AS FailureCount,
				CASE WHEN ISNULL((SELECT TOP 1 IsSendMail FROM POSendMailLog WHERE POHeaderID =  H.Id AND PropertyID = H.PropertyID ORDER BY LogDate DESC),0) = 1THEN 'Success' ELSE 'Fail' END AS MailStatus,
				ISNULL((SELECT TOP 1 IsSendMail FROM POSendMailLog WHERE POHeaderID =  H.Id AND PropertyID = H.PropertyID ORDER BY LogDate DESC),0) IsSendMail,
				S.Email,
				S.Email2
			FROM dbo.PoHeaders H
			INNER JOIN PoDetails PD ON PD.PoHeaderID = H.Id
			INNER JOIN [dbo].[CentralUsers] U ON u.Id = H.UserProfileID
			INNER JOIN suppliers S ON S.ID = H.SupplierID
			INNER JOIN dbo.Locations L ON L.Id = H.LocationID
			INNER JOIN Companies C ON C.CompanyID = H.PropertyID
			LEFT JOIN #TempNoGRNPO TGP ON TGP.ReferenceID = H.Id
			WHERE 
			DocumentStatus = 'P' AND 
			IsApproved = 1 
			AND H.PropertyID = CASE WHEN @PropertyID = -999 THEN H.PropertyID ELSE @PropertyID END
			AND TGP.ReferenceID IS NULL
			AND H.DocumentDate BETWEEN @FromDate AND @ToDate
			AND H.LocationID = CASE WHEN @LocationID1 = -999 THEN H.LocationID ELSE @LocationID1 END
			AND H.SupplierID = CASE WHEN @SupplierID = -999 THEN H.SupplierID ELSE @SupplierID END
		END
		ELSE
		BEGIN
			SELECT DISTINCT H.ID SN,
				S.Name AS SupplierName,
			   H.SupplierID AS SupplierId,
		       H.PoNo ,
		       U.UserName ReqUserProf,
			   l.Name Location, 
			   h.DocumentDate ,
			   H.NetTotal POValue,
			   ISNULL(H.Remarks,'') Remarks,
			   C.Name CompanyName,
				(SELECT COUNT(*) FROM POSendMailLog WHERE POHeaderID =  H.Id AND PropertyID = H.PropertyID AND IsSendMail =1) AS SuccessCount,
				(SELECT COUNT(*) FROM POSendMailLog WHERE POHeaderID =  H.Id AND PropertyID = H.PropertyID AND IsSendMail =0) AS FailureCount,
				CASE WHEN ISNULL((SELECT TOP 1 IsSendMail FROM POSendMailLog WHERE POHeaderID =  H.Id AND PropertyID = H.PropertyID ORDER BY LogDate DESC),0) = 1THEN 'Success' ELSE 'Fail' END AS MailStatus,
				ISNULL((SELECT TOP 1 IsSendMail FROM POSendMailLog WHERE POHeaderID =  H.Id AND PropertyID = H.PropertyID ORDER BY LogDate DESC),0) IsSendMail
			FROM dbo.PoHeaders H
			INNER JOIN suppliers S ON S.ID = H.SupplierID
			INNER JOIN dbo.UserMasters U ON u.Id = H.UserProfileID
			INNER JOIN dbo.Locations L ON L.Id = H.LocationID
			INNER JOIN Companies C ON C.CompanyID = H.PropertyID
			LEFT JOIN #TempNoGRNPO TGP ON TGP.ReferenceID = H.Id
			WHERE 
			DocumentStatus = 'P' AND 
			IsApproved = 1  
			AND H.PropertyID = CASE WHEN @PropertyID = -999 THEN H.PropertyID ELSE @PropertyID END
			AND TGP.ReferenceID IS NULL
			AND H.DocumentDate BETWEEN @FromDate AND @ToDate
			AND H.LocationID = CASE WHEN @LocationID1 = -999 THEN H.LocationID ELSE @LocationID1 END
			AND H.SupplierID = CASE WHEN @SupplierID = -999 THEN H.SupplierID ELSE @SupplierID END
		END

	END
	ELSE IF(@Type = 'D')
	BEGIN

			DECLARE @PoHeaderIDtemp INT, @LocationID int
				SET @PoHeaderIDtemp = CAST (@PoHeaderID AS INT)
			
		
			DECLARE @tblRequestHeader AS TABLE (Id INT IDENTITY(1,1),PoDetailID INT,PoHeaderID INT,StockItemID INT,StockItemCode INT,
			ItemName VARCHAR(max),UnitCode int,UnitName VARCHAR(max), StockInHand  DECIMAL(18,8) ,RequestedQuantity DECIMAL(18,8) ,
			ApprovedQuantity DECIMAL(18,8) ,ReceivedQuantity DECIMAL(18,8),Remarks VARCHAR(max),UnitPrice DECIMAL(18,8),flag INT,
			RequestHeaderID INT,RequestionQty DECIMAL(18,8), LocationID int, Tax DECIMAL(18,8) )

			INSERT INTO @tblRequestHeader
					(
					  PoDetailID ,
					  PoHeaderID ,
					  StockItemID ,
					  StockItemCode ,
					  ItemName ,
					  UnitCode ,
					  UnitName ,
					  RequestedQuantity ,
					  ApprovedQuantity,
					  ReceivedQuantity ,
					  Remarks ,
					  UnitPrice,
					  flag,
					  RequestHeaderID,
					  RequestionQty,
					  StockInHand,
					  LocationID,
					  Tax
					)
			SELECT	DISTINCT	
				d.Id AS PoDetailID,
				d.PoHeaderID, 
				D.StockItemID,  
				i.StockItemID AS StockItemCode,			
				ih.Name AS ItemName,
				d.UnitID AS UnitCode, 
				u.Name  AS UnitName,
				d.RequestedQuantity, 
				d.ApprovedQuantity, 
				ReceivedQuantity, 
				d.Remarks,
				d.UnitPrice - case when DiscountValue<> 0 THEN DiscountValue ELSE (d.UnitPrice *DiscountPercentage /100) END  ,
				ISNULL(RH.flag,0),
				PWR.RequestHeaderID,
				PWR.RequestionQty,
				--dbo.GetStockInHand(h.PropertyID,h.LocationID,d.StockItemID),
				 dbo.[FN_GetStockInHand_Reatils](h.PropertyID,h.LocationID,d.StockItemID),
				h.LocationID,
				h.TaxTotal

			FROM         dbo.PoDetails d
				inner join	dbo.PoHeaders h on h.Id = d.PoHeaderID
				inner join	dbo.StockItemDetails i 
				on i.PropertyID = h.PropertyID and h.LocationID = i.LocationID and i.StockItemHeaderID=d.StockItemID
				inner join dbo.StockItemHeaders ih
				on ih.Id = i.StockItemHeaderID and ih.CompanyId = i.CompanyID
				inner join dbo.Units u on u.Id=d.UnitID 
			LEFT  JOIN dbo.PoWisePRs AS PWR ON PWR.PoHeaderID = h.Id AND d.StockItemID=PWR.StockItemID
			LEFT  JOIN dbo.RequestHeaders RH ON RH.Id=PWR.RequestHeaderID 
			WHERE     (d.PoHeaderID = @PoHeaderIDtemp )

			DECLARE @tblRequestHeaderW AS TABLE (
				Id INT IDENTITY(1,1),
				PoDetailID INT,
				PoHeaderID INT,
				StockItemID INT,
				StockItemCode INT,
				ItemName VARCHAR(max),
				UnitCode int,
				UnitName VARCHAR(max),
				RequestedQuantity DECIMAL(18,8) ,
				ApprovedQuantity DECIMAL(18,8) ,
				ReceivedQuantity DECIMAL(18,8),
				Remarks VARCHAR(max),
				UnitPrice DECIMAL(18,8),
				ISMrn BIT, 
				StockInHand  DECIMAL(18,8),
				AdditonalChargesTotal Decimal(18,8),
				LastPurchasePrice Decimal(18,8),
				TotalTax Decimal(18,8) 
			)

			WHILE (SELECT count(*) FROM @tblRequestHeader)>0
			BEGIN

				DECLARE @PoHeaderID1 INT,@StockItemID INT 
				
				SELECT DISTINCT TOP (1)  
					@PoHeaderID1 = PoHeaderID,
					@StockItemID=StockItemID,
					@LocationID =LocationID  
				FROM @tblRequestHeader

				IF EXISTS(
				SELECT * 
				FROM @tblRequestHeader 
				WHERE PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID AND flag=1
				)
				BEGIN

					INSERT INTO @tblRequestHeaderW
							( 
							  PoDetailID ,
							  PoHeaderID ,
							  StockItemID ,
							  StockItemCode ,
							  ItemName ,
							  UnitCode ,
							  UnitName ,
							  RequestedQuantity ,
							  ApprovedQuantity ,
							  ReceivedQuantity ,
							  Remarks ,
							  UnitPrice ,
							  ISMrn,
							  StockInHand,
							  AdditonalChargesTotal,
							  LastPurchasePrice,
							  TotalTax
								)
					SELECT  PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,SUM(RequestedQuantity),ApprovedQuantity,SUM(ReceivedQuantity),Remarks,UnitPrice,1 ,StockInHand,[dbo].[FN_GetPOwiseAdditionalChargesTotal](@PoHeaderID) , dbo.FN_GetLastGRNPrice(@LocationID,@StockItemID),Tax
					FROM @tblRequestHeader WHERE PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID
					GROUP BY PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,Remarks,UnitPrice,ApprovedQuantity,StockInHand,Tax

					END 

				ELSE 
				BEGIN

					INSERT INTO @tblRequestHeaderW
							( 
							  PoDetailID ,
							  PoHeaderID ,
							  StockItemID ,
							  StockItemCode ,
							  ItemName ,
							  UnitCode ,
							  UnitName ,
							  RequestedQuantity ,
							  ApprovedQuantity ,
							  ReceivedQuantity ,
							  Remarks ,
							  UnitPrice ,
							  ISMrn,
							  StockInHand,
							  AdditonalChargesTotal,
							  LastPurchasePrice,
							  TotalTax
							)

					SELECT  PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,SUM(RequestedQuantity),ApprovedQuantity,SUM(ReceivedQuantity),Remarks,UnitPrice,0 ,StockInHand,[dbo].[FN_GetPOwiseAdditionalChargesTotal](@PoHeaderID) , dbo.FN_GetLastGRNPrice(@LocationID,@StockItemID),Tax
					FROM @tblRequestHeader WHERE PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID
					GROUP BY PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,Remarks,UnitPrice,ApprovedQuantity,StockInHand,Tax
				END
		
				DELETE FROM @tblRequestHeader 
				WHERE  PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID 

			END 

			SELECT * FROM @tblRequestHeaderW

		END

END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
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

