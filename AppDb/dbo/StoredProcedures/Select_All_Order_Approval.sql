
CREATE PROCEDURE [dbo].[Select_All_Order_Approval] --Select_All_Order_Approval 1,1,1,0,40,1

    @UserProfileId INT = -1,
    @LocationID INT = 52,
    @PropertyID INT = -1,
    @Departmentid INT = -1,
    @TransactionID INT = -1,
    @IsLocationFilter BIT = 0
AS
BEGIN

    SET NOCOUNT ON;

    --IF OBJECT_ID('tempdb..#TempRequsetApproval') IS NOT NULL DROP TABLE #TempRequsetApproval	
    IF OBJECT_ID(N'#TempRequsetApproval', N'U') IS NOT NULL
    BEGIN
        DROP TABLE #TempRequsetApproval;
    END;
    --16 is MRN
    IF (@IsLocationFilter = 1 AND @TransactionID = 40)
    BEGIN
        SELECT DISTINCT
               al.ApprovalLogID,
               al.SeqID,
               al.TransactionID,
               al.ApprovalLevelID,
               al.TransactionHeaderID,
               al.PropertyID,
               al.LocationID,
               al.ApprovalUserID,
               al.ApprovalDate,
               al.IsComplete,
               al.DocStatus,
               UserToApprove.UserProfileId,
               UserToApprove.TransationTypeName,
               UserToApprove.Location,
               UserToApprove.Code,
               UserToApprove.ApprovalTypeID,
               ohed.Id AS 'PIID',
               ohed.TransType,
               ohed.DocumentNo,
               ohed.DocumentDate AS 'HeadersCreatedDate',
               ohed.DocumentStatus AS Status,
               1 AS 'JobNo',
               ohed.IsCancel,
               ohed.Remark,
                                         --inv.DepartmentID AS 'DepartmentID',
               1 AS 'TransferLocation',
               CURRENT_TIMESTAMP AS 'TimeStamp',
               1 AS 'TransactionTypeID', --txnTypeId
			   C.Id As 'CustomerID',
               C.CustomerName,
               al.LastModUserID,
               ohed.CancelDate AS 'CancelDate',
               ohed.CustomerID AS 'Reqcustomer',
               (
                   SELECT SUM(ISNULL(UnitPrice, 0) * RequestedQuantity) AS SumOf
                   FROM dbo.RequestDetails
                   WHERE RequestHeaderID = al.TransactionHeaderID
               ) AS 'ValueOfRequest',
               ohed.NetAmount AS 'NetAmount'
        INTO #TempRequsetApproval
        FROM dbo.ApprovalLogs al
            INNER JOIN
            (
                SELECT ta.PropertyID,
                       ta.LocationID,
                       ta.TransactionID,
                       ua.UserProfileId,
                       ta.SeqID,
                       tt.Name AS 'TransationTypeName',
                       ld.Name 'Location',
                       tt.Code AS 'Code',
                       ta.ApprovalTypeID
                FROM dbo.UserWiseApproveLevels ua
                    INNER JOIN dbo.TransactionWiseApprovalTypes ta
                        ON ua.ApproveLevelID = ta.ApprovalTypeID
                           AND ua.LocationId = ta.LocationID
                           AND ua.PropertyId = ta.PropertyID
                    INNER JOIN TransactionTypes tt
                        ON tt.Id = ta.TransactionID
                    INNER JOIN dbo.Locations ld
                        ON ld.Id = ta.LocationID
                WHERE ua.UserProfileId = @UserProfileId
                      AND ua.PropertyId = @PropertyID
                      AND ua.LocationId = @LocationID
            ) UserToApprove
                ON al.PropertyID = UserToApprove.PropertyID
            INNER JOIN dbo.OrderHeaders ohed
                ON ohed.Id = al.TransactionHeaderID
                   AND UserToApprove.PropertyID = UserToApprove.PropertyID
                   AND ohed.LocationID = UserToApprove.LocationID
                   --AND req.TransactionTypeCode = UserToApprove.ApprovalTypeID
                   AND al.LocationID = UserToApprove.LocationID
                   AND al.TransactionID = UserToApprove.TransactionID
                   AND IsComplete = 0
                   AND UserToApprove.SeqID = al.SeqID
            INNER JOIN Customers C
                ON C.Id = ohed.CustomerID
        WHERE al.SeqID IN
              (
                  SELECT MIN(SeqID)
                  FROM dbo.ApprovalLogs
                  WHERE IsComplete = 0
                        AND TransactionID = @TransactionID
                        AND al.PropertyID = @PropertyID
                        AND LocationID = @LocationID
                        AND dbo.ApprovalLogs.TransactionID = al.TransactionID
                        AND TransactionHeaderID = al.TransactionHeaderID
              );



        SELECT *
        FROM #TempRequsetApproval;



    END;
    ELSE IF @TransactionID = 49
    BEGIN
        SELECT DISTINCT
               al.ApprovalLogID,
               al.SeqID,
               al.TransactionID,
               al.ApprovalLevelID,
               al.TransactionHeaderID,
               al.PropertyID,
               al.LocationID,
               al.ApprovalUserID,
               al.ApprovalDate,
               al.IsComplete,
               al.DocStatus,
               UserToApprove.UserProfileId,
               UserToApprove.TransationTypeName,
               UserToApprove.Code,
               UserToApprove.ApprovalTypeID,
               req.Id AS 'PIID',
               req.CRNumber AS 'DocumentNo',
               --	req.RequestType,
			   C.Id as 'CustomerId',
               C.CustomerName,
               req.CreatedDate AS 'HeadersCreatedDate',
               req.DocumentStatus,
               1 AS 'JobNo',
               req.IsApproved,
               1 AS 'TransferLocation',
               CURRENT_TIMESTAMP AS 'TimeStamp',
               al.LastModUserID,
               req.Amount AS 'ValueOfRequest',
               req.Amount
        INTO #TempRequsetApproval3
        --SELECT * 
        FROM dbo.ApprovalLogs al
            INNER JOIN
            (
                SELECT ta.PropertyID,
                       ta.LocationID,
                       ta.TransactionID,
                       ua.UserProfileId,
                       ta.SeqID,
                       tt.Name AS 'TransationTypeName',
                       --  , ld.Name 'Location'
                       tt.Code AS 'Code',
                       ta.ApprovalTypeID
                FROM dbo.UserWiseApproveLevels ua
                    INNER JOIN dbo.TransactionWiseApprovalTypes ta
                        ON ua.ApproveLevelID = ta.ApprovalTypeID
                           AND ua.LocationId = ta.LocationID
                           AND ua.PropertyId = ta.PropertyID
                    INNER JOIN TransactionTypes tt
                        ON tt.Id = ta.TransactionID
                --  INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID 
                -- WHERE ua.TransactionTypeID =49

                WHERE ua.UserProfileId = @UserProfileId
                      AND ua.PropertyId = @PropertyID
                      AND ua.LocationId = -99
            ) UserToApprove
                ON al.PropertyID = UserToApprove.PropertyID
            INNER JOIN dbo.CreditApprovals req
                ON req.Id = al.TransactionHeaderID
                   AND UserToApprove.PropertyID = UserToApprove.PropertyID
                   -- AND req.LocationID = UserToApprove.LocationID 
                   --AND req.TransactionTypeCode = UserToApprove.ApprovalTypeID
                   AND al.LocationID = UserToApprove.LocationID
                   AND al.TransactionID = UserToApprove.TransactionID
                   AND IsComplete = 0
                   AND UserToApprove.SeqID = al.SeqID
            INNER JOIN Customers C
                ON C.Id = req.CustomerId

        --INNER JOIN dbo.UserMasters up ON up.Id = req.UserProfileID

        WHERE al.SeqID IN
              (
                  SELECT MIN(SeqID)
                  FROM dbo.ApprovalLogs
                  WHERE IsComplete = 0
                        AND TransactionID = @TransactionID
                        AND al.PropertyID = @PropertyID
                        AND dbo.ApprovalLogs.TransactionID = al.TransactionID
                        AND TransactionHeaderID = al.TransactionHeaderID
              );

        --SELECT * FROM CreditApprovals


        SELECT *
        FROM #TempRequsetApproval3;

    END;

    ELSE
    BEGIN

        --SELECT * FROM InvoiceHeaders
        SELECT DISTINCT
               al.ApprovalLogID,
               al.SeqID,
               al.TransactionID,
               al.ApprovalLevelID,
               al.TransactionHeaderID,
               al.PropertyID,
               al.LocationID,
               al.ApprovalUserID,
               al.ApprovalDate,
               al.IsComplete,
               al.DocStatus,
               UserToApprove.UserProfileId,
               UserToApprove.TransationTypeName,
               UserToApprove.Location,
               UserToApprove.Code,
               UserToApprove.ApprovalTypeID,
               req.ID AS 'PIID',
               1 AS 'JobNo',
               req.DepartmentID AS 'DepartmentID',
               1 AS 'TransferLocation',
               CURRENT_TIMESTAMP AS 'TimeStamp',
               1 AS 'TransactionTypeID', --txnTypeId
               al.LastModUserID,
               (
                   SELECT SUM(ISNULL(UnitPrice, 0) * RequestedQuantity) AS SumOf
                   FROM dbo.RequestDetails
                   WHERE RequestHeaderID = al.TransactionHeaderID
               ) AS 'ValueOfRequest'
        INTO #TempRequsetApproval2
        FROM dbo.ApprovalLogs al
            INNER JOIN
            (
                SELECT ta.PropertyID,
                       ta.LocationID,
                       ta.TransactionID,
                       ua.UserProfileId,
                       ta.SeqID,
                       tt.Name AS 'TransationTypeName',
                       ld.Name 'Location',
                       tt.Code AS 'Code',
                       ta.ApprovalTypeID
                FROM dbo.UserWiseApproveLevels ua
                    INNER JOIN dbo.TransactionWiseApprovalTypes ta
                        ON ua.ApproveLevelID = ta.ApprovalTypeID
                           AND ua.LocationId = ta.LocationID
                           AND ua.PropertyId = ta.PropertyID
                    INNER JOIN TransactionTypes tt
                        ON tt.Id = ta.TransactionID
                    INNER JOIN dbo.Locations ld
                        ON ld.Id = ta.LocationID
                WHERE ua.UserProfileId = @UserProfileId
                      AND ua.PropertyId = @PropertyID
            --AND ua.LocationID=@LocationID
            ) UserToApprove
                ON al.PropertyID = UserToApprove.PropertyID
            INNER JOIN dbo.InvoiceHeaders req
                ON req.ID = al.TransactionHeaderID
                   AND UserToApprove.PropertyID = UserToApprove.PropertyID
                   -- AND req.LocationID = UserToApprove.LocationID 
                   --AND req.TransactionTypeCode = UserToApprove.ApprovalTypeID
                   AND al.LocationID = UserToApprove.LocationID
                   AND al.TransactionID = UserToApprove.TransactionID
                   AND IsComplete = 0
                   AND UserToApprove.SeqID = al.SeqID
        --	 AND req.DepartmentID = @Departmentid
        -- AND req.Flag=0
        --	INNER JOIN dbo.UserMasters up ON up.Id = req.UserProfileID

        WHERE al.SeqID IN
              (
                  SELECT MIN(SeqID)
                  FROM dbo.ApprovalLogs
                  WHERE IsComplete = 0
                        AND TransactionID = @TransactionID
                        AND al.PropertyID = @PropertyID
                        --AND LocationID =@LocationID 
                        AND dbo.ApprovalLogs.TransactionID = al.TransactionID
                        AND TransactionHeaderID = al.TransactionHeaderID
              );



        SELECT *
        FROM #TempRequsetApproval2;

    END;

END;

GO

