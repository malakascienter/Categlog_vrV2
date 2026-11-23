-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-01-06
-- Description:	table value function to get last completed approval details
-- =============================================
CREATE FUNCTION dbo.fn_GetLastCompletedApproval
(
    @TransactionHeaderID INT,
    @TransactionID INT,
    @CompanyID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT
        CU.UserName AS ApprovedUserName,
        AP.ApprovalDate,
        AP.TransactionHeaderID,
        AP.TransactionID
    FROM ApprovalLogs AP
    INNER JOIN CentralUsers CU
        ON AP.ApprovalUserID = CU.Id
    WHERE AP.TransactionID = @TransactionID
      AND AP.TransactionHeaderID = @TransactionHeaderID
      AND AP.IsComplete = 1
      AND AP.SeqID = (
            SELECT MAX(SeqID)
            FROM ApprovalLogs
            WHERE TransactionID = @TransactionID
              AND TransactionHeaderID = @TransactionHeaderID
              AND IsComplete = 1
      )
      AND
      (
            @TransactionID NOT IN (1, 2)

            OR (
                @TransactionID = 2
                AND EXISTS (
                    SELECT 1
                    FROM POHEADERS PH
                    WHERE PH.Id = @TransactionHeaderID
                      AND PH.IsApproved = 1
                )
            )

            OR (
                @TransactionID = 1
                AND EXISTS (
                    SELECT 1
                    FROM RequestHeaders RH
                    WHERE RH.Id = @TransactionHeaderID
                      AND RH.IsApproved = 1
                )
            )
      )
);

GO

