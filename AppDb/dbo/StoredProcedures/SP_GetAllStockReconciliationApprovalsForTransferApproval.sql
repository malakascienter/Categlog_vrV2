-- =============================================
-- Author:		Vinuki
-- Create date: 28.06.2024
-- Description:	<Description,,>
-- =============================================

--SP_GetAllStockReconciliationApprovalsForTransferApproval 1,4,8210,4182
CREATE PROCEDURE [dbo].[SP_GetAllStockReconciliationApprovalsForTransferApproval] (@CompanyId int,@LocationID int, @UserProfileID int , @TransferUser int)

AS
BEGIN
------------------------------------------------------------------------
BEGIN TRY 
	DECLARE @IsCentralLogn BIT
	declare @RowCount INT = 1, @TotalRows INT, @TempDocNo varchar(255) 

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

	SELECT GA.Id AS HeaderId,U.Username,GA.UserProfileId,GA.StockTransactionHeaderID, L.Name AS Location,GA.CreatedDate,GA.ApprovalDocNo,GA.ReferenceNo,AT.ApprovalTypeName,
	GA.seqid, DENSE_RANK() OVER (PARTITION BY GA.ApprovalDocNo ORDER BY GA.seqid) AS RowNum,
	GA.TransactionType,GA.Status,l.Id as LocationID,
	GA.ApprovallevelId
	 INTO #TempGrnApprovalTable FROM GRNApprovalLog GA
	INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
	INNER JOIN Locations L ON L.Id = GA.LocationId
	LEFT JOIN ApprovalTypes AT ON AT.Id = GA.ApprovallevelId
	WHERE GA.CompanyId = CASE WHEN @CompanyId = -999 THEN GA.CompanyId ELSE @CompanyId END
	AND l.Id = CASE WHEN @LocationID IS NULL THEN l.Id ELSE (CASE WHEN @LocationID =-999 THEN l.Id ELSE @LocationID END) END 
	AND GA.TransactionType = 'AA' 
	AND GA.Status = 'P'
	ORDER BY GA.Id DESC

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
	AND UserProfileId = @UserProfileID
	AND TransactionType = 'AA'
	AND Status = 'P'
	AND LocationID = CASE WHEN @LocationID IS NULL THEN LocationID ELSE (CASE WHEN @LocationID =-999 THEN LocationID ELSE @LocationID END) END 
	order by HeaderId

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

