
CREATE PROCEDURE [dbo].[SP_Insert_LocationWiseTransactionType] --3,6,1,1,1,1,'I'
	
	@PropertyID											INT,	
	@LocationID											INT,
	@TransactionID										INT,
	@IsActive											INT,
	@CreatedUserID										INT,
	@LastModUserID										INT,
	@Operation											CHAR(1)		
	
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @TDocNo VARCHAR(5)
	
	IF @Operation = 'I'
	BEGIN
	
		Declare @DocNo VARCHAR(5)
		Declare @TT   TABLE  
		(
		  [DocNo] [char](7)   
		)  
		  INSERT INTO @TT EXEC [SP_UpdateDocNo] 'LocationWiseTransactionTypes' 
			 SELECT @DocNo= DocNo FROM @TT 
			 
		IF @@ROWCOUNT > 0 
		BEGIN
			SET @TDocNo  = @DocNo
		END
	
		INSERT INTO [dbo].[LocationWiseTransactionTypes]
		(
			PropertyID,
			LocationID,
			TransactionID, 
			IsActive,
			CreatedUserID,
			LastModUserID,
			CreatedDate, 
			LastModDate
		)
		VALUES
		(
			@PropertyID,
			@LocationID,
			@TransactionID,
			@IsActive,
			@CreatedUserID,
			@LastModUserID,	
			GETDATE(),
			GETDATE()
		)
	END
	ELSE 
	BEGIN
	

	--select * from LocationWiseTransactionTypes
		UPDATE dbo.LocationWiseTransactionTypes
		SET

			LastModDate							=	GETDATE(),
			LastModUserID						=	@LastModUserID,
			IsActive							=	@IsActive
		
		WHERE PropertyID =	@PropertyID AND LocationID = @LocationID AND TransactionID = @TransactionID
	
	END
    
END

GO

