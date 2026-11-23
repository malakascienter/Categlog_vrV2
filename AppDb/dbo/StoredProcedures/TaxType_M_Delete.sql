


-- =============================================
-- Author:		Yasiru
-- Create date: 30/10/2018
-- Description:	Delete Tax Group
-- =============================================
CREATE PROCEDURE [dbo].[TaxType_M_Delete] 
@ChargeTypeID INT,
@userId	INT,
@PropertyId INT
AS
BEGIN 
	DECLARE @Remark NVARCHAR(250)	 

	IF EXISTS(Select * from Gen_ChargeGroupDetail Where ChargeTypeID = @ChargeTypeID AND PropertyId=@PropertyId)
	BEGIN
    RAISERROR ('Error!, Record already used in Tax Group Details',16,1  );
	END
	ELSE
	BEGIN
		-- audit trail	 
	EXEC [dbo].[AuditTrail_InsertToHistory] 'Gen_ChargeType',@ChargeTypeID
	-- end of audit trail	

	SET NOCOUNT OFF; 
	DELETE FROM Gen_ChargeType WHERE ChargeTypeID = @ChargeTypeID AND PropertyId=@PropertyId

	-- audit trail		
			
	SET @Remark = 'Tax type '+CAST(@ChargeTypeID as Nvarchar(50))+' deleted.';
	EXEC [dbo].[AuditTrail_InsertTableChanges] 'Gen_ChargeType',@ChargeTypeID,@UserId,'D',@Remark
	-- end of audit trail	
	END

	
END

GO

