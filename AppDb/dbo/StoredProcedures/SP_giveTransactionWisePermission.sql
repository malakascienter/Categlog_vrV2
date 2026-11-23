
-- =============================================
-- Modified date: 2026-07-15
-- Description:   Give transaction wise approval permission.
--                Added audit trail logging (Inventry_AuditTail_WriteToLog):
--                - 'I' on TransactionWiseApprovalTypes after each insert
--                - 'U' on UserWiseApproveLevels after the range/email update
--                Audit calls run after the write so the audit SP can read
--                the row and snapshot it to history.
--                (UserWiseApproveLevels inserts are logged inside
--                SP_giveTransactionWisePermissionToUSer.)
-- =============================================

CREATE PROCEDURE [dbo].[SP_giveTransactionWisePermission]
    @CompanyId   INT,
    @LocationID  INT,
    @TransType   INT,
    @ApprovalType INT,
    @UserId      INT,
    @MinVal      INT,
    @RangeFrom   DECIMAL(18, 0) = 0,
    @RangeTo     DECIMAL(18, 0) = 0,
    @SendEmail   BIT = 0,
    @LoggedUserID INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY

        IF (@CompanyId = 0)
        BEGIN
            RAISERROR('Error Occured :Company ID Invalid, Please Log In Again', 16, 1)
            ROLLBACK TRANSACTION
        END

        IF (@UserId = 0)
        BEGIN
            RAISERROR('Error Occured :User ID Invalid, Please Log In Again', 16, 1)
            ROLLBACK TRANSACTION
        END

        --added by isuru 2026-10-28
        --Reason: Supplier Grading (SGR) has ONE approval level only. More users can be added to
        --        that level; a second level (another approval type) is not allowed.
        IF (@TransType = ISNULL((SELECT TOP (1) Id FROM dbo.TransactionTypes WHERE Code = 'SGR'), -1)
            AND EXISTS (SELECT 1 FROM dbo.TransactionWiseApprovalTypes
                        WHERE TransactionID = @TransType
                          AND PropertyID = @CompanyId
                          AND ApprovalTypeID <> @ApprovalType))
        BEGIN
            DECLARE @SGRLevelName NVARCHAR(200), @SGRMsg NVARCHAR(400);

            SELECT TOP (1) @SGRLevelName = AP.ApprovalTypeName
            FROM dbo.TransactionWiseApprovalTypes T
            INNER JOIN dbo.ApprovalTypes AP ON AP.Id = T.ApprovalTypeID
            WHERE T.TransactionID = @TransType
              AND T.PropertyID = @CompanyId
            ORDER BY T.SeqID;

            SET @SGRMsg = CONCAT('Supplier Grading allows only one approval level (', @SGRLevelName,
                                 '). Add more users to that level instead.');
            THROW 50020, @SGRMsg, 1;
        END
        --End

        DECLARE @seq INT;
        DECLARE @LocationID2 INT, @IsDepartmentWisePOApproval BIT, @IsRangeWiseApproval BIT;

        -- added by Tharuka 2026-07-15 for Audit trail
        DECLARE @NewTransApprovalTypeID INT, @UserWiseApproveLevelID INT;

        CREATE TABLE #TempUserWiseLocation (LocationID INT)

        SELECT @IsDepartmentWisePOApproval = IsDepartmentWisePOApproval,
               @IsRangeWiseApproval        = IsRangeWiseApproval
        FROM Companies
        WHERE CompanyID = @CompanyId

        --changed by isuru 2026-10-28
        --Reason: Supplier Grading (SGR) is approved at company level: keep 'All Locations' (-999)
        --        as one setup row instead of one row per user location (like the Tour Guide design)
        IF (@LocationID = -999 AND @TransType <> ISNULL((SELECT TOP (1) Id FROM dbo.TransactionTypes WHERE Code = 'SGR'), -1))
        BEGIN

            IF (@TransType = 2) -- PO
            BEGIN
                IF (@IsDepartmentWisePOApproval = 1)
                BEGIN
                    INSERT INTO #TempUserWiseLocation (LocationID)
                    SELECT deptid
                    FROM UserWiseDepartments
                    WHERE UserID = @UserId
                      AND CompanyId = @CompanyId
                END
                ELSE
                BEGIN
                    INSERT INTO #TempUserWiseLocation (LocationID)
                    SELECT LocationID
                    FROM UserWise_Location
                    WHERE UserID = @UserId
                      AND CompanyId = @CompanyId
                END
            END

            IF (@TransType IN (1, 11)) -- Purchase Request, Issue Request
            BEGIN
                INSERT INTO #TempUserWiseLocation (LocationID)
                SELECT deptid
                FROM UserWiseDepartments
                WHERE UserID = @UserId
                  AND CompanyId = @CompanyId
            END

            IF (@TransType NOT IN (1, 11, 2))
            BEGIN
                INSERT INTO #TempUserWiseLocation (LocationID)
                SELECT LocationID
                FROM UserWise_Location
                WHERE UserID = @UserId
                  AND CompanyId = @CompanyId
            END

            DELETE FROM #TempUserWiseLocation
            WHERE LocationID IN (
                SELECT LocationId
                FROM UserWiseApproveLevels
                WHERE TransactionTypeID = @TransType
                  AND UserProfileId = @UserId
            )

            SELECT * FROM #TempUserWiseLocation

            WHILE (SELECT COUNT(*) FROM #TempUserWiseLocation) > 0
            BEGIN
                SELECT TOP (1) @LocationID2 = LocationID
                FROM #TempUserWiseLocation

                IF NOT EXISTS
                (
                    SELECT 1
                    FROM TransactionWiseApprovalTypes
                    WHERE ApprovalTypeID = @ApprovalType
                      AND PropertyID     = @CompanyId
                      AND LocationID     = @LocationID2
                      AND TransactionID  = @TransType
                )
                BEGIN
                    IF NOT EXISTS
                    (
                        SELECT 1
                        FROM dbo.TransactionWiseApprovalTypes
                        WHERE PropertyID   = @CompanyId
                          AND LocationID   = @LocationID2
                          AND TransactionID = @TransType
                    )
                    BEGIN
                        SET @seq = 0;
                    END;
                    ELSE
                    BEGIN
                        SELECT @seq = MAX(SeqID)
                        FROM dbo.TransactionWiseApprovalTypes
                        WHERE PropertyID   = @CompanyId
                          AND LocationID   = @LocationID2
                          AND TransactionID = @TransType;
                    END;

                    INSERT INTO [dbo].[TransactionWiseApprovalTypes]
                    (
                        [TransactionApprovalID], [TransactionID], [PropertyID],
                        [LocationID], [ApprovalTypeID], [SeqID],
                        [IPAddress], [CreatedUserID], [LastModUserID],
                        [CreatedDate], [LastModDate], MinValue
                    )
                    VALUES
                    (
                        1, @TransType, @CompanyId, @LocationID2, @ApprovalType, @seq + 1,
                        '192.168.1.120', @LoggedUserID, @LoggedUserID, GETDATE(), GETDATE(), @MinVal
                    );

                    SET @NewTransApprovalTypeID = SCOPE_IDENTITY();

                    --Audit trail for the new transaction wise approval type
                    EXEC Inventry_AuditTail_WriteToLog 'TransactionWiseApprovalTypes', @NewTransApprovalTypeID, 'INV', 'TWAI', 'I', @LoggedUserID, @CompanyId, '', ''

                END;

                EXEC [dbo].[SP_giveTransactionWisePermissionToUSer] @CompanyId, @LocationID2, @TransType, @ApprovalType, @UserId, @LoggedUserID;

                IF (@IsRangeWiseApproval = 1)
                BEGIN
                    UPDATE dbo.UserWiseApproveLevels
                    SET RangeFrom = @RangeFrom,
                        RangeTo   = @RangeTo,
                        SendEmail = @SendEmail        -- added by Tharuka 2026-06-25 approval email
                    WHERE PropertyId        = @CompanyId
                      AND LocationId        = @LocationID2
                      AND TransactionTypeID = @TransType
                      AND ApproveLevelID    = @ApprovalType
                      AND UserProfileId     = @UserId;
                END
                ELSE
                BEGIN
                    UPDATE dbo.UserWiseApproveLevels
                    SET SendEmail = @SendEmail        -- added by Tharuka 2026-06-25 approval email
                    WHERE PropertyId        = @CompanyId
                      AND LocationId        = @LocationID2
                      AND TransactionTypeID = @TransType
                      AND ApproveLevelID    = @ApprovalType
                      AND UserProfileId     = @UserId;
                END

                --Audit trail for the range/email update on the approval level
                SET @UserWiseApproveLevelID = NULL

                SELECT @UserWiseApproveLevelID = Id
                FROM dbo.UserWiseApproveLevels
                WHERE PropertyId        = @CompanyId
                  AND LocationId        = @LocationID2
                  AND TransactionTypeID = @TransType
                  AND ApproveLevelID    = @ApprovalType
                  AND UserProfileId     = @UserId

                IF (@UserWiseApproveLevelID IS NOT NULL)
                BEGIN
                    EXEC Inventry_AuditTail_WriteToLog 'UserWiseApproveLevels', @UserWiseApproveLevelID, 'INV', 'UAI', 'I', @LoggedUserID, @CompanyId, '', ''
                END

                DELETE TOP (1) FROM #TempUserWiseLocation
            END
        END
        ELSE
        BEGIN
            IF NOT EXISTS
            (
                SELECT 1
                FROM TransactionWiseApprovalTypes
                WHERE ApprovalTypeID = @ApprovalType
                  AND PropertyID     = @CompanyId
                  AND LocationID     = @LocationID
                  AND TransactionID  = @TransType
            )
            BEGIN
                IF NOT EXISTS
                (
                    SELECT 1
                    FROM dbo.TransactionWiseApprovalTypes
                    WHERE PropertyID   = @CompanyId
                      AND LocationID   = @LocationID
                      AND TransactionID = @TransType
                )
                BEGIN
                    SET @seq = 0;
                END;
                ELSE
                BEGIN
                    SELECT @seq = MAX(SeqID)
                    FROM dbo.TransactionWiseApprovalTypes
                    WHERE PropertyID   = @CompanyId
                      AND LocationID   = @LocationID
                      AND TransactionID = @TransType;
                END;

                INSERT INTO [dbo].[TransactionWiseApprovalTypes]
                (
                    [TransactionApprovalID], [TransactionID], [PropertyID],
                    [LocationID], [ApprovalTypeID], [SeqID],
                    [IPAddress], [CreatedUserID], [LastModUserID],
                    [CreatedDate], [LastModDate], MinValue
                )
                VALUES
                (
                    1, @TransType, @CompanyId, @LocationID, @ApprovalType, @seq + 1,
                    '192.168.1.120', @LoggedUserID, @LoggedUserID, GETDATE(), GETDATE(), @MinVal
                );

                SET @NewTransApprovalTypeID = SCOPE_IDENTITY();

                --Audit trail for the new transaction wise approval type
                EXEC Inventry_AuditTail_WriteToLog 'TransactionWiseApprovalTypes', @NewTransApprovalTypeID, 'INV', 'TWAI', 'I', @LoggedUserID, @CompanyId, '', ''

            END;

            EXEC [dbo].[SP_giveTransactionWisePermissionToUSer] @CompanyId, @LocationID, @TransType, @ApprovalType, @UserId, @LoggedUserID;

            IF (@IsRangeWiseApproval = 1)
            BEGIN
                UPDATE dbo.UserWiseApproveLevels
                SET RangeFrom = @RangeFrom,
                    RangeTo   = @RangeTo,
                    SendEmail = @SendEmail            -- added by Tharuka 2026-06-25 approval email
                WHERE PropertyId        = @CompanyId
                  AND LocationId        = @LocationID
                  AND TransactionTypeID = @TransType
                  AND ApproveLevelID    = @ApprovalType
                  AND UserProfileId     = @UserId;
            END
            ELSE
            BEGIN
                UPDATE dbo.UserWiseApproveLevels
                SET SendEmail = @SendEmail            -- added by Tharuka 2026-06-25 approval email
                WHERE PropertyId        = @CompanyId
                  AND LocationId        = @LocationID
                  AND TransactionTypeID = @TransType
                  AND ApproveLevelID    = @ApprovalType
                  AND UserProfileId     = @UserId;
            END

            --Audit trail for the range/email update on the approval level
            SET @UserWiseApproveLevelID = NULL

            SELECT @UserWiseApproveLevelID = Id
            FROM dbo.UserWiseApproveLevels
            WHERE PropertyId        = @CompanyId
              AND LocationId        = @LocationID
              AND TransactionTypeID = @TransType
              AND ApproveLevelID    = @ApprovalType
              AND UserProfileId     = @UserId

            IF (@UserWiseApproveLevelID IS NOT NULL)
            BEGIN
                EXEC Inventry_AuditTail_WriteToLog 'UserWiseApproveLevels', @UserWiseApproveLevelID, 'INV', 'UAI', 'I', @LoggedUserID, @CompanyId, '', ''
            END

        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT @ErrorMessage;
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

GO

