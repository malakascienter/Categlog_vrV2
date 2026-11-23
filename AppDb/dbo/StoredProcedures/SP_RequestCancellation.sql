

CREATE  PROCEDURE [dbo].[SP_RequestCancellation] 
	@isPOCancelationOrCompletion VARCHAR(4),
	@Type				VARCHAR(2),
	@UserProfileId		int = 1,
	@Id			INT = 0
AS
BEGIN
-----------------------------------------------------------------
BEGIN TRY 
		DECLARE @RequestType CHAR(2),@LocationID INT,@PropertyID INT
---------------------
IF(@UserProfileId = 0)
		BEGIN
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

----------------------

	IF @isPOCancelationOrCompletion = 'CA'
	BEGIN
     IF @Type = 'P'
	   BEGIN

	   ------------------------Added by Nivesh 2024-10-02-------------------When rejecting the PR base PO update the document status 'C' to 'P'
	    DECLARE @TEmp AS TABLE
        (
            RequestHeaderID INT,
            RequestedQty DECIMAL,
            StockItemID INT,
            ApprovedQty DECIMAL
        );

        INSERT INTO @TEmp
        (
            RequestHeaderID,
            RequestedQty,
            StockItemID,
            ApprovedQty
        )
        SELECT RequestHeaderID,
               RequestionQty,
               StockItemID,
               ApprovedQty
        FROM dbo.PoWisePRs WITH(NOLOCK)
        WHERE PoHeaderID = @Id;

		 WHILE
        (SELECT COUNT(*) FROM @TEmp) > 0
        BEGIN

            DECLARE @RequestHeadID INT,
                    @RequestionQty DECIMAL,
                    @ApprovedQty DECIMAL,
                    @ItemId INT;

            SELECT TOP (1)
                   @RequestHeadID = RequestHeaderID,
                   @RequestionQty = RequestedQty,
                   @ItemId = StockItemID,
                   @ApprovedQty = ApprovedQty
            FROM @TEmp;

            UPDATE dbo.PoWisePRs
            SET ApprovedQty = @RequestionQty
            WHERE PoHeaderID = @Id
                  AND StockItemID = @ItemId
                  AND RequestHeaderID = @RequestHeadID;

            IF (@ApprovedQty > 0)
            BEGIN
                UPDATE dbo.RequestDetails
                SET IssuedQuantity = (IssuedQuantity + (@RequestionQty - @ApprovedQty)) - @RequestionQty
                WHERE RequestHeaderID = @RequestHeadID
                      AND StockItemID = @ItemId;

            END;

            ELSE
            BEGIN
                UPDATE dbo.RequestDetails
                SET IssuedQuantity = IssuedQuantity - @RequestionQty
                WHERE RequestHeaderID = @RequestHeadID AND StockItemID = @ItemId;
            END;

			
			DECLARE @IsDirectPO BIT =0;
			SELECT @IsDirectPO = IsDirectPo FROM PoHeaders WHERE ID = @Id;

			IF(ISNULL(@IsDirectPO,0)= 0)
			BEGIN
                UPDATE dbo.RequestHeaders
                SET DocumentStatus = 'P'
                WHERE Id = @RequestHeadID;				
			END

            SELECT @RequestHeadID,
                   @RequestionQty,
                   @ItemId;

            DELETE FROM @TEmp
            WHERE StockItemID = @ItemId
                  AND RequestHeaderID = @RequestHeadID;

        END;

	   -------------------------------------------------------------
	     
		 UPDATE PoHeaders SET DocumentStatus = 'X',LastModUserID = @UserProfileId,LastModDate=GETDATE() WHERE Id = @Id



		 SELECT @LocationID = LocationID,@PropertyID = PropertyID
		 FROM PoHeaders
		 WHERE ID = @Id

		 
		 --Added by Isuru 2025-02-05 for inserting into log table cancelled POs
		INSERT INTO  POStatusUpdate_Log(PropertyID, PoHeaderID, Status, Module, SysDate, UserID)
		SELECT @PropertyID,@Id,'Cancel','PO Cancelation View',GETDATE(),@UserProfileID
		--End

		 	 --sending Tranasctionwise emails 2024-09-27
		EXEC [dbo].[SendTransactionWiseEmailS] 'PO',@Id,@LocationID,@PropertyID,'X'
		--END


	   END
	 ELSE 
	   BEGIN
	    
		 UPDATE RequestHeaders SET DocumentStatus = 'X',LastModUserID = @UserProfileId WHERE Id = @Id

		 SELECT @RequestType= RequestType,@LocationID =  LocationID,@PropertyID = PropertyID
		 FROM RequestHeaders
		 WHERE Id = @Id

		 --sending Tranasctionwise emails 2024-09-27
		EXEC [dbo].[SendTransactionWiseEmailS] @RequestType,@Id,@LocationID,@PropertyID,'X'
		--END

	   END
	END
	ELSE IF @isPOCancelationOrCompletion = 'CO'
	BEGIN
	IF @Type = 'P'
	   BEGIN

		 INSERT INTO POCancellationLog( PoHeaderId, UserProfileID, SysDate) -- Do not remove this log table  -- its used to get Discarded PO List for print copies
		 VALUES       (@Id,@UserProfileId,GETDATE())
		 UPDATE PoHeaders SET DocumentStatus = 'C',LastModUserID = @UserProfileId,LastModDate=GETDATE() WHERE Id = @Id

	   END
	 ELSE 
	   BEGIN
	    
		 UPDATE RequestHeaders SET DocumentStatus = 'C',UserProfileID = @UserProfileId WHERE Id = @Id

	   END
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
-----------------------------------------------------------------

END

GO

