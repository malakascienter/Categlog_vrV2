-- exec Rpt_Requisition_TeaAvenue 14,14
CREATE PROCEDURE [dbo].[Rpt_Requisition_TeaAvenue]
	@HeaderID  INT,
	@TransactionTypeId INT
AS
BEGIN
	 SET NOCOUNT ON;
	 DECLARE @ApprovedUserName VARCHAR(MAX)
	
IF( @TransactionTypeId = 1 )
BEGIN


SELECT @ApprovedUserName= STUFF((
		SELECT DISTINCT ' | ' + ISNULL(CU.UserName,'')
		FROM RequestHeaders PH
		INNER JOIN ApprovalLogs AP ON PH.Id = AP.TransactionHeaderID
		INNER JOIN CentralUsers CU ON CU.Id = AP.ApprovalUserID
		WHERE PH.Id = @HeaderID AND 
		AP.IsComplete=1 AND AP.TransactionID=1
		FOR XML PATH('')), 1, 1, '') 

 SELECT  SH.StockItemCode ,
             SH.Name ,
	 		 CAST(CONVERT(VARCHAR, CAST(D.UnitPrice AS MONEY), 1) AS VARCHAR) AS UnitPrice  ,
             CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(D.RequestedQuantity AS MONEY), 1) AS VARCHAR)
	 	     ELSE  CAST(CONVERT(VARCHAR, CAST(D.ApprovedQuantity AS MONEY), 1) AS VARCHAR) END  AS Quantity ,
            CONVERT(MONEY, CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.RequestedQuantity ) AS MONEY), 1) AS VARCHAR) ELSE CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.ApprovedQuantity ) AS MONEY), 1) AS VARCHAR)  END ) AS GrossAmmount ,
			 CONVERT(MONEY,  CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.RequestedQuantity ) AS MONEY), 1) AS VARCHAR) ELSE CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.ApprovedQuantity ) AS MONEY), 1) AS VARCHAR)  END) AS Amount ,
             u.Name AS 'UnitName',
	 		 D.Remarks,
			 SD.QuantityInHand AS CurrentStockBalance,
			 Companies.Telephone1, 
			 Companies.Telephone2, 
			 Companies.FaxNo, 
			 Companies.Email, 
			 Companies.TaxRegistrationNumber1,
			 Companies.Name AS company,
			 CONCAT(Companies.Address1,',',Companies.Address2,',',Companies.Address3) AS CompanyAddress,
			 R.DocumentNo,
			 R.RequestDate,
			 R.Remarks AS HeaderRemark,
			 DP.Name AS DepartmentName,
			 R.DeliveryDate,
			 CU.UserName AS RequestBy,
			 (SELECT Name FROM Locations WHERE Id = R.TransferLocation) AS TransferLocationName,
			  (SELECT Name FROM Locations WHERE Id = R.LocationID) AS LocationName
			  , CASE WHEN R.IsApproved = 1 THEN 'APPROVED' ELSE 'PENDING' END AS DocStatus
			   , @ApprovedUserName ApprovedUserName
     FROM    dbo.RequestDetails AS D
             INNER JOIN dbo.RequestHeaders R ON R.Id = D.RequestHeaderID
             INNER JOIN dbo.StockItemHeaders AS SH ON D.StockItemID = SH.Id
             INNER JOIN dbo.StockItemDetails AS SD ON SH.Id = SD.StockItemHeaderID
                                                   AND SH.CompanyId = SD.CompanyID
                                                   AND R.LocationID = SD.LocationID
             INNER JOIN dbo.Units AS u ON d.UnitID = u.Id
			 INNER JOIN Departments DP ON R.DepartmentID = DP.Id AND DP.PropertyID = R.PropertyID
			 INNER JOIN Companies ON R.PropertyID = Companies.CompanyID
			 INNER JOIN CentralAccessDB..Central_Users CU ON R.UserProfileID = CU.Id
     WHERE   D.RequestHeaderID = @HeaderID 

END
ELSE IF ( @TransactionTypeId = 8 )
BEGIN

 SELECT  SH.StockItemCode ,
             SH.Name ,
	 		 CAST(CONVERT(VARCHAR, CAST(D.UnitPrice AS MONEY), 1) AS VARCHAR) AS UnitPrice  ,
             CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(D.RequestedQuantity AS MONEY), 1) AS VARCHAR)
	 	     ELSE  CAST(CONVERT(VARCHAR, CAST(D.ApprovedQuantity AS MONEY), 1) AS VARCHAR) END  AS Quantity ,
             CONVERT(MONEY, CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.RequestedQuantity ) AS MONEY), 1) AS VARCHAR) ELSE CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.ApprovedQuantity ) AS MONEY), 1) AS VARCHAR)  END ) AS GrossAmmount ,
			 CONVERT(MONEY,  CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.RequestedQuantity ) AS MONEY), 1) AS VARCHAR) ELSE CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.ApprovedQuantity ) AS MONEY), 1) AS VARCHAR)  END) AS Amount ,
             u.Name AS 'UnitName',
	 		 D.Remarks,
			 SD.QuantityInHand AS CurrentStockBalance,
			 Companies.Telephone1, 
			 Companies.Telephone2, 
			 Companies.FaxNo, 
			 Companies.Email, 
			 Companies.TaxRegistrationNumber1,
			 Companies.Name AS company,
			 CONCAT(Companies.Address1,',',Companies.Address2,',',Companies.Address3) AS CompanyAddress,
			 R.DocumentNo,
			 R.RequestDate,
			 R.Remarks AS HeaderRemark,
			 '' AS DepartmentName,
			 R.DeliveryDate,
			 CU.UserName AS RequestBy,
			 (SELECT Name FROM Locations WHERE Id = R.TransferLocation) AS TransferLocationName,
			  (SELECT Name FROM Locations WHERE Id = R.LocationID) AS LocationName
			  , CASE WHEN R.IsApproved = 1 THEN 'APPROVED' ELSE 'PENDING' END AS DocStatus
     FROM    dbo.RequestDetails AS D
             INNER JOIN dbo.RequestHeaders R ON R.Id = D.RequestHeaderID
             INNER JOIN dbo.StockItemHeaders AS SH ON D.StockItemID = SH.Id
             INNER JOIN dbo.StockItemDetails AS SD ON SH.Id = SD.StockItemHeaderID
                                                   AND SH.CompanyId = SD.CompanyID
                                                   AND R.LocationID = SD.LocationID
             INNER JOIN dbo.Units AS u ON d.UnitID = u.Id
			 --INNER JOIN Departments DP ON R.DepartmentID = DP.Id AND DP.PropertyID = R.PropertyID
			 INNER JOIN Companies ON R.PropertyID = Companies.CompanyID
			 INNER JOIN CentralAccessDB..Central_Users CU ON R.UserProfileID = CU.Id
     WHERE   D.RequestHeaderID = @HeaderID 

END
ELSE IF ( @TransactionTypeId = 11 )
BEGIN

---Added by Isuru 2023-08-31
DECLARE @INDocumentNo VARCHAR(20), @ApproveDate DATE, @ApproveTime TIME

SELECT @INDocumentNo = SH.DocumentNo
FROM RequestHeaders RH
INNER JOIN StockTransactionHeaders SH ON RH.Id = SH.ReferenceID
WHERE RH.Id = @HeaderID AND SH.TransactionType='IN'

SELECT TOP(1) @ApproveDate=convert(date,AP.ApprovalDate)
FROM REQUESTHEADERS RH
INNER JOIN APPROVALLOGS AP ON RH.ID = AP.TRANSACTIONHEADERID
WHERE RH.ID=2138 AND AP.TransactionID=11
ORDER BY AP.ApprovalDate DESC



SELECT TOP(1) @ApproveTime= convert(time,AP.ApprovalDate)
FROM REQUESTHEADERS RH
INNER JOIN APPROVALLOGS AP ON RH.ID = AP.TRANSACTIONHEADERID
WHERE RH.ID=2138 AND AP.TransactionID=11
ORDER BY AP.ApprovalDate DESC



--end

 SELECT  SH.StockItemCode ,
             SH.Name ,
	 		 CAST(CONVERT(VARCHAR, CAST(D.UnitPrice AS MONEY), 1) AS VARCHAR) AS UnitPrice  ,
             CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(D.RequestedQuantity AS MONEY), 1) AS VARCHAR)
	 	     ELSE  CAST(CONVERT(VARCHAR, CAST(D.ApprovedQuantity AS MONEY), 1) AS VARCHAR) END  AS Quantity ,
             CONVERT(MONEY, CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.RequestedQuantity ) AS MONEY), 1) AS VARCHAR) ELSE CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.ApprovedQuantity ) AS MONEY), 1) AS VARCHAR)  END ) AS GrossAmmount ,
			 CONVERT(MONEY,  CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.RequestedQuantity ) AS MONEY), 1) AS VARCHAR) ELSE CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.ApprovedQuantity ) AS MONEY), 1) AS VARCHAR)  END) AS Amount ,
             u.Name AS 'UnitName',
	 		 D.Remarks,
			 SD.QuantityInHand AS CurrentStockBalance,
			 Companies.Telephone1, 
			 Companies.Telephone2, 
			 Companies.FaxNo, 
			 Companies.Email, 
			 Companies.TaxRegistrationNumber1,
			 Companies.Name AS company,
			 CONCAT(Companies.Address1,',',Companies.Address2,',',Companies.Address3) AS CompanyAddress,
			 R.DocumentNo,
			 R.RequestDate,
			 R.Remarks AS HeaderRemark,
			  DP.Name AS DepartmentName,
			 R.DeliveryDate,
			 CU.UserName AS RequestBy,
			 (SELECT Name FROM Locations WHERE Id = R.TransferLocation) AS TransferLocationName,
			  (SELECT Name FROM Locations WHERE Id = R.LocationID) AS LocationName
			  ,ISNULL(@INDocumentNo,'Pending') AS INDocumentNo
			  , CASE WHEN R.IsApproved = 1 THEN 'APPROVED' ELSE 'PENDING' END AS DocStatus
			  ,@ApproveDate ApproveDate
			  ,@ApproveTime ApproveTime
     FROM    dbo.RequestDetails AS D
             INNER JOIN dbo.RequestHeaders R ON R.Id = D.RequestHeaderID
             INNER JOIN dbo.StockItemHeaders AS SH ON D.StockItemID = SH.Id
             INNER JOIN dbo.StockItemDetails AS SD ON SH.Id = SD.StockItemHeaderID
                                                   AND SH.CompanyId = SD.CompanyID
                                                   AND R.LocationID = SD.LocationID
             INNER JOIN dbo.Units AS u ON d.UnitID = u.Id
			 INNER JOIN Departments DP ON R.DepartmentID = DP.Id AND DP.PropertyID = R.PropertyID
			 INNER JOIN Companies ON R.PropertyID = Companies.CompanyID
			 INNER JOIN CentralAccessDB..Central_Users CU ON R.UserProfileID = CU.Id
     WHERE   D.RequestHeaderID = @HeaderID 

END
ELSE IF ( @TransactionTypeId = 14 )
BEGIN
 SELECT  SH.StockItemCode ,
             SH.Name ,
	 		 CAST(CONVERT(VARCHAR, CAST(D.UnitPrice AS MONEY), 1) AS VARCHAR) AS UnitPrice  ,
             CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(D.RequestedQuantity AS MONEY), 1) AS VARCHAR)
	 	     ELSE  CAST(CONVERT(VARCHAR, CAST(D.ApprovedQuantity AS MONEY), 1) AS VARCHAR) END  AS Quantity ,
             CONVERT(MONEY, CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.RequestedQuantity ) AS MONEY), 1) AS VARCHAR) ELSE CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.ApprovedQuantity ) AS MONEY), 1) AS VARCHAR)  END ) AS GrossAmmount ,
			 CONVERT(MONEY,  CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.RequestedQuantity ) AS MONEY), 1) AS VARCHAR) ELSE CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
              * D.ApprovedQuantity ) AS MONEY), 1) AS VARCHAR)  END) AS Amount ,
             u.Name AS 'UnitName',
	 		 D.Remarks,
			 SD.QuantityInHand AS CurrentStockBalance,
			 Companies.Telephone1, 
			 Companies.Telephone2, 
			 Companies.FaxNo, 
			 Companies.Email, 
			 Companies.TaxRegistrationNumber1,
			 Companies.Name AS company,
			 CONCAT(Companies.Address1,',',Companies.Address2,',',Companies.Address3) AS CompanyAddress,
			 R.DocumentNo,
			 R.RequestDate,
			 R.Remarks AS HeaderRemark,
			 '' AS DepartmentName,
			 R.DeliveryDate,
			 CU.UserName AS RequestBy,
			 (SELECT Name FROM Locations WHERE Id = R.TransferLocation) AS TransferLocationName,
			  (SELECT Name FROM Locations WHERE Id = R.LocationID) AS LocationName
			 , CASE WHEN R.IsApproved = 1 THEN 'APPROVED' ELSE 'PENDING' END AS DocStatus
			 ,DR.Name DamageCategory
     FROM    dbo.RequestDetails AS D
             INNER JOIN dbo.RequestHeaders R ON R.Id = D.RequestHeaderID
             INNER JOIN dbo.StockItemHeaders AS SH ON D.StockItemID = SH.Id
             INNER JOIN dbo.StockItemDetails AS SD ON SH.Id = SD.StockItemHeaderID
                                                   AND SH.CompanyId = SD.CompanyID
                                                   AND R.LocationID = SD.LocationID
             INNER JOIN dbo.Units AS u ON d.UnitID = u.Id
			 --INNER JOIN Departments DP ON R.DepartmentID = DP.Id AND DP.PropertyID = R.PropertyID
			 INNER JOIN Companies ON R.PropertyID = Companies.CompanyID
			 INNER JOIN CentralAccessDB..Central_Users CU ON R.UserProfileID = CU.Id
			 INNER JOIN DamageRequestCategories DR ON DR.ID  = R.DamageCategoryID
     WHERE   D.RequestHeaderID = @HeaderID 

END


END

GO

