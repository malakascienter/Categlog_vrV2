-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: 2025-08-04
-- Description:	DELETE TOUR GUIDE COMPANIES
-- =============================================
CREATE PROCEDURE [dbo].[INV_TourGuideCompanies_M_Delete]
(
@Id		BIGINT,
@UserId	INT,
@PropertyId INT
)
AS
BEGIN
BEGIN TRANSACTION
BEGIN TRY

	UPDATE TourGuideCompanies
	SET IsDelete =1, IsActive =0
	WHERE Id = @Id AND PropertyId=@PropertyId
				
COMMIT TRANSACTION
END TRY
BEGIN CATCH	
	ROLLBACK TRANSACTION
	DECLARE @Error NVARCHAR(MAX)
	SET @Error=ERROR_MESSAGE()
	RAISERROR(@Error,16,1)	
END CATCH
    
END

GO

