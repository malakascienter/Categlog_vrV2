
CREATE PROCEDURE [dbo].[GET_ALL_Approvals]
(
    @LocationID      INT,
    @TransactionType INT,
    @CompanyId       INT = 0
)
AS
BEGIN

    DECLARE @IsCentral BIT, @IsDepartmentWisePOApproval BIT = 0

    SELECT @CompanyId = CompanyId FROM Locations WHERE Id = @LocationID

    IF (@TransactionType = 11 OR @TransactionType = 1)
    BEGIN
        SELECT @CompanyId = PropertyID FROM DEPARTMENTS WHERE Id = @LocationID
        SELECT @IsCentral = IsCentralLogin FROM Companies WHERE CompanyID = @CompanyId
    END

    -- Added by Isuru 2025-09-29
    --changed by isuru 2026-10-28: Supplier Grading (SGR) setups are stored with location -999 like 81/82
    IF (@TransactionType = 81 OR @TransactionType = 82 OR @TransactionType = (SELECT TOP (1) Id FROM dbo.TransactionTypes WHERE Code = 'SGR'))
    BEGIN
        SELECT @CompanyId = 1
        SELECT @IsCentral = IsCentralLogin FROM Companies WHERE CompanyID = @CompanyId
    END
    -- End

    IF (@CompanyId IS NOT NULL AND @CompanyId <> 0)
    BEGIN
        SELECT @IsCentral                  = IsCentralLogin,
               @IsDepartmentWisePOApproval = IsDepartmentWisePOApproval
        FROM Companies
        WHERE CompanyID = @CompanyId
    END

    IF (@IsCentral = 1)
    BEGIN
        SELECT TA.LocationID       AS LocationID,
               TA.SeqID,
               TT.Name             AS TrasactionTypeName,
               AP.ApprovalTypeName AS ApprovalTypeName,
               UM.UserName         AS UserName,
               TA.TransactionID    AS TrasactionTypeID,
               TA.ApprovalTypeID   AS ApprovalTypeID,
               UA.UserProfileId    AS UserID,
               TA.MinValue         AS CutoffValue,
               UA.RangeFrom,
               UA.RangeTo,
               UA.SendEmail                                    -- added by Tharuka 2026-06-25 approval email
        FROM dbo.TransactionWiseApprovalTypes AS TA
        INNER JOIN dbo.UserWiseApproveLevels  AS UA ON TA.TransactionID  = UA.TransactionTypeID
                                                    AND TA.ApprovalTypeID = UA.ApproveLevelID
                                                    AND TA.LocationID     = UA.LocationId
                                                    AND TA.PropertyID     = UA.PropertyId
        INNER JOIN [dbo].[CentralUsers]       AS UM ON UM.Id = UA.UserProfileId
        INNER JOIN dbo.ApprovalTypes          AS AP ON AP.Id = TA.ApprovalTypeID
        INNER JOIN dbo.TransactionTypes       AS TT ON TT.Id = TA.TransactionID
        WHERE TA.TransactionID = @TransactionType
          AND TA.LocationID    = @LocationID
    END
    ELSE
    BEGIN
        SELECT TA.LocationID       AS LocationID,
               TA.SeqID,
               TT.Name             AS TrasactionTypeName,
               AP.ApprovalTypeName AS ApprovalTypeName,
               UM.UserName         AS UserName,
               TA.TransactionID    AS TrasactionTypeID,
               TA.ApprovalTypeID   AS ApprovalTypeID,
               UA.UserProfileId    AS UserID,
               TA.MinValue         AS CutoffValue,
               UA.RangeFrom,
               UA.RangeTo,
               UA.SendEmail                                    -- added by Tharuka 2026-06-25 approval email
        FROM dbo.TransactionWiseApprovalTypes AS TA
        INNER JOIN dbo.UserWiseApproveLevels  AS UA ON TA.TransactionID  = UA.TransactionTypeID
                                                    AND TA.ApprovalTypeID = UA.ApproveLevelID
                                                    AND TA.LocationID     = UA.LocationId
                                                    AND TA.PropertyID     = UA.PropertyId
        INNER JOIN UserMasters                AS UM ON UM.Id = UA.UserProfileId
        INNER JOIN dbo.ApprovalTypes          AS AP ON AP.Id = TA.ApprovalTypeID
        INNER JOIN dbo.TransactionTypes       AS TT ON TT.Id = TA.TransactionID
        WHERE TA.TransactionID = @TransactionType
          AND TA.LocationID    = @LocationID
    END

END

GO

