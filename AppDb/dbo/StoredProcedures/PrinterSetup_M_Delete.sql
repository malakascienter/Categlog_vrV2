
-- =============================================
-- Author:		Chiraj
-- Create date: 2018-10-31
-- Description:	Delete Printer
-- =============================================
CREATE PROCEDURE [dbo].[PrinterSetup_M_Delete] 
	@Code	VARCHAR(2),
	@UserId	INT,
	@PropertyId INT
AS
BEGIN
	DECLARE @Remark NVARCHAR(250)	
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROm ItemWisePrinters where PrinterCode=@Code AND PropertyId=@PropertyId)       
		BEGIN  
			RAISERROR('Printer already assign to Menu Item  ,You can not Delete the record',16,1)  
		END 

	ELSE
	BEGIN
		-- audit trail	 
	EXEC [dbo].[AuditTrail_InsertToHistory] 'PrinterSetup',@Code
	-- end of audit trail	

   Delete from PrinterSetup where Code=@Code AND PropertyId=@PropertyId

    UPDATE MainMenu SET IsUpload=0 WHERE ItemCode in (SELECT MainMenuCode FROM ItemWisePrinters where PrinterCode=@Code AND PropertyId=@PropertyId )AND PropertyId=@PropertyId
	-- audit trail				
	SET @Remark = 'Printer setup '+@Code+' deleted.';
	EXEC [dbo].[AuditTrail_InsertTableChanges] 'PrinterSetup',@Code,@UserId,'D',@Remark
	-- end of audit trail	
	END

	
END

GO

