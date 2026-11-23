-- =============================================
-- Author:		Isuru
-- Create date: 2025-05-27
-- Last Modified by	: Nivesh
-- Modified date	: 2025-07-16
-- Description:	Inserting into Mail Error Log

-- [dbo].[SP_InsertMailErroLog] 159,5,'','S','',0

-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertMailErroLog] 
	@SupplierID INT,
	@PurchaseRequestID INT,
	@ErrorMessage VARCHAR(MAX)='N/A',
	@Mode CHAR(2),
	@FilePath VARCHAR(MAX),
	@isMailSent BIT
AS
BEGIN
	SET NOCOUNT ON;

	IF(@Mode='I')
	BEGIN
		DELETE FROM  EmailFailureLog WHERE PurchaseRequestID = @PurchaseRequestID AND SupplierId = @SupplierId

		 INSERT INTO EmailFailureLog (SupplierId,PurchaseRequestID, ErrorMessage, ErrorDate,FilePath,isMailSent)
         VALUES (@SupplierId,@PurchaseRequestID, @ErrorMessage, GETDATE(),@FilePath,@isMailSent)

		 UPDATE QD
		 SET QD.MailStatus = CASE WHEN @isMailSent = 0 THEN 'F' ELSE 'S' END
		 FROM
		 QuotationRequestDetail QD 
		 INNER JOIN QuotationRequestHeader QH ON QD.QuotationRequestId = QH.Id
		 WHERE PurchaseRequestID = @PurchaseRequestID AND QD.SupplierId = @SupplierID

	END

	IF(@Mode ='S')
	BEGIN
	SELECT SU.Code,SU.Name SupplierName,ISNULL(SU.Email,'N/A') Email,SU.BSPCODE,EM.ErrorMessage ErrorMsg,FilePath FilePath, EM.isMailSent
	FROM EmailFailureLog EM
	INNER JOIN SUPPLIERS SU ON EM.SupplierId = SU.ID
	WHERE   PurchaseRequestID = @PurchaseRequestID
	AND ISNULL(IsView,0)=0

	UPDATE EmailFailureLog
	SET IsView=1
	WHERE   PurchaseRequestID = @PurchaseRequestID
	END

    
END

GO

