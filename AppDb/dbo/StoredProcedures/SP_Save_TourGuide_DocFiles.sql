-- =============================================
-- Author:		Ravindu
-- Create date: 2025-07-29
-- Description:	Tour guide company document save 
-- =============================================
CREATE PROCEDURE [dbo].[SP_Save_TourGuide_DocFiles]
    @DocID INT,
    @SetupID INT,
    @SetupCode VARCHAR(20),
    @Module VARCHAR(10),
    @Type VARCHAR(10),
    @FileName VARCHAR(MAX),
    @CreateduserID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO TourGuideDocUploads
        (
            DocID,
            SetupID,
            SetupCode,
            Module,
            Type,
            FileName,
            CreateduserID,
            CreatedDate
        )
        VALUES
        (
            @DocID,
            @SetupID,
            @SetupCode,
            @Module,
            @Type,
            @FileName,
            @CreateduserID,
            GETDATE()
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ERRmsg VARCHAR(MAX) = ERROR_MESSAGE();
        RAISERROR(@ERRmsg, 16, 1);
    END CATCH
END;

GO

