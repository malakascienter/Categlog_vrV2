CREATE PROCEDURE [dbo].[SP_SaveProcumentRequest]
@JsonData AS VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	 BEGIN TRY
        BEGIN TRANSACTION;

	 DECLARE @ItemId AS BIGINT,@ItemName VARCHAR(200)
	 DECLARE @ProcurementID AS BIGINT
	 DECLARE @ID AS BIGINT
	 DECLARE @SuppID AS BIGINT
	 SET @ProcurementID =  JSON_VALUE(@JsonData, '$.ProcurementID')
	 SET @SuppID =  JSON_VALUE(@JsonData, '$.SupplierId')
	 SET @ID =  JSON_VALUE(@JsonData, '$.UniqueId')


	
IF( isnull(@ID,0) = 0 )
BEGIN

IF EXISTS ( SELECT * FROM [SupplierQuotation] WHERE  ProcurementID = @ProcurementID AND SupplierID = @SuppID )
	BEGIN

      RAISERROR ('Record already exist.!',16,1)   

	END


	 SELECT @ItemId = ItemID,@ItemName = ItemName FROM ProcurementRequest WHERE ID = @ProcurementID

       INSERT INTO [dbo].[SupplierQuotation]
           ([ProcurementID]
           ,[SupplierID]
           ,[ItemID]
           ,[QuotationFile]
           ,[Price]
           ,[SubmittedDate]
           ,[StatusID]
           ,[ItemName]
           ,[TaxGroupId]
           ,[UserID]
           ,[ApprovedUserID])
     VALUES
           (JSON_VALUE(@JsonData, '$.ProcurementID'),        -- ProcurementID
            JSON_VALUE(@JsonData, '$.SupplierId'),           -- SupplierID
            ISNULL(@ItemId,0),               -- ItemID
            ISNULL(JSON_VALUE(@JsonData, '$.FileName'),''),                         -- FileName
            JSON_VALUE(@JsonData, '$.UnitPrice'),            -- Price (from the JSON)
            GETDATE(),                                   -- SubmittedDate (current date)
            1,                                           -- StatusID (Placeholder, replace as needed)
            isnull(@ItemName,''),                              -- ItemName (Placeholder)
            JSON_VALUE(@JsonData, '$.TaxGroupId'),           -- TaxGroupId
            JSON_VALUE(@JsonData, '$.UserId'),               -- UserID (from the JSON)
            NULL);  

			UPDATE ProcurementRequest
			SET StatusID=1
			WHERE ID= @ProcurementID
 

END
ELSE
BEGIN    

   IF EXISTS ( SELECT * FROM [SupplierQuotation] WHERE  ProcurementID = @ProcurementID AND SupplierID = @SuppID AND ID <> @ID )
	BEGIN

      RAISERROR ('Record already exist.!',16,1)   

	END

	UPDATE [SupplierQuotation]
	SET [SupplierID] = JSON_VALUE(@JsonData, '$.SupplierId'),
	    [TaxGroupId] = JSON_VALUE(@JsonData, '$.TaxGroupId'),
		[Price] = JSON_VALUE(@JsonData, '$.UnitPrice'),
		[QuotationFile] = CASE WHEN ISNULL(JSON_VALUE(@JsonData, '$.FileName'),'') = '' THEN [QuotationFile] ELSE ISNULL(JSON_VALUE(@JsonData, '$.FileName'),'') END
	WHERE ID = @ID

END
    
	 COMMIT TRANSACTION;
    END TRY


    BEGIN CATCH
      
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY()
          

      
        ROLLBACK TRANSACTION;

     
       
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END

GO

