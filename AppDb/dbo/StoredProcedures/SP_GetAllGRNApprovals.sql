--[dbo].[SP_GetAllGRNApprovals] 1,1,4168
CREATE PROCEDURE [dbo].[SP_GetAllGRNApprovals] (@CompanyId int,@paramId INT, @UserID INT  = 0-- added by vinuki 14.06.2024
)
AS
BEGIN
------------------------------------------------------------------------
BEGIN TRY 
	DECLARE @IsCentralLogn BIT
	SELECT @IsCentralLogn = IsCentralLogin FROM Companies WHERE CompanyID = CASE WHEN @CompanyId = -999 THEN CompanyID  ELSE @CompanyId END

	CREATE TABLE #TempApprovalData(Id INT, UserName NVARCHAR(3000))
	IF(@IsCentralLogn = 1)
	BEGIN
		INSERT INTO #TempApprovalData
		SELECT Id,Username 
		FROM [dbo].[CentralUsers]
	END
	ELSE 
	BEGIN
		INSERT INTO #TempApprovalData
		SELECT Id,Username 
		FROM UserMasters
	END

	IF(@paramId = 1)
	BEGIN
		--SELECT GA.Id AS HeaderId,U.Username,L.Name AS Location,PO.PoNo AS ReferenceNo,S.Name AS Supplier,GA.ApprovalDocNo,GA.ReferenceNo  AS SuppInv,
		--S.Id AS SupplierID
		--FROM GRNApprovalLog GA
		--INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
		--INNER JOIN Locations L ON L.Id = GA.LocationId
		--INNER JOIN Suppliers S ON S.Id = GA.SupplierId
		--LEFT JOIN PoHeaders PO ON PO.Id = GA.ReferenceId
		--WHERE GA.CompanyId = CASE WHEN @CompanyId = -999 THEN GA.CompanyId ELSE @CompanyId END
		--AND TransactionType = 'GR' AND Status = 'P'
		--ORDER BY GA.Id DESC -- commented by vinuki 14.06.2024
	
		-- ADDED BY VINUKI 14.06.2024 FOR GRN APPROVAL 
	SELECT GA.Id AS HeaderId,U.Username,GA.UserProfileId,GA.StockTransactionHeaderID, L.Name AS Location,GA.CreatedDate,GA.ApprovalDocNo,GA.ReferenceNo as SuppInv,AT.ApprovalTypeName,
	GA.seqid,  DENSE_RANK() OVER (PARTITION BY GA.ApprovalDocNo ORDER BY GA.seqid) AS RowNum,
	
	GA.TransactionType,GA.Status,l.Id as LocationID,
	GA.ApprovallevelId,
	CASE WHEN GA.ReferenceNo = 'FreeQty' THEN (SELECT GAT.ApprovalDocNo FROM GRNApprovalLog  GAT WHERE GAT.Id = GA.ReferenceId  ) ELSE PO.PoNo END AS ReferenceNo,
	s.Name as Supplier,
		(
			SELECT TOP 1 
			ID 
			FROM Locations 
			WHERE ID = (ISNULL(CAST(GA.XMLDetails AS XML).value('(StockTransactionHeader/TransferLocationID/text())[1]', 'INT'),0))
		) 
		AS TransferLocationID, -- Added by Nivesh 2025-11-07 For Auto Transfer GRN
		(
			SELECT TOP 1 
			Name 
			FROM Locations 
			WHERE ID = (ISNULL(CAST(GA.XMLDetails AS XML).value('(StockTransactionHeader/TransferLocationID/text())[1]', 'INT'),0))
		) 
		AS TransferLocation -- Added by Nivesh 2025-11-07 For Auto Transfer GRN
		,GA.SupplierId SupplierID,
		CONVERT(VARCHAR(10), 
		CAST(
        CAST(GA.XMLDetails AS XML).value('(StockTransactionHeader/InvoiceDate/text())[1]', 'NVARCHAR(50)') 
			AS DATETIME), 
		101) AS SuppInvDate ---Added by Tharuka 2026-04-02 for get invoice date from xml---
		INTO #TempGrnApprovalTable
		FROM GRNApprovalLog GA
		INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
		INNER JOIN Locations L ON L.Id = GA.LocationId
		INNER JOIN Suppliers S ON S.Id = GA.SupplierId
		LEFT JOIN PoHeaders PO ON PO.Id = GA.ReferenceId
		LEFT JOIN ApprovalTypes AT ON AT.Id = GA.ApprovallevelId
		WHERE GA.CompanyId = CASE WHEN @CompanyId = -999 THEN GA.CompanyId ELSE @CompanyId END
		AND TransactionType = 'GR' AND Status = 'P'
		ORDER BY GA.Id DESC

	select * from
	#TempGrnApprovalTable
	where
	RowNum =1 
	AND UserProfileId = @UserID 
	AND TransactionType = 'GR'
	AND Status = 'P'
	order by HeaderId desc
	END

	IF(@paramId = 2)
	BEGIN
		--SELECT GA.Id AS HeaderId,U.Username,L.Name AS Location,SH.DocumentNo AS ReferenceNo,S.Name AS Supplier,GA.ApprovalDocNo,GA.ReferenceNo  AS SuppInv
		--FROM GRNApprovalLog GA
		--INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
		--INNER JOIN Locations L ON L.Id = GA.LocationId
		--INNER JOIN Suppliers S ON S.Id = GA.SupplierId
		--INNER JOIN StockTransactionHeaders SH ON SH.Id = GA.ReferenceId AND SH.TransactionType = 'GR'
		--WHERE GA.CompanyId = CASE WHEN @CompanyId = -999 THEN GA.CompanyId ELSE @CompanyId END
		--AND GA.TransactionType = 'SR' AND Status = 'P'
		--ORDER BY GA.Id DESC -- COMMENTED BY VINUKI 18.06.2024

			-- ADDED BY VINUKI 18.06.2024 FOR SRN APPROVAL 
	SELECT GA.Id AS HeaderId,U.Username,GA.UserProfileId,GA.StockTransactionHeaderID, L.Name AS Location,GA.CreatedDate,GA.ApprovalDocNo,GA.ReferenceNo as SuppInv,AT.ApprovalTypeName,
	GA.seqid,  DENSE_RANK() OVER (PARTITION BY GA.ApprovalDocNo ORDER BY GA.seqid) AS RowNum,
	
	GA.TransactionType,GA.Status,l.Id as LocationID,
	GA.ApprovallevelId, PO.PoNo AS ReferenceNo,s.Name as Supplier
	
		INTO #TempSRNApprovalTable
		FROM GRNApprovalLog GA
		INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
		INNER JOIN Locations L ON L.Id = GA.LocationId
		INNER JOIN Suppliers S ON S.Id = GA.SupplierId
		LEFT JOIN PoHeaders PO ON PO.Id = GA.ReferenceId
		LEFT JOIN ApprovalTypes AT ON AT.Id = GA.ApprovallevelId
		WHERE GA.CompanyId = CASE WHEN @CompanyId = -999 THEN GA.CompanyId ELSE @CompanyId END
		AND TransactionType = 'SR' AND Status = 'P'
		ORDER BY GA.Id DESC

	select * from
	#TempSRNApprovalTable
	where
	RowNum =1 
	AND UserProfileId = @UserID 
	AND TransactionType = 'SR'
	AND Status = 'P'
	order by HeaderId desc
	END
	



	--IF(@paramId = 3)
	--BEGIN
	--	SELECT GA.Id AS HeaderId,U.Username,L.Name AS Location,PO.PoNo AS ReferenceNo,S.Name AS Supplier
	--	FROM GRNApprovalLog GA
	--	INNER JOIN UserMasters U ON GA.CreatedUserId = U.Id
	--	INNER JOIN Locations L ON L.Id = GA.LocationId
	--	LEFT JOIN Suppliers S ON S.Id = GA.SupplierId
	--	LEFT JOIN PoHeaders PO ON PO.Id = GA.ReferenceId
	--	WHERE GA.CompanyId = @CompanyId AND TransactionType = 'IR' AND Status = 'P'
	--	ORDER BY GA.Id DESC
	--END
	
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
------------------------------------------------------------------------
END

GO

