CREATE procedure [dbo].[InsertCustomerDocuments](@XmlDetails as xml)
as
begin try
begin transaction

--[dbo].[InsertCustomerDocuments] '<ArrayOfCustomerWiseDocuments><CustomerWiseDocuments><CustomerID>1</CustomerID><DocumentID>5</DocumentID><Submited>true</Submited><documentPath>AAA</documentPath></CustomerWiseDocuments><CustomerWiseDocuments><CustomerID>1</CustomerID><DocumentID>5</DocumentID><Submited>true</Submited><documentPath>AAA</documentPath></CustomerWiseDocuments></ArrayOfCustomerWiseDocuments>'

	DECLARE @iDocID INT, @CustomerID int
	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
	
	SELECT	* into #tempdata	
	FROM	OPENXML(@iDocID, 'ArrayOfCustomerWiseDocuments/CustomerWiseDocuments', 2)
	WITH	(CustomerID int, DocumentID int, documentPathId varchar(max), Submited bit)

	--declare @CustomerID int

	select top (1) @CustomerID =CustomerID from  #tempdata

	delete from CustomerWiseDocuments
	where CustomerID = @CustomerID


	insert into CustomerWiseDocuments (CustomerID, DocumentID, Submited, documentPathId)
	select CustomerID, DocumentID, Submited, documentPathId from #tempdata

	UPDATE CustomerWiseDocuments
	SET CustomerWiseDocuments.documentPathId = D.ID 
	FROM CustomerWiseDocuments AS CWD
	INNER JOIN Documents AS D 
	ON D.PartnerTypeId = CWD.CustomerID AND D.DocTyprId = CWD.DocumentID AND D.PartnerType = 1
	

commit transaction
end try
begin catch
if @@TRANCOUNT>0
	ROLLBACK TRANSACTION

	INSERT INTO dbo.Error_List (OccuredDateTime,ErrorNo,ErrorLine,Error,ErrorProcedure) VALUES (SYSDATETIME(),ERROR_NUMBER(),ERROR_LINE(),ERROR_MESSAGE(),ERROR_PROCEDURE()); 		
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

end catch

--select * from CustomerWiseDocuments 

GO

