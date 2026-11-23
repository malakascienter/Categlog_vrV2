
-- =============================================  
-- Author:  Ovanthi NapeVithanage  
-- Create date: July 24,2018  
-- Description: Waiter_M_Delete  
-- =============================================  
CREATE PROCEDURE [dbo].[Waiter_M_Delete]  
	@Code NVARCHAR(8),  
	@UserId	INT,
	@PropertyId INT
AS  
BEGIN  
	DECLARE @Remark NVARCHAR(250)
	DECLARE @Id INT	
	
	SELECT @Id = Id FROM Waiter WHERE Code = @Code  AND PropertyId=@PropertyId
	-- audit trail	 
	EXEC [dbo].[AuditTrail_InsertToHistory] 'Waiter',@Id
	-- end of audit trail	

	-- Audit trail ----------------------------		
	EXEC HotelResWeb_AuditTail_WriteToLog 'Waiter',@Id,'POS','POSWWD','D',@UserId,'','','','','',@PropertyId
	-- End of Audit trail ---------------------

	UPDATE Waiter
	SET Active = 0,
		IsDeleted = 1,
		IsUpload = 0
	WHERE Code = @Code  AND PropertyId=@PropertyId

	--DELETE FROM Waiter WHERE Code = @Code  AND PropertyId=@PropertyId
	--DELETE FROM WaiterWiseoutlets WHERE WaiterCode = @Code   AND PropertyId=@PropertyId
	-- audit trail				
	SET @Remark = 'Waiter '+@Code+' deleted.';
	EXEC [dbo].[AuditTrail_InsertTableChanges] 'Category',@Id,@UserId,'D',@Remark
	-- end of audit trail	
END

GO

