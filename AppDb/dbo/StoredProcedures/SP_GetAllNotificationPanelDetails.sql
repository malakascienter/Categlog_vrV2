-- =============================================
-- Author:      Isuru Pramodya
-- Create date: 2025-08-20
-- Description: Retrieve all notification panel details with simplified error handling 
-- [dbo].[SP_GetAllNotificationPanelDetails] 4168,1

-- =============================================
CREATE PROCEDURE [dbo].[SP_GetAllNotificationPanelDetails]
@UserID INT,
@PropertyID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

    CREATE TABLE #TempPendingCount
    (Id INT IDENTITY(1,1),
    TransactionType VARCHAR(10),
	TransactionID INT,
    TransactionName VARCHAR(100),
    PendingCount INT)

    --added by isuru 2026-10-30: page access of the tiles (local login only - see HasAccess below)
    DECLARE @IsCentralLogin BIT, @GroupID INT
    SELECT TOP (1) @IsCentralLogin = ISNULL(IsCentralLogin, 0) FROM Companies WHERE CompanyID = @PropertyID
    SELECT @GroupID = UserGroupID FROM UserMasters WHERE Id = @UserID

    DECLARE @PRCount INT,
		    @POCount INT,
            @IssueRequestCount INT,
            @TransferRequestCount INT

    --Pending Request Headers 
    INSERT INTO #TempPendingCount (TransactionType,TransactionID,TransactionName,PendingCount)
    SELECT RequestType,TransactionTypeCode,TR.Name TransactionName,COUNT(RH.ID) Count
	FROM RequestHeaders RH
    INNER JOIN TransactionTypes TR ON RH.RequestType = TR.Code
	WHERE IsApproved = 1
	AND PropertyID = @PropertyID
	AND DocumentStatus = 'P'
    GROUP BY RequestType,TransactionTypeCode,TR.Name
    --End

    --Pending  Purchase Orders
    INSERT INTO #TempPendingCount (TransactionType,TransactionID,TransactionName,PendingCount)
    SELECT 'PO' RequestType,2 TransactionTypeCode,'Purchase Orders' TransactionName,COUNT(ID) Count
    FROM PoHeaders
    WHERE IsApproved=1
    AND DocumentStatus = 'P'
    AND PropertyID = @PropertyID

    --End

    -- Pending Transfer Ins
     INSERT INTO #TempPendingCount (TransactionType,TransactionID,TransactionName,PendingCount)
    SELECT 'TO' RequestType,5 TransactionTypeCode,'Transfer Outs' TransactionName,COUNT(ID) Count
    FROM StockTransactionHeaders
    WHERE TransactionType='TO'
    AND IsTrasferIn=0
    AND PropertyID= @PropertyID
    --End

    --added by isuru 2026-10-30
    --Reason: Pending supplier blacklists - same rows as the Supplier Blacklist Approval screen
    --        (SP_GetSupplierBlacklistApprovals, without its supplier / date filters)
    INSERT INTO #TempPendingCount (TransactionType,TransactionID,TransactionName,PendingCount)
    SELECT 'SGR' RequestType,TR.Id TransactionTypeCode,'Supplier Black List' TransactionName,
           (SELECT COUNT(SEH.ID)
            FROM dbo.SupplierEvaluationHeader SEH
            WHERE SEH.PropertyID = @PropertyID
            AND SEH.IsApproved = 1
            AND SEH.DocumentStatus = 'P'
            AND SEH.SupplierGrade = 'X'
            AND SEH.IsBlackListedApproved = 0) Count
    FROM TransactionTypes TR
    WHERE TR.Code = 'SGR'
    --End


       --SELECT *
       --FROM #TempPendingCount




        -- Main SELECT query
        SELECT NT.Id,NT.HeadingName,NT.Type,NT.Color,NT.Hint,NT.TransactionTypeId,ISNULL(TT.PendingCount,0) Counts,
               --added by isuru 2026-10-30: page of the tile and the user's access to it
               NT.RoutePath, NT.FormID,
               -- same rule as SP_S_GetFinalSecuritySet + PermissionEnableGuard (the guard reads its
               -- ViewAccess, which that SP fills from the insert access): group access of the form,
               -- overridden by the user's own row. Central login: NULL - the access comes from the
               -- central login menu (checked in the menu, not in this database).
               CAST(CASE WHEN @IsCentralLogin = 1 THEN NULL
                         WHEN NT.FormID IS NULL OR GP.FormID IS NULL THEN 0
                         WHEN UP.FormID IS NOT NULL THEN ISNULL(UP.IsInsertAccess, 0)
                         ELSE ISNULL(GP.DefaultInsertAccess, 0) END AS BIT) HasAccess
        FROM dbo.NotificationPanelDetails NT
        LEFT JOIN #TempPendingCount TT ON TT.TransactionID = NT.TransactionTypeId
        OUTER APPLY (SELECT TOP (1) AGP.FormID, AGP.DefaultInsertAccess
                     FROM AutoGenerateGroupPrivileges AGP
                     WHERE AGP.UserGroupID = @GroupID AND AGP.FormID = NT.FormID) GP
        OUTER APPLY (SELECT TOP (1) AUP.FormID, AUP.IsInsertAccess
                     FROM AutoGenerateUserPrivileges AUP
                     WHERE AUP.UserMasterId = @UserID AND AUP.FormID = NT.FormID) UP


       
    END TRY
    BEGIN CATCH
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

GO

