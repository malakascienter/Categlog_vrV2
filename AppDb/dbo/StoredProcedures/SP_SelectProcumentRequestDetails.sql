CREATE PROCEDURE [dbo].[SP_SelectProcumentRequestDetails]
@ProcumentId AS INT,
@PropertyID AS INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT P.CompanyID , Q.ProcurementID,P.DocumentNo,L.Name AS Location,P.LocationID AS LocationId,GeneralDescription AS GeneralDescription,'' AS EvaluationCriteriaID,
	P.ItemName AS ItemName,P.ItemId AS ItemId,U.Name AS Unit,0 AS UnitId,P.Quantity, Q.SupplierID,S.Name AS SupplierName,Q.TaxGroupId AS TaxGroupId,TG.Name AS TaxGroupName,
	Q.Price AS UnitPrice,Q.ID AS UniqueId,Q.UserID AS UserId,q.QuotationFile,Q.StatusID AS Status,SQS.Name AS StatusName
	FROM [SupplierQuotation] Q INNER JOIN ProcurementRequest P ON Q.ProcurementID = P.ID
	LEFT JOIN Locations L ON P.LocationID = l.id
	LEFT JOIN Units U ON p.UnitID = U.Id 
	INNER JOIN Suppliers S ON S.Id = q.SupplierID
	LEFT join TaxGroups TG ON Q.TaxGroupId = TG.TaxGroupId
	INNER JOIN SupplierQuotationStatus SQS ON SQS.ID = Q.StatusID
	WHERE ProcurementID = @ProcumentId
	 
END

GO

