-- =============================================
-- Author:		Nivesh
-- Create date: 2025-11-27
-- Description:	Insert Special Order User-wise Transaction
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SP_InsertUserWiseTransaction] 
	@JsonDetail NVARCHAR(MAX)
AS
BEGIN
	
	--SET NOCOUNT ON;
BEGIN TRY 
BEGIN TRAN

	DECLARE @Id INT                = JSON_VALUE(@JsonDetail, '$.Id');
    DECLARE @PropertyId INT        = JSON_VALUE(@JsonDetail, '$.PropertyId');
    DECLARE @LocationId VARCHAR(5)        = JSON_VALUE(@JsonDetail, '$.LocationId');
    DECLARE @TransactionTypeID INT = JSON_VALUE(@JsonDetail, '$.TransactionTypeID');
    DECLARE @ApproveTypeID INT     = JSON_VALUE(@JsonDetail, '$.ApproveTypeID');
    DECLARE @UserProfileId INT     = JSON_VALUE(@JsonDetail, '$.UserProfileId');
    DECLARE @CreatedUserID INT     = JSON_VALUE(@JsonDetail, '$.CreatedUserID');
    DECLARE @LastModUserID INT     = JSON_VALUE(@JsonDetail, '$.LastModUserID');
    DECLARE @IsDropdown BIT = 0

    SELECT @IsDropdown =ISNULL(IsDropdown,0) FROM SPO_TransactionType WHERE Id= @TransactionTypeID

    IF(@IsDropdown = 1)
    BEGIN
		CREATE TABLE #Temp_UserWiseLocaion(
		id VARCHAR(5)
	    )
         IF JSON_QUERY(@JsonDetail, '$.LocationList') IS  NULL AND @IsDropdown = 1
         BEGIN
            RAISERROR('Please Select Locaion',16,1)
		    ROLLBACK TRANSACTION
         END
	
        INSERT INTO #Temp_UserWiseLocaion
	    (
		    id
	    )
	    SELECT  
            JSON_VALUE(value, '$.id')
        FROM OPENJSON(@JsonDetail,'$.LocationList' );

	     ---------------------------------------------------------
        -- Declare Cursor
        ---------------------------------------------------------
        DECLARE location_cursor CURSOR FAST_FORWARD FOR
        SELECT id
        FROM #Temp_UserWiseLocaion;

        ---------------------------------------------------------
        -- Open cursor
        ---------------------------------------------------------
        OPEN location_cursor;

        FETCH NEXT FROM location_cursor INTO @LocationId;

        ---------------------------------------------------------
        -- Loop through each row
        ---------------------------------------------------------
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Example insert
            IF NOT EXISTS(
		    SELECT 1 
		    FROM  SPO_UserWiseApproveLevels SU 
		    WHERE SU.PropertyId = @PropertyId 
		    AND SU.LocationId = @LocationId 
		    AND SU.TransactionTypeID = @TransactionTypeID
		    AND SU.UserProfileId = @UserProfileId
	        )
	        BEGIN
		        INSERT INTO [dbo].[SPO_UserWiseApproveLevels]
                   ([PropertyId]
                   ,[LocationId]
                   ,[TransactionTypeID]
                   ,[ApproveTypeID]
                   ,[UserProfileId]
                   ,[CreatedUserID]
                   ,[LastModUserID]
                   )
                VALUES( 
		            @PropertyId
                    ,@LocationId
                    ,@TransactionTypeID
                    ,@ApproveTypeID
                    ,@UserProfileId
                    ,@CreatedUserID
                    ,@LastModUserID
	            )
	        END

	    

            FETCH NEXT FROM location_cursor INTO @LocationId
        END

        ---------------------------------------------------------
        -- Close cursor
        ---------------------------------------------------------
        CLOSE location_cursor;
        DEALLOCATE location_cursor;
    END
    ELSE
    BEGIN
         IF NOT EXISTS(
		    SELECT 1 
		    FROM  SPO_UserWiseApproveLevels SU 
		    WHERE SU.PropertyId = @PropertyId 
		    AND SU.TransactionTypeID = @TransactionTypeID
		    AND SU.UserProfileId = @UserProfileId
	        )
	        BEGIN
		        INSERT INTO [dbo].[SPO_UserWiseApproveLevels]
                   ([PropertyId]
                   ,[LocationId]
                   ,[TransactionTypeID]
                   ,[ApproveTypeID]
                   ,[UserProfileId]
                   ,[CreatedUserID]
                   ,[LastModUserID]
                   )
                VALUES( 
		            @PropertyId
                    ,0
                    ,@TransactionTypeID
                    ,@ApproveTypeID
                    ,@UserProfileId
                    ,@CreatedUserID
                    ,@LastModUserID
	            )
	        END
            ELSE
            BEGIN
                RAISERROR('User has already approval',16,1)
		        ROLLBACK TRANSACTION
            END
    END
	

COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
	ROLLBACK TRANSACTION
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
END

GO

