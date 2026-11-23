
CREATE PROCEDURE [dbo].[DeleteDocImages]
@DocId INT,
@DocType INT,
@Filename VARCHAR(max),
@UserID INT
AS 
BEGIN

	INSERT INTO DocumentWiseAttachments_Log(TableID, DocId, DocTypeID, FileName, CreatedUserID, CreatedDate, DeletedUser, DeletedDate)
	SELECT  Id, DocId, DocTypeID, FileName, CreatedUserID, CreatedDate,@UserID,GETDATE()
	FROM DocumentWiseAttachments
	WHERE DocId=@DocId AND DocTypeID=@DocType AND FileName=@Filename


    
	DELETE FROM DocumentWiseAttachments WHERE DocId=@DocId AND DocTypeID=@DocType AND FileName=@Filename

END

GO

