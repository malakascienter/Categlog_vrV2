
--SaveUserWiseCompanies '<UserWiseCompaniesViewModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><IPAddress>192.168.8.1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>0</LastModUserID><CreatedDate>2018-12-17T09:22:04.401Z</CreatedDate><LastModDate>2018-12-17T09:22:04.401Z</LastModDate><UserId>1</UserId><CompanyId>1</CompanyId></UserWiseCompaniesViewModel>'
--SELECT * FROM dbo.UserWiseCompanies
CREATE PROCEDURE SaveUserWiseCompanies @XMLDetails AS XML
AS
	 DECLARE @iDocID INT 
 BEGIN
       BEGIN TRY
         BEGIN TRANSACTION
		  EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;


		 
				SELECT  *
				INTO    #TEMPH
				FROM    OPENXML (@iDocID,'UserWiseCompaniesViewModel',2)	
				WITH (IPAddress VARCHAR(max),CreatedUserID INT , LastModUserID INT,CreatedDate DATETIME,LastModDate DATETIME,UserId INT,CompanyId INT)


				INSERT INTO dbo.UserWiseCompanies
				(
				    UserId,
				    CompnayId,
				    IPAddress,
				    CreatedUserID,
				    LastModUserID,
				    CreatedDate,
				    LastModDate
				)
				SELECT UserId,CompanyId,IPAddress,CreatedUserID,LastModUserID,SYSDATETIME(),SYSDATETIME() FROM #TEMPH
				
				


		  COMMIT TRANSACTION
 END TRY
   BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 



END

GO

