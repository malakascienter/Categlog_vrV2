
CREATE PROCEDURE [dbo].[SPP_save_MRNRegistries]
	@RequestionID INT,
	@IssueID INT,
	@IPAddress nvarchar(max),	
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate DATETIME,
	@DocNO VARCHAR(max),
	@status[int] output,
	@message NVARCHAR(max) OUTPUT

	
AS
BEGIN



BEGIN TRY
	BEGIN TRANSACTION

	INSERT INTO dbo.MRNRegistries
	        ( RequestionID ,
	          IssueID ,
	          IPAddress ,
	          CreatedUserID ,
	          LastModUserID ,
	          CreatedDate ,
	          LastModDate ,
	          DocNo
	        )
	VALUES  ( @RequestionID , -- RequestionID - int
	          @IssueID , -- IssueID - int
	          @IPAddress , -- IPAddress - nvarchar(max)
	          @CreatedUserID , -- CreatedUserID - int
	          @LastModUserID , -- LastModUserID - int
	          @CreatedDate , -- CreatedDate - datetime
	          @LastModDate , -- LastModDate - datetime
	          @DocNO  -- DocNo - nvarchar(max)
	        )
			SET @status = 1;
COMMIT TRAN 
END TRY

BEGIN CATCH
SET @status = -1;
SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH

END

GO

