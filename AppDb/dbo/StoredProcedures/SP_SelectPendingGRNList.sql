-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-12-23
-- Description:	Loading Pending GRN Approval for Edit GRN

-- [dbo].[SP_SelectPendingGRNList] 1,1,1

-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectPendingGRNList]
	@PropertyID INT,
	@LocationID INT,
	@SupplierID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  ApprovalDocNo text,MAX(ID) id
	FROM GRNApprovalLog  G
	WHERE TransactionType = 'GR'
	AND IsComplete = 0
	AND Status = 'P'
	AND CompanyId = @PropertyID
	AND LocationId = @LocationID
	AND SupplierId = @SupplierID
	AND NOT EXISTS (
			SELECT 1
			FROM GRNApprovalLog X WITH (NOLOCK)
			WHERE X.ApprovalDocNo = G.ApprovalDocNo
			AND TransactionType = 'GR'
			  AND (
					X.Status <> 'P'
					OR X.IsComplete = 1
				  )
	  )
	GROUP BY ApprovalDocNo
    
END

GO

