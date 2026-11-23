
-- Save the logged-in user (not hardcoded 1) into CreatedUser/ModifiedUser/CreatedUserID/LastModUserID
-- when giving transaction wise approvals.

CREATE PROCEDURE [dbo].[SP_giveTransactionWisePermissionToUSer]
    @CompanyId INT,
    @LocationID INT,
    @TransType INT,
    @ApprovalType INT,
    @UserId INT,
    @LoggedUserID INT
AS
BEGIN
    BEGIN TRY

        DECLARE @Validation VARCHAR(500)
        IF NOT EXISTS
        (
            SELECT *
            FROM UserWiseApproveLevels
            WHERE PropertyId = @CompanyId
                  AND LocationId = @LocationID
                  AND TransactionTypeID = @TransType
                  AND ApproveLevelID = @ApprovalType
                  AND UserProfileId = @UserId
        )
        BEGIN

            IF EXISTS(SELECT 1 FROM UserWiseApproveLevels WHERE LocationId = @LocationID and TransactionTypeID = @TransType and UserProfileId = @UserId)
            BEGIN
                SET @Validation =  'Approval Type is set for the Selected user with regard to the transcation type and location selected'
                RAISERROR (@Validation, 16, 1);
                SELECT -999 AS result
            END

            ELSE
            BEGIN

                INSERT INTO [dbo].[UserWiseApproveLevels]
                (
                    [PropertyId],
                    [LocationId],
                    [TransactionTypeID],
                    [ApproveLevelID],
                    [UserProfileId],
                    [CreatedDate],
                    [CreatedUser],
                    [ModifiedUser],
                    [ModifiedDate],
                    [IPAddress],
                    [CreatedUserID],
                    [LastModUserID],
                    [LastModDate]
                )
                VALUES
                (@CompanyId, @LocationID, @TransType, @ApprovalType, @UserId, GETDATE(), 1, 1, GETDATE(), '192.168.1.120', @LoggedUserID,
                 @LoggedUserID, GETDATE());

                 SELECT 1 AS result
            END;
        END;
        ELSE
        BEGIN
            SELECT -1 AS result;
        END;
    END TRY
BEGIN CATCH

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    -- Rethrow the error with the appropriate severity and state
    THROW 50000, @ErrorMessage, @ErrorState;
END CATCH;

END;

GO

