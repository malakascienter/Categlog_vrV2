
-- =============================================  
-- Author:  Banu  
-- Create date: 02/11/2018  
-- Description: Delete for Item Category  
-- =============================================  
CREATE PROCEDURE [dbo].[ItemCategory_M_Delete]  
@Id INT,  
@UserId INT  
AS  
BEGIN  
	DECLARE @Remark NVARCHAR(250)    
	SET NOCOUNT OFF;  
  
	-- audit trail    
	EXEC [dbo].[AuditTrail_InsertToHistory] 'ItemCategory',@Id  
	-- end of audit trail   
  
	DELETE FROM ItemCategory   
	WHERE Id = @Id  
  
	-- audit trail      
	SET @Remark = 'Item category '+ CONVERT(VARCHAR,@Id) +' deleted.';  
	EXEC [dbo].[AuditTrail_InsertTableChanges] 'ItemCategory',@Id,@UserId,'D',@Remark  
	-- end of audit trail   
END

GO

