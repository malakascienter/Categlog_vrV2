-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-08
-- Description:	Completion Common Transaction
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SP_CompletionCommonTransaction] 
	@JsonDetail NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	BEGIN TRY 
        ---------------------------------------------
        -- 1. Parse JSON input
        ---------------------------------------------
        DECLARE 
            @UserID INT,
            @PropertyID INT,
            @TransactionTypeID INT,
            @Action CHAR(1),
            @HeaderID INT;

        -- Extract top-level fields
        SELECT
            @TransactionTypeID = JSON_VALUE(@JsonDetail, '$.TransactionTypeID'),
            @Action            = JSON_VALUE(@JsonDetail, '$.action');

        ---------------------------------------------
        -- 2. Parse spParam object
        ---------------------------------------------
        DECLARE @spParam NVARCHAR(MAX) = JSON_VALUE(@JsonDetail, '$.spParam');

        SELECT
            @UserID     = JSON_VALUE(@spParam, '$.UserID'),
            @PropertyID = JSON_VALUE(@spParam, '$.PropertyID');

        ---------------------------------------------
        -- 3. Parse headerData object
        ---------------------------------------------
        DECLARE @headerData NVARCHAR(MAX) = JSON_VALUE(@JsonDetail, '$.headerData');

        SELECT 
            @HeaderID = JSON_VALUE(@headerData, '$.ID');

        ---------------------------------------------
        -- 4. DetailData (optional)
        ---------------------------------------------
        DECLARE @detailData NVARCHAR(MAX) = JSON_QUERY(@JsonDetail, '$.detailData');

        select @TransactionTypeID TransactionTypeID,
        @Action Action,
        @spParam spParam,
        @UserID UserID,
        @PropertyID PropertyID,
        @headerData headerData,
        @HeaderID HeaderID,
        @detailData detailData

	BEGIN TRAN
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

