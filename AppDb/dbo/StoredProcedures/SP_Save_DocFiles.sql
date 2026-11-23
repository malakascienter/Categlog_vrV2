CREATE PROCEDURE [dbo].[SP_Save_DocFiles]
    @DocTypeID INT,
    @DocId INT,
    @filename VARCHAR(MAX),
    @Action INT
AS
BEGIN
    BEGIN TRY

        BEGIN TRANSACTION;



        IF (@Action = 1)
        BEGIN



            INSERT INTO [dbo].[DocumentWiseAttachments]
            (
                [DocId],
                [DocTypeID],
                [FileName],
                [CreatedUserID],
                [CreatedDate]
            )
            VALUES
            (@DocId, @DocTypeID, @filename, 1, GETDATE());



        END;
        ELSE
        BEGIN

            DELETE FROM DocumentWiseAttachments
            WHERE DocId = @DocId
                  AND DocTypeID = @DocTypeID;

        END;
        --select * from [dbo].[TenderBoardPaperHeaders]
        --select * from TenderBoardPaperWiseAttachments

        COMMIT TRANSACTION;


    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRAN; --RollBack in case of Error
    END CATCH;

END;

GO

