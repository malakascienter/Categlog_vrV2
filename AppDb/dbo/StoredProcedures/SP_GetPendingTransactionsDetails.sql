-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 22 September 2023
-- Description:	Loading Pending Transaction Details
--- [dbo].[SP_GetPendingTransactionsDetails]  1,11,4168,21008
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetPendingTransactionsDetails]  
(
	@CompanyId	INT ,
	@TxnTypeId INT,
	@userProfileId INT,
	@HeaderId INT
)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @IsCentralLogin BIT

	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID =  @CompanyId

	DECLARE @UserTempTable TABLE(
	Id INT,
	FirstName NVARCHAR(300)
	)

	IF(@IsCentralLogin = 1)
	BEGIN
		INSERT INTO @UserTempTable
		SELECT Id,FullName
		FROM [dbo].[CentralUsers]
	END
	ELSE
	BEGIN
		INSERT INTO @UserTempTable
		SELECT Id, FirstName 
		FROM UserMasters
	END

	
    IF(@TxnTypeId IN(1,8,11,14))  ---RD,RP,RI,RT  Purchase Request, Damage Request Note,Transfer Request,Issue Request
	BEGIN
	SELECT ROUND(SUM(RD.RequestedQuantity* RD.UnitPrice),2) ValueOfRequest,RD.RequestedQuantity, RD.UnitPrice, U.Name AS UnitName, SID.Name AS ItemName, RD.StockItemID,
	  D.Name AS DepartmentName,
	dbo.GetStockInHand(RH.PropertyID,RH.LocationID,RD.StockItemID) AS StockInHand
	FROM dbo.RequestDetails AS RD 
	INNER JOIN dbo.StockItemHeaders AS SID ON RD.StockItemID = SID.Id
	INNER JOIN dbo.RequestHeaders RH ON RH.Id = RD.RequestHeaderID
	LEFT JOIN dbo.Departments D ON D.Id = RH.DepartmentID
	INNER JOIN Units U ON U.Id = RD.UnitID
	WHERE RD.RequestHeaderID = @headerID
	GROUP BY RD.RequestedQuantity, RD.UnitPrice, SID.Name , RD.StockItemID,D.Name,U.Name,RH.PropertyID,RH.LocationID,RD.StockItemID
	END

	IF(@TxnTypeId = 2) -- PO Purchase Order
	BEGIN
	SELECT ROUND(SUM(PD.RequestedQuantity * PD.UnitPrice),2) ValueOfRequest,PD.RequestedQuantity, PD.UnitPrice,U.Name UnitName,SH.Name ItemName,PD.StockItemID,ISNULL(null,'-') DepartmentName,
	dbo.GetStockInHand(PH.PropertyID,PH.LocationID,pd.StockItemID) AS StockInHand
	FROM PoHeaders PH
	INNER JOIN PoDetails PD ON PH.Id = PD.PoHeaderID
	INNER JOIN Locations L ON L.Id = PH.LocationID  
	INNER JOIN Units U ON U.Id = PD.UnitID 
	INNER JOIN StockItemHeaders SH ON SH.Id = PD.StockItemID
	WHERE PH.Id = @HeaderId 
	GROUP BY PD.RequestedQuantity, PD.UnitPrice,U.Name,SH.Name ,PD.StockItemID,PH.PropertyID,PH.LocationID,pd.StockItemID
	END

	IF(@TxnTypeId IN (3,4,5,6,7,9,10,12,13,15,20,68)) --Transactions in Stocktransactionheaders
	BEGIN

	DECLARE @XMLDetails XML,@iDocID INT,@LocationId INT,@ItemTotal DECIMAl(18,6),@StockItemID INT,@SupplierID INT, @TaxAmount DECIMAL(18,6),
		@Qty DECIMAL(18,6)

		SELECT @XMLDetails = CONVERT(XML,XMLDetails),@LocationId = LocationId
		FROM  GRNApprovalLog 
		WHERE Id = @HeaderId

		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

		SELECT * INTO #tempItemDetails FROM 
		OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2) 
		WITH (StockItemID INT, Quantity DECIMAL(18,6),UnitPrice DECIMAL(18,6),TxnUnitID INT, Remarks VARCHAR(MAX),DiscountValue DECIMAL(18,6),
		DiscountPercentage DECIMAL(18,6))



		SELECT ROUND(SUM(TP.Quantity*TP.UnitPrice), 2)   ValueOfRequest,TP.Quantity RequestedQuantity,TP.UnitPrice, U.Name UnitName,SH.Name ItemName,SH.Id StockItemID,ISNULL(null,'-') DepartmentName,
		dbo.GetStockInHand(@CompanyId,@LocationId,TP.StockItemID) AS StockInHand
		FROM #tempItemDetails TP
		INNER JOIN Units U ON U.Id = TP.TxnUnitID
		INNER JOIN StockItemHeaders SH ON SH.Id = TP.StockItemID
		GROUP BY TP.Quantity,TP.UnitPrice, U.Name,SH.Name ,SH.Id ,TP.StockItemID
		
	


	END
END

GO

