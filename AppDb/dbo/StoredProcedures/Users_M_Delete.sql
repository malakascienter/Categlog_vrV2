-- =============================================
-- Author:	Yasiru	
-- Create date: 2017/12/11
-- Description:Delete Alert Types
-- =============================================
CREATE PROCEDURE [dbo].[Users_M_Delete]
(
	@Id INT ,
	@PropertyId INT
)
AS
BEGIN	
	SET NOCOUNT ON;
	IF EXISTS (SELECT 1 FROM Users WHERE Id = @Id AND PropertyId=@PropertyId )
	BEGIN

		-- Audit trail ----------------------------		
		EXEC HotelResWeb_AuditTail_WriteToLog 'Users',@Id,'POS','POSUUD','D',0,'','','','','',@PropertyId
		-- End of Audit trail ---------------------
			

		UPDATE Users
		SET IsUpload = 0,
			IsActive = 0
		WHERE Id = @Id AND PropertyId=@PropertyId 


		IF EXISTS( SELECT 1 FROM Companies WHERE IsRestaurant = 1 AND CompanyID = @PropertyId  )
		BEGIN
		 DECLARE @UserTableIDStr VARCHAR(50) = CONVERT(VARCHAR(50),@Id)
		 EXEC Insert_Sync_MasterDataTransferStatus 'User',0,@UserTableIDStr,@PropertyId
		
		END

		--DELETE FROM Users WHERE Id = @Id AND PropertyId=@PropertyId 
	END
	ELSE
	BEGIN
		RAISERROR('No record exists.',16,1)
	END	
END

GO

