CREATE PROCEDURE [dbo].[SP_Recall_CreditRequest_Header] --1011
	@headerID int
AS
BEGIN
	--SELECT L.Name AS LocationName,  OH.DocumentNo, OH.DocumentDate, OH.Id ,OH.TransType ,
	SELECT  DISTINCT CA.CRNumber as DocumentNO  , CA.CreatedDate AS 'DocumentDate',CA.Id ,tt.Name,
	CASE tt.Code
				 WHEN 'CR' THEN 'CR Number'
				-- WHEN 'RI' THEN 'IR Number'
				-- WHEN 'RD' THEN 'DR Number'
				-- WHEN 'RT' THEN 'TO Number'
				-- WHEN 'MR' THEN 'MR Number'
			 END
			 AS DocumentType
	FROM CreditApprovals CA INNER JOIN ApprovalLogs AL ON  CA.Id=Al.TransactionHeaderID 
	INNER JOIN TransactionTypes TT ON AL.TransactionID = TT.Id 
	
	--INNER JOIN dbo.Departments AS D ON RH.DepartmentID = D.Id
	--INNER JOIN dbo.Locations AS TL ON RH.TransferLocation = TL.Id
	--INNER JOIN dbo.UserMasters AS U ON RH.UserProfileID = U.Id
	WHERE CA.Id = @headerID
END
    
	--SELECT * FROM TransactionTypes


	
	

--SELECT * FROM OrderHeaders 

GO

