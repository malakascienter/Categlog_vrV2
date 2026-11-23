-- =============================================

-- =============================================
CREATE PROCEDURE [dbo].[POSUserRoles_M_Delete]
(
	@Id INT ,
	@PropertyId INT 
)
AS
BEGIN	
	SET NOCOUNT ON;
	IF EXISTS (SELECT 1 FROM POSUserRoles WHERE Id = @Id)
	BEGIN

		-- Audit trail ----------------------------		
		EXEC HotelResWeb_AuditTail_WriteToLog 'POSUserRoles',@Id,'POS','POSURD','D',0,'','','','','',@PropertyId
		-- End of Audit trail ---------------------

		DELETE FROM POSUserRoles WHERE Id = @Id AND PropertyId=@PropertyId
	END
	ELSE
	BEGIN
		RAISERROR('No record exists.',16,1)
	END	
END

GO

