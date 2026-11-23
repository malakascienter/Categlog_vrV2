-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-09-19
-- Description:	Commisary Request report view
-- [dbo].[Rpt_PrintCommiRequest] 20
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_PrintCommiRequest] 
	@HeaderID  INT
	AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TransferRequestNo VARCHAR(200)

	SELECT @TransferRequestNo = RH.DocumentNo
	FROM CommiRequestHeader CH
	INNER JOIN CommiTransferHeader CT ON CH.ID = CT.ReferenceID
	INNER JOIN RequestHeaders RH ON RH.CommiRequestHeaderID = CT.ID
	WHERE CH.ID=@HeaderID





	SELECT CH.TxnNo,CH.TaxnDate,CH.RequestedDate DocumentRequestedDate, CU.UserName,LO.Name ProductionLocation, LO2.Name RequestedLocation,sh.Name ItemName,sh.StockItemCode,un.Name UnitName,CH.Remarks HeaderRemarks,CD.Remarks ItemRemakrs,CD.RequestedQTY,CD.RequestedDate ItemRequestedDate,
	DE.Name DeliverySchedule,cd.AdjustedQty,CD.ApprovedQTY,CO.Name Companyname, CONCAT(CO.Address1,',',CO.Address2,',',CO.Address3) AS CompanyAddress,ch.LogDate,ISNULL(@TransferRequestNo,'') TransferRequestNo
	FROM CommiRequestHeader CH
	INNER JOIN CommiRequestDetails CD ON CH.ID = CD.HeaderID
	INNER JOIN StockItemHeaders SH ON SH.Id = CD.StockItemID
	INNER JOIN Locations LO ON LO.ID = CH.ProductionLocationID
	INNER JOIN Locations LO2 ON LO2.Id = CH.RequestedLocationID
	INNER JOIN Companies CO ON CO.CompanyID = CH.PropertyID
	INNER JOIN CentralUsers CU ON CH.UserID = CU.Id
	INNER JOIN Units UN ON UN.Id = CD.UnitID
	INNER JOIN DeliverySchedule DE ON DE.ID = CD.DeliveryScheduleID
	WHERE CH.ID=@HeaderID
	ORDER BY SH.Name ASC
   
END

GO

