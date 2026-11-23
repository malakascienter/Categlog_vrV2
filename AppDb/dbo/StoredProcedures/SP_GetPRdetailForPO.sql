--SP_GetPRdetailForPO 13,15
CREATE  PROCEDURE [dbo].[SP_GetPRdetailForPO]
	-- Add the parameters for the stored procedure here
	@POheaderID INT,
	@PODetailID INT 
AS
BEGIN
	SELECT		
			d.Id AS PoDetailID,
			d.PoHeaderID, 
			PWR.StockItemID,  
			i.StockItemID AS StockItemCode,			
			ih.Name AS ItemName,
			d.UnitID AS UnitCode, 
	        u.Name  AS UnitName,
			d.RequestedQuantity, 
			ISNULL(PWR.ApprovedQty,0) ApprovedQuantity, 
			ReceivedQuantity, 
			d.Remarks,
			d.UnitPrice,
			RH.flag,
			PWR.RequestHeaderID,
			PWR.RequestionQty,
			ISNULL(MRN.DocNo,'PR') AS DocNo
		FROM         dbo.PoDetails d
			inner join	dbo.PoHeaders h on h.Id = d.PoHeaderID
			inner join	dbo.StockItemDetails i 
			on i.PropertyID = h.PropertyID and h.LocationID = i.LocationID and i.StockItemHeaderID=d.StockItemID
			inner join dbo.StockItemHeaders ih
			on ih.Id = i.StockItemHeaderID and ih.CompanyId = i.CompanyID
			inner join dbo.Units u on u.Id=d.UnitID 
		    LEFT  JOIN dbo.PoWisePRs AS PWR ON PWR.PoHeaderID = h.Id AND d.StockItemID=PWR.StockItemID
			LEFT  JOIN dbo.RequestHeaders RH ON RH.Id=PWR.RequestHeaderID LEFT JOIN dbo.MRNRegistries AS MRN ON MRN.RequestionID=PWR.RequestHeaderID		
			

		WHERE     (d.PoHeaderID = @POheaderID AND d.Id=@PODetailID ) 
END

GO

