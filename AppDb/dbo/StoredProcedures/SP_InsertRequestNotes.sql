--[dbo].[SP_InsertRequestNotes] '<ArrayOfRequestNotes ><RequestNotes><Id>-1</Id><HeaderID>1076</HeaderID><Note>cxxc</Note><UserId>1</UserId><UserName>System</UserName></RequestNotes></ArrayOfRequestNotes>'
--go
--EXEC [dbo].[SP_InsertRequestNotes] '<ArrayOfRequestNotes xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><RequestNotes><Id>-1</Id><HeaderID>24</HeaderID><Note>test note 1111</Note><UserId>2</UserId></RequestNotes><RequestNotes><Id>-1</Id><HeaderID>24</HeaderID><Note>sssghkjf ntweukll 5646446</Note><UserId>2</UserId></RequestNotes></ArrayOfRequestNotes>'

CREATE PROCEDURE [dbo].[SP_InsertRequestNotes]
    (
      @XMLDetails AS XML 
    )
AS
    DECLARE @iDocID INT


    BEGIN TRY
        BEGIN TRANSACTION

		 DECLARE @HeaderID VARCHAR(MAX) 

		 EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails

		 SELECT TOP 1  @HeaderID=HeaderID 
                FROM    OPENXML (@iDocID,'/ArrayOfRequestNotes/RequestNotes',2)
         WITH RequestNotes

		 DELETE FROM RequestNotes WHERE HeaderID = @HeaderID

		 INSERT  INTO RequestNotes
                ( 
                  HeaderID, Note, UserId
                )
                SELECT  HeaderID, Note, UserId
                FROM    OPENXML (@iDocID,'/ArrayOfRequestNotes/RequestNotes',2)
         WITH RequestNotes


	

     



        COMMIT TRAN 
    END TRY
    BEGIN CATCH
	    --RAISERROR('Error raised in TRY block.', 16, 1 ) //Comment by Nivesh 2024 02 12
        IF @@TRANCOUNT > 0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState); --Added by Nivesh 2024 02 12
        ROLLBACK TRAN 
    END CATCH

GO

