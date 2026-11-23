


CREATE PROCEDURE [dbo].[SaveUserWiseLocations] @XMLDetails AS XML
AS
	 DECLARE @iDocID INT 
 BEGIN
       BEGIN TRY
         BEGIN TRANSACTION
		  EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;


		 
				SELECT  *
				INTO    #TEMPH
				FROM    OPENXML (@iDocID,'SaveUserWiseLocations',2)	
				WITH (IPAddress VARCHAR(max),CompanyId INT,CreatedUserID INT , LastModUserID INT,UserID INT,LocationID INT, IsActive BIT)


				INSERT INTO dbo.UserWise_Location
				(
				    UserID,
				    LocationID,
				    CompanyId,
				    IPAddress,
					IsActive,
				    CreatedUserID,
				    LastModUserID,
				    CreatedDate,
				    LastModDate
				)
				SELECT UserID,LocationID,CompanyId,IPAddress,IsActive,CreatedUserID,LastModUserID,GETDATE(),GETDATE() FROM #TEMPH
								
				


		  COMMIT TRANSACTION
 END TRY
   BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 



END

GO

