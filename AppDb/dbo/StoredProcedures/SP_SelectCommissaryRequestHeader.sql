CREATE PROCEDURE [dbo].[SP_SelectCommissaryRequestHeader]
AS
BEGIN
    SELECT 
        h.ID,
        h.PropertyID,
        h.RequestedLocationID,
		rl.Name AS RequestedLocationName,
        h.ProductionLocationID,
		pl.Name AS ProductionLocationName,
        h.TxnNo,
        h.TaxnDate,
        h.RequestedDate,
        h.UserID,
        h.Remarks,
        h.IsApproved,
        h.Status,
        h.IsSPOBased
       
    FROM 
        CommiRequestHeader h INNER JOIN Locations rl ON h.RequestedLocationID=rl.Id INNER JOIN Locations pl ON h.ProductionLocationID=pl.Id;
END

GO

