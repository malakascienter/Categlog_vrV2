

CREATE  PROCEDURE [dbo].[TourGuide_M_Delete]
@Id		BIGINT,
@UserId	INT,
@PropertyId INT
AS
BEGIN
BEGIN TRANSACTION
BEGIN TRY
	
		--IF EXISTS(SELECT 1 FROm TourGuideCompanies where Category=@Code AND PropertyId=@PropertyId)       
		--BEGIN  
		--	RAISERROR('Tour Guide Companies already used ,You can not Delete the record',16,1)  
		--END 
		--ELSE
		--BEGIN
				
			UPDATE TourGuideMaster 
			SET IsDelete = 1
			WHERE Id = @Id AND PropertyId=@PropertyId
			
		--END
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

