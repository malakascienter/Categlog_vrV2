create PROCEDURE [dbo].[UploadDocuments] @PartnerType INT,@CustomerId INT, @DocId INT, @PropertyId INT,@FilePath varchar(max)

 AS
 BEGIN 
	BEGIN TRY

	 BEGIN TRANSACTION;

--select * from documents


INSERT INTO [dbo].[Documents]
           ([PartnerType]
           ,[PartnerTypeId]
           ,[DocTyprId]
		   ,[UploadDate]
           ,[UserId]
           ,[FilePath])
     VALUES
           (@PartnerType
           ,@CustomerId
           ,@DocId
		   ,GETDATE()
		   ,@PropertyId
           ,@FilePath)

UPDATE CustomerWiseDocuments
SET CustomerWiseDocuments.documentPathId = D.ID 
FROM CustomerWiseDocuments AS CWD
INNER JOIN Documents AS D 
ON D.PartnerTypeId = CWD.CustomerID AND D.DocTyprId = CWD.DocumentID AND D.PartnerType = 1
WHERE D.PartnerTypeId = CWD.CustomerID AND D.DocTyprId = CWD.DocumentID AND D.PartnerType = 1


--select * from CustomerWiseDocuments
--delete from customerwisedocuments
--select * from documents
	 COMMIT TRANSACTION

	END TRY

	BEGIN CATCH

	 IF @@TRANCOUNT > 0
            ROLLBACK TRAN; --RollBack in case of Error
	END CATCH

 END

GO

