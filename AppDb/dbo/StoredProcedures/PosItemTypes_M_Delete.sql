
  
-- =============================================  
-- Author:  Chiraj  
-- Create date: 2018-7-25  
-- Description: Delete POSItemTypes  
-- =============================================  
CREATE PROCEDURE [dbo].[PosItemTypes_M_Delete]   
@Code CHAR(1) ,
@UserId	INT,
@PropertyId INT
AS  
BEGIN   
	DECLARE @Remark NVARCHAR(250);
	DECLARE @Id INT;
	SET NOCOUNT ON; 
	----SELECT ID FOR AUDIT TRAILS
	SELECT @Id = Id FROM POSItemTypes WHERE Code = @Code AND PropertyId=@PropertyId

	-- audit trail	 
	EXEC [dbo].[AuditTrail_InsertToHistory] 'POSItemTypes',@Id
	-- end of audit trail	
		 
	 
	DELETE FROM POSItemTypes WHERE Code=@Code  AND PropertyId=@PropertyId

	-- audit trail				
	SET @Remark = 'POS item types '+@Code+' deleted.';
	EXEC [dbo].[AuditTrail_InsertTableChanges] 'POSItemTypes',@Id,@UserId,'D',@Remark
	-- end of audit trail	
END

GO

