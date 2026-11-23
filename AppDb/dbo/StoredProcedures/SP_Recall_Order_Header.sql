CREATE PROCEDURE [dbo].[SP_Recall_Order_Header] --1011
	@headerID int
AS
BEGIN
	SELECT L.Name AS LocationName,  OH.DocumentNo, OH.DocumentDate AS RequestDate, OH.Id ,OH.TransType ,
			CASE OH.TransType
				 WHEN 'OR' THEN 'Sales Order No'
				-- WHEN 'RI' THEN 'IR Number'
				-- WHEN 'RD' THEN 'DR Number'
				-- WHEN 'RT' THEN 'TO Number'
				-- WHEN 'MR' THEN 'MR Number'
			 END
			 AS DocumentType
	FROM dbo.OrderHeaders  AS OH
	INNER  JOIN dbo.Locations AS L ON OH.LocationID = L.Id
	--INNER JOIN dbo.Departments AS D ON RH.DepartmentID = D.Id
	--INNER JOIN dbo.Locations AS TL ON RH.TransferLocation = TL.Id
	--INNER JOIN dbo.UserMasters AS U ON RH.UserProfileID = U.Id
	INNER JOIN TransactionTypes TT ON TT.Code =OH.TransType
	WHERE OH.Id = @headerID
END
    


	--SELECT * FROM Locations



--SELECT * FROM OrderHeaders 

GO

