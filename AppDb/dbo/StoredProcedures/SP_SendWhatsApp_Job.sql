-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-08-15
-- Description:	Job SP to call every 10 minutes to send pending whatsapp messages
--  [dbo].[SP_SendWhatsApp_Job]
-- =============================================
create PROCEDURE [dbo].[SP_SendWhatsApp_Job]
AS
BEGIN
	SET NOCOUNT ON;


	/**
	STATUS DESCRIPTION
	S = SUCCESS
	E = ERROR
	F = FAILED (AFTER 5 RETRRY UPDATING AS F)
	**/

	DECLARE @Number VARCHAR(20),@Message NVARCHAR(MAX),@LogID INT,@TransactionType CHAR(3),@Status CHAR(1),@Response NVARCHAR(MAX),@HeaderID INT,@UserID INT,@ApprovalLogID INT,
	@PropertyID INT,@LocationID INT,@TransactionID INT



	SELECT TOP (1) @Number =ContactNo,@UserID = RecivedUserID ,@TransactionType =  TransactionType
	FROM TransactionWiseSMS_Log WITH (NOLOCK)
	WHERE ISNULL(Status,'') <> 'S'
	AND ISNULL(ReTryCount,0) <=5


	SELECT @Message = 'You have to respond pending approval ' + STRING_AGG('• '+Message, ', ')  
	FROM TransactionWiseSMS_Log WITH (NOLOCK)
	WHERE ISNULL(Status,'') <> 'S'
	AND ISNULL(ReTryCount,0) <=5
	AND @UserID = RecivedUserID
	AND @TransactionType =  TransactionType; 

	SELECT @TransactionID = ID 
	FROM TransactionTypes
	WHERE Code= @TransactionType

	select @Message
	--Sending whatsapp message 
	EXEC SendWhatsAppMessage @Number, @Message,@Status = @Status OUTPUT,@Response = @Response OUTPUT;
	--end

	--Update log status table

	UPDATE TransactionWiseSMS_Log
	SET Status = @Status,ReTryCount = ReTryCount+1,Response = @Response,MsgSentTime = GETDATE()
	WHERE  @UserID = RecivedUserID
	AND @TransactionType =  TransactionType
	AND ISNULL(Status,'') <> 'S'
	AND ISNULL(ReTryCount,0) <=5
	--End

	IF (@Status = 'S')
	BEGIN

		UPDATE AL
		SET SendSMS =1 
		FROM ApprovalLogs AL
		INNER JOIN TransactionWiseSMS_Log TS ON AL.ApprovalLogID = TS.ApprovalLogID AND AL.TransactionHeaderID = TS.HeaderID AND AL.PropertyID = TS.PropertyID
		
		
	END

	

	IF EXISTS (SELECT 1 FROM TransactionWiseSMS_Log WITH (NOLOCK) WHERE @UserID = RecivedUserID  AND @TransactionType =  TransactionType AND Status <> 'S' AND ReTryCount >= 5)
	BEGIN
		UPDATE TransactionWiseSMS_Log
		SET Status = 'F'
		WHERE  @UserID = RecivedUserID
		AND @TransactionType =  TransactionType
		AND ISNULL(Status,'') <> 'S'
		AND ISNULL(ReTryCount,0) <=5

	END

END

GO

