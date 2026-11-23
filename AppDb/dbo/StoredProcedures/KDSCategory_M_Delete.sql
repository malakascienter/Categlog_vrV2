
-- =============================================
-- Author:		Chiraj
-- Create date: 2018-07-23
-- Description:KDSCategory Delete
-- =============================================
CREATE  PROCEDURE [dbo].[KDSCategory_M_Delete]
@Code VARCHAR(6),
@UserId INT,
@PropertyId INT
AS
BEGIN	
	DECLARE @ID INT
	DECLARE @Remark VARCHAR(MAX)

	IF EXISTS(SELECT 1 FROM MainMenu WHERE MenuType=@Code And PropertyId=@PropertyId)
	BEGIN
		RAISERROR('Record Already Used, You Cannot Delete KDS Category!.',16,1)		
	END
	ELSE
	BEGIN
		SELECT @ID = Id FROM POSKDSCategory WHERE Code = @Code AND PropertyId=@PropertyId
		-- audit trail	 
		EXEC [dbo].[AuditTrail_InsertToHistory] 'POSKDSCategory',@ID
		-- end of audit trail

		DELETE FROM POSKDSCategory WHERE Code = @Code AND PropertyId=@PropertyId

		-- audit trail				
		SET @Remark = 'KDS Category '+@Code+' deleted.';
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'POSKDSCategory',@ID,@UserId,'D',@Remark
		-- end of audit trail	
	END	

    
END

GO

