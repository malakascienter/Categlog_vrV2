-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-08-14
-- Description:	Sending Transaction wise approval SMS
-- [dbo].[SP_GetTransactionWiseWhatsAppSMS] 1,'PO',1,'C',4024,'TEST SMS SENDING'

-- =============================================
create PROCEDURE [dbo].[SP_GetTransactionWiseWhatsAppSMS]
@LocationID INT,
@TransactionType CHAR(3),
@PropertyID INT,
@Operation CHAR(2),
@HeaderID INT,
@SMSText NVARCHAR(MAX)

AS
BEGIN
	SET NOCOUNT ON;


	IF EXISTS (SELECT 1 FROM TransactionTypes  WHERE ISNULL(IsWhatsAppNotification,0) = 1 AND CODE = @TransactionType)
	BEGIN
		IF(@Operation = 'C')
		BEGIN
			IF(@TransactionType = 'PO')
			BEGIN
				DECLARE @SeqID INT

				SELECT TOP(1)@SeqID= AL.SeqID
				FROM ApprovalLogs AL
				WHERE AL.TransactionID=2 AND AL.TransactionHeaderID= @HeaderID AND ISNULL(AL.SendSMS,0) = 0 AND AL.DocStatus = 'P' 
				ORDER BY AL.SeqID ASC;

				INSERT INTO TransactionWiseSMS_Log(TransactionType, PropertyID, LocationID, HeaderID,ContactNo, RecivedUserID, Message, Status, CreatedDateTime, MsgSentTime, Response,ReTryCount,ApprovalLogID)
				SELECT DISTINCT @TransactionType TransactionType,@PropertyID PropertyID,@LocationID LocationID,@HeaderID HeaderID,US.MobileNumber ContactNo,AL.ApprovalUserID RecivedUserID
				,@SMSText  Message,'P' Status,GETDATE() CreatedDateTime,NULL MsgSentTime,NULL Response,0 ReTryCount,AL.ApprovalLogID
				FROM ApprovalLogs AS AL
					INNER JOIN dbo.UserWiseApproveLevels AS UAL
					ON AL.TransactionID = UAL.TransactionTypeID
					AND AL.LocationID = UAL.LocationId
					AND AL.PropertyID = UAL.PropertyId
					AND AL.ApprovalLevelID = UAL.ApproveLevelID
					INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
					INNER JOIN PoHeaders PH ON PH.Id = AL.TransactionHeaderID
				WHERE AL.TransactionID = 2	AND AL.TransactionHeaderID=@HeaderID AND AL.SeqID=@SeqID  AND ISNULL(AL.SendSMS,0) = 0
				AND PH.IsApproved=0

				
			


			END 

		END
	END	
END

GO

