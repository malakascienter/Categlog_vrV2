-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-01
-- Description:	Delete User-wise Transaction
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SP_DeleteUserWiseTransaction] 
    @JsonDetail NVARCHAR(MAX)
AS
BEGIN
    --SET NOCOUNT ON;

    DECLARE @Id INT               = JSON_VALUE(@JsonDetail, '$.Id');
    DECLARE @PropertyId INT       = JSON_VALUE(@JsonDetail, '$.PropertyId');
    DECLARE @LocationId VARCHAR(5)       = JSON_VALUE(@JsonDetail, '$.LocationId');
    DECLARE @TransactionID INT    = JSON_VALUE(@JsonDetail, '$.TransactionTypeID');
    DECLARE @UserProfileId INT    = JSON_VALUE(@JsonDetail, '$.UserProfileId');
    DECLARE @IsDropdown BIT =0;

    BEGIN TRY
        BEGIN TRANSACTION;
        
        SELECT @IsDropdown = ISNULL(IsDropdown,0) 
	    FROM SPO_TransactionType 
	    WHERE Id = @TransactionID

        --Check Pending Approvals--
        IF(@TransactionID =1) -- Customer Approval
        BEGIN
            IF EXISTS(
                SELECT 1 
                FROM SPO_TransactionApprovalLog 
                WHERE TransactionTypeID = @TransactionID 
                AND UserProfileID = @UserProfileId 
                AND IsApproved = 0 
                AND TransactionStatus = 'P'
            )
            BEGIN
                RAISERROR('Pending transaction found',16,1)
		        ROLLBACK TRANSACTION
            END
        END
        ELSE IF(@TransactionID =3) -- Discount Approval
        BEGIN
            IF EXISTS(
                SELECT 1 
                FROM SPO_TransactionApprovalLog 
                WHERE TransactionTypeID = @TransactionID 
                AND UserProfileID = @UserProfileId 
                AND LocationID = @LocationId
                AND IsApproved = 0 
                AND TransactionStatus = 'P'
            )
            BEGIN
                RAISERROR('Pending transaction found',16,1)
		        ROLLBACK TRANSACTION
            END
        END
        ---------------------------

        IF(@IsDropdown =1)
        BEGIN
             DELETE FROM [SPO_UserWiseApproveLevels]
                WHERE Id = @Id
              AND LocationId = @LocationId
              AND PropertyId = @PropertyId
              AND TransactionTypeID = @TransactionID
              AND UserProfileId = @UserProfileId;
        END
        ELSE
        BEGIN
             DELETE FROM [SPO_UserWiseApproveLevels]
                WHERE Id = @Id
                  AND PropertyId = @PropertyId
                  AND TransactionTypeID = @TransactionID
                  AND UserProfileId = @UserProfileId;
        END
       

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END

GO

