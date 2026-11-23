-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-02-09
-- Description:	Save Production Document attachements
-- =============================================
create PROCEDURE [dbo].[PRO_SaveDocumentAttachment]
	@DocId INT,
    @DocTypeID INT,
    @FileName NVARCHAR(MAX),
    @CreatedUserID INT,
    @CreatedDate DATETIME,
    @IsActive BIT,
    @CompanyId INT,
    @Operation CHAR(1),
    @DisplayFileName NVARCHAR(MAX)
AS
BEGIN
BEGIN  TRY
BEGIN TRANSACTION

	SET NOCOUNT ON;

    IF(@Operation = 'I')
    BEGIN
         INSERT INTO PRO_DocumentAttachments 
        (DocId, DocTypeID, FileName, CreatedUserID, CreatedDate, IsActive, CompanyId,DisplayFileName) 
        VALUES 
        (@DocId, @DocTypeID, @FileName, @CreatedUserID, @CreatedDate, @IsActive, @CompanyId,@DisplayFileName);
    
        SELECT SCOPE_IDENTITY() AS NewID;
    END
    
COMMIT TRANSACTION		
END TRY 
BEGIN CATCH
ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH  
END

GO

