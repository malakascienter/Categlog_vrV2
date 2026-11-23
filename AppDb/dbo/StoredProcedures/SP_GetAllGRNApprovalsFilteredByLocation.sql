-- =============================================
-- Author:		Vinuki
-- Create date: 24.06.2024
-- Description:	Get All Details For GRNApproval WithLocation Filteration
--SP_GetAllGRNApprovalsFilteredByLocation 1,1,4168,4,4182
-- =============================================

CREATE PROCEDURE [dbo].[SP_GetAllGRNApprovalsFilteredByLocation] (@CompanyId int,@paramId INT, @UserID INT  = 0, @LocationID INT = 0 , @TransferUser int)
AS
BEGIN
------------------------------------------------------------------------
BEGIN TRY 
	DECLARE @IsCentralLogn BIT
	SELECT @IsCentralLogn = IsCentralLogin FROM Companies WHERE CompanyID = CASE WHEN @CompanyId = -999 THEN CompanyID  ELSE @CompanyId END
	declare @RowCount INT = 1, @TotalRows INT, @TempDocNo varchar(255) 


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
	SELECT GA.Id AS HeaderId,U.Username,GA.UserProfileId,GA.StockTransactionHeaderID, L.Name AS Location,GA.CreatedDate,GA.ApprovalDocNo,GA.ReferenceNo as SuppInv,AT.ApprovalTypeName,
	GA.seqid,  DENSE_RANK() OVER (PARTITION BY GA.ApprovalDocNo ORDER BY GA.seqid) AS RowNum,
	
	GA.TransactionType,GA.Status,l.Id as LocationID,
	GA.ApprovallevelId, PO.PoNo AS ReferenceNo,s.Name as Supplier
	
		INTO #TempGrnApprovalTable
		FROM GRNApprovalLog GA
		INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
		INNER JOIN Locations L ON L.Id = GA.LocationId
		INNER JOIN Suppliers S ON S.Id = GA.SupplierId
		LEFT JOIN PoHeaders PO ON PO.Id = GA.ReferenceId
		LEFT JOIN ApprovalTypes AT ON AT.Id = GA.ApprovallevelId
		WHERE GA.CompanyId = 1 
		AND TransactionType = 'GR' AND Status = 'P'
		ORDER BY GA.Id DESC

	--select * from
	--#TempGrnApprovalTable
	--where
	--RowNum =1 
	--and LocationID = 4
	--AND UserProfileId = @UserID 
	--AND TransactionType = 'GR'
	--AND Status = 'P'
	--order by HeaderId desc

	SELECT @TotalRows = COUNT(*) FROM #TempGrnApprovalTable;

			WHILE @RowCount <= @TotalRows
				begin
				select   @TempDocNo = ApprovalDocNo from #TempGrnApprovalTable
				SELECT @TempDocNo = ApprovalDocNo
			
				FROM (
				SELECT 
						ApprovalDocNo,
					ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM #TempGrnApprovalTable
    ) AS SubQuery
    WHERE RowNum = @RowCount;


		if exists (select * from GRNApprovalLog where UserProfileId = @TransferUser and ApprovalDocNo = @TempDocNo)
		begin
		
		
			delete from #TempGrnApprovalTable where  ApprovalDocNo = @TempDocNo
		end

		

		SET @RowCount = @RowCount + 1;
				end

	select * from
	#TempGrnApprovalTable
	where
	RowNum =1 
	and LocationID = 4
	AND UserProfileId = @UserID 
	AND TransactionType = 'GR'
	AND Status = 'P'
	order by HeaderId desc

	END
	


	IF(@paramId = 2)
	BEGIN

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

		
	SELECT @TotalRows = COUNT(*) FROM #TempSRNApprovalTable;

			WHILE @RowCount <= @TotalRows
				begin
				select   @TempDocNo = ApprovalDocNo from #TempSRNApprovalTable
				SELECT @TempDocNo = ApprovalDocNo
			
				FROM (
				SELECT 
						ApprovalDocNo,
					ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM #TempSRNApprovalTable
    ) AS SubQuery
    WHERE RowNum = @RowCount;


		if exists (select * from GRNApprovalLog where UserProfileId = @TransferUser and ApprovalDocNo = @TempDocNo)
		begin
		
		
			delete from #TempSRNApprovalTable where  ApprovalDocNo = @TempDocNo
		end

		

		SET @RowCount = @RowCount + 1;
				end


	select * from
	#TempSRNApprovalTable
	where
	RowNum =1 
	AND UserProfileId = @UserID
	and LocationID = @LocationID
	AND TransactionType = 'SR'
	AND Status = 'P'
	order by HeaderId desc
	END
	


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

