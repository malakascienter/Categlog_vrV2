

-- =============================================
-- Author:		Chiraj
-- Create date: 2018-7-24
-- Description:	Delete payment Type
-- =============================================
--[PaymentTypes_M_Delete] 'BR',1,3
CREATE  PROCEDURE [dbo].[PaymentTypes_M_Delete] -- 'hh',1,1
	@PayCode CHAR(2),
	@UserId	INT,
	@PropertyId INT
AS
BEGIN
BEGIN TRY
	DECLARE @Remark NVARCHAR(250)
	IF EXISTS (SELECT 1 FROM PayTrans WHERE PayCode = @PayCode AND PropertyId=@PropertyId)
	BEGIN
		RAISERROR('Payment type already use ,You cant delete the record',16,1)
	END
	ELSE
	BEGIN

		--DECLARE @PayCodeval CHAR(2)
		--SET @PayCodeval=(SELECT  case when @PayCode>0 and @PayCode<100 then RIGHT('0' + CAST(@PayCode AS VARCHAR), 2) else NULL END)
		SET NOCOUNT ON;

		DECLARE @PymentId INT
		SET @PymentId=(SELECT  Id FROM PaymentTypes WHERE PayCode=@PayCode  AND PropertyId=@PropertyId)
		-- audit trail	 
		EXEC [dbo].[AuditTrail_InsertToHistory] 'PaymentTypes',@PymentId
		-- end of audit trail	


		-- Audit trail ----------------------------		
		EXEC HotelResWeb_AuditTail_WriteToLog 'PaymentTypes',@PymentId,'POS','POSPTD','D',@UserId,'','','','','',@PropertyId
		-- End of Audit trail ---------------------

		DELETE FROM PaymentTypes WHERE PayCode=@PayCode AND PropertyId=@PropertyId

		-- audit trail				
		SET @Remark = 'Payment type '+@PayCode+' deleted.';
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'PaymentTypes',@PymentId,@UserId,'D',@Remark
		-- end of audit trail	

	END
	
END TRY

BEGIN CATCH	
	DECLARE @Error NVARCHAR(MAX)
	SET @Error=ERROR_MESSAGE()
	RAISERROR(@Error,16,1)	
END CATCH
END

GO

