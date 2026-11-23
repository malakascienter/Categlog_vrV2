
--SaveUserWiseDepartments '<UserWiseDepartmentViewModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><IPAddress>192.168.8.1</IPAddress><CreatedUserID>4168</CreatedUserID><LastModUserID>0</LastModUserID><CreatedDate>2023-09-11T04:44:25.427Z</CreatedDate><LastModDate>2023-09-11T04:44:25.427Z</LastModDate><UserId>4168</UserId><DepartmentId>1</DepartmentId><CompanyId>1</CompanyId></UserWiseDepartmentViewModel>'

CREATE PROCEDURE [dbo].[SaveUserWiseDepartments] @XMLDetails AS XML
AS
	 DECLARE @iDocID INT 
	 DECLARE @ErrorMsg VARCHAR(300)
 BEGIN
       BEGIN TRY
        BEGIN TRANSACTION
		  EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;


		 
				SELECT  *
				INTO    #TEMPH
				FROM    OPENXML (@iDocID,'UserWiseDepartmentViewModel',2)	
				WITH (IPAddress VARCHAR(max),CompanyId INT,CreatedUserID INT , LastModUserID INT,CreatedDate DATETIME,LastModDate DATETIME,UserId INT,DepartmentId INT)



IF EXISTS( SELECT * FROM  UserWiseDepartments US INNER JOIN #TEMPH T ON US.companyId = T.CompanyID AND US.deptid = T.DepartmentId AND US.userId = T.UserId)
BEGIN
select '44'   
SET @ErrorMsg  =  'Department already exists for user..!'
			RAISERROR ( @ErrorMsg, 16, 1 );  
			ROLLBACK TRANSACTION
 

END
ELSE
BEGIN

 INSERT INTO dbo.UserWiseDepartments
				(
				    userId,
				    deptid,
				    companyId,
				    IPAddress,
				    CreatedUserID,
				    LastModUserID,
				    CreatedDate,
				    LastModDate
				)
				SELECT UserId,DepartmentId,CompanyID,IPAddress,CreatedUserID,LastModUserID,SYSDATETIME(),SYSDATETIME() FROM #TEMPH

END


				
       COMMIT TRAN  --Transaction Success!
    END TRY
    BEGIN CATCH
	    --RAISERROR('Error raised in TRY block.', 16, 1 )
     --   IF @@TRANCOUNT > 0
     --       ROLLBACK TRAN 
	    --SELECT  
     --       ERROR_NUMBER() AS ErrorNumber  
     --       ,ERROR_SEVERITY() AS ErrorSeverity  
     --       ,ERROR_STATE() AS ErrorState  
     --       ,ERROR_PROCEDURE() AS ErrorProcedure  
     --       ,ERROR_LINE() AS ErrorLine  
     --       ,ERROR_MESSAGE() AS ErrorMessage;  
	 

		ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);


    END CATCH;



END

GO

