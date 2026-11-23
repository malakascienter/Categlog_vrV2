-- [dbo].[SelectRequestTemplteDetals] 1042,1,null,1,'Y'

CREATE Procedure [dbo].[SelectRequestTemplteDetals] (@TemplateHeaderID INT, @location INT = -999, @TxnDate date=null, @SuppId INT = -999, @IsPO CHAR(1)= '')
AS
BEGIN

	SET @TxnDate = CASE WHEN @TxnDate is null then getdate() else @TxnDate end 
IF(@IsPO = 'Y')
	BEGIN
	IF @location = -999
	BEGIN
		SELECT	DISTINCT	D.TemplateHeaderID Id,TH.Name TemplateName,d.StockItemHeaderID StockItemID,H.Name StockName,C.id CategoryID,C.Name CategoryName,d.UnitID, U.Name UnitName,1 MasterUnitID,D.Qty Quantity,TH.IsActive IsActive, SW.CostPrice,H.StockItemCode
		FROM		RequestTemplateDetails D
		INNER JOIN  RequestTemplateheader TH ON TH.TemplateHeaderID = D.TemplateHeaderID
		INNER JOIN	StockItemHeaders H ON	d.StockItemHeaderID = h.Id 
		INNER JOIN	Units U on u.Id = D.UnitId 
		INNER JOIN	Categories C on C.Id = H.CategoryId 
		INNER JOIN  SupplierWiseItemDetails SW ON SW.CompanyId = H.CompanyId AND H.Id = SW.StockItemID AND SW.SupplierID = @SuppId AND SW.PurchaseUnitID = D.UnitID
		WHERE		D.TemplateHeaderID=@TemplateHeaderID
		ORDER BY H.Name
		
	END
	ELSE
	BEGIN

		SELECT	DISTINCT D.TemplateHeaderID Id,TH.Name TemplateName,d.StockItemHeaderID StockItemID,H.Name StockName,C.id CategoryID,C.Name CategoryName,d.UnitID, U.Name UnitName,1 MasterUnitID,D.Qty Quantity,TH.IsActive IsActive,  [dbo].[GetBalance](@TxnDate ,h.Id,@location,0,0) QuantityInHand, sd.AveragePrice AS UnitPrice, SW.CostPrice,H.StockItemCode
		FROM		RequestTemplateDetails D
		INNER JOIN  RequestTemplateheader TH ON TH.TemplateHeaderID = D.TemplateHeaderID
		INNER JOIN	StockItemHeaders H ON	d.StockItemHeaderID = h.Id 
		INNER JOIN	Units U on u.Id = D.UnitId 
		INNER JOIN	Categories C on C.Id = H.CategoryId 
		INNER JOIN  dbo.StockItemDetails SD ON sd.StockItemHeaderID = h.Id
		INNER JOIN  SupplierWiseItemDetails SW ON SW.CompanyId = H.CompanyId AND H.Id = SW.StockItemID AND SW.SupplierID = @SuppId AND SW.PurchaseUnitID = D.UnitID 
		AND SW.LocationId = @location
		WHERE		D.TemplateHeaderID=@TemplateHeaderID AND SD.LocationID =@location
		ORDER BY H.Name
		
	END
	END
ELSE
	BEGIN
	IF @location = -999
	BEGIN
		SELECT		D.TemplateHeaderID Id,TH.Name TemplateName,d.StockItemHeaderID StockItemID,H.Name StockName,C.id CategoryID,C.Name CategoryName,d.UnitID, U.Name UnitName,1 MasterUnitID,D.Qty Quantity,TH.IsActive IsActive
		,TransactionTypeCode TransactionType,LocationList MultipleLocationID
		FROM		RequestTemplateDetails D WITH (NOLOCK)
		INNER JOIN  RequestTemplateheader TH WITH (NOLOCK) ON TH.TemplateHeaderID = D.TemplateHeaderID
		INNER JOIN	StockItemHeaders H WITH (NOLOCK) ON	d.StockItemHeaderID = h.Id 
		INNER JOIN	Units U WITH (NOLOCK) on u.Id = D.UnitId 
		INNER JOIN	Categories C WITH (NOLOCK) on C.Id = H.CategoryId 		
		WHERE		D.TemplateHeaderID=@TemplateHeaderID
		ORDER BY H.Name
		
	END
	ELSE
	BEGIN
		SELECT		D.TemplateHeaderID Id,TH.Name TemplateName,d.StockItemHeaderID StockItemID,H.Name StockName,C.id CategoryID,C.Name CategoryName,d.UnitID, U.Name UnitName,1 MasterUnitID,D.Qty Quantity,TH.IsActive IsActive,  [dbo].[GetBalance](@TxnDate ,h.Id,@location,0,0) QuantityInHand, sd.AveragePrice AS UnitPrice, H.StockItemCode
		FROM		RequestTemplateDetails D
		INNER JOIN  RequestTemplateheader TH ON TH.TemplateHeaderID = D.TemplateHeaderID
		INNER JOIN	StockItemHeaders H ON	d.StockItemHeaderID = h.Id 
		INNER JOIN	Units U on u.Id = D.UnitId 
		INNER JOIN	Categories C on C.Id = H.CategoryId 
		INNER JOIN  dbo.StockItemDetails SD ON sd.StockItemHeaderID = h.Id		
		WHERE		D.TemplateHeaderID=@TemplateHeaderID AND SD.LocationID =@location
		ORDER BY H.Name
		
	END
	END

	

END

GO

