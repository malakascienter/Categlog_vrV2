--[dbo].[SP_S_SaveUserPermission] '<SecurityTemplateViewModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>-1</Id><TemplateName /><GroupId>0</GroupId><GroupName /><UserId>1</UserId><IpAddress>192.168.1.120</IpAddress><Details><SecuritySet><FormId>101</FormId><FormName>Approval Types</FormName><ViewAccess>false</ViewAccess><InsertAccess>false</InsertAccess><UpdateAccess>true</UpdateAccess><DeleteAccess>true</DeleteAccess><PrintAccess>true</PrintAccess><OverridedDefault>false</OverridedDefault><RwUpdated>true</RwUpdated></SecuritySet></Details></SecurityTemplateViewModel>'


--[dbo].[SP_S_SaveUserPermission] '<SecurityTemplateViewModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>1</Id><TemplateName>ccccc</TemplateName><GroupId>1</GroupId><GroupName>xxxx</GroupName><UserId>1</UserId><IpAddress>192.168.1.160</IpAddress><Details><SecuritySet><FormId>101</FormId><ViewAccess>false</ViewAccess><InsertAccess>true</InsertAccess><UpdateAccess>true</UpdateAccess><DeleteAccess>false</DeleteAccess><PrintAccess>false</PrintAccess><OverridedDefault>true</OverridedDefault></SecuritySet><SecuritySet><FormId>102</FormId><ViewAccess>true</ViewAccess><InsertAccess>true</InsertAccess><UpdateAccess>true</UpdateAccess><DeleteAccess>true</DeleteAccess><PrintAccess>true</PrintAccess><OverridedDefault>true</OverridedDefault></SecuritySet><SecuritySet><FormId>106</FormId><ViewAccess>true</ViewAccess><InsertAccess>true</InsertAccess><UpdateAccess>true</UpdateAccess><DeleteAccess>true</DeleteAccess><PrintAccess>true</PrintAccess><OverridedDefault>true</OverridedDefault></SecuritySet></Details></SecurityTemplateViewModel>'
CREATE PROCEDURE [dbo].[SP_S_SaveUserPermission] @XMLDetails AS XML
AS
    DECLARE @iDocID INT 
    BEGIN
       BEGIN TRY
         BEGIN TRANSACTION
		  EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
		  DECLARE @TemplateId INT,@Count INT =0,@UserId INT,@TemplateName VARCHAR(MAX),@DetailID INT,@FormID INT,@moduleID INT,@ViewAccess INT,@InsertAccess INT,@UpdateAccess INT,@DeleteAccess INT,@PrintAccess INT,@IPAddress VARCHAR(MAX)

				SELECT  *
				INTO    #TEMPH
				FROM    OPENXML (@iDocID,'SecurityTemplateViewModel',2)	
				WITH (Id INT , TemplateName VARCHAR(MAX),UserId INT,GroupName VARCHAR(MAX),IpAddress VARCHAR(MAX))
				SELECT TOP(1) @TemplateId=Id,@UserId=UserId,@TemplateName=TemplateName FROM #TempH
			    --get the template details

				SELECT *
				INTO #TempD
				FROM    OPENXML (@iDocID,'SecurityTemplateViewModel/Details/SecuritySet',2)
				WITH (FormId INT,ViewAccess BIT,InsertAccess BIT,UpdateAccess BIT,DeleteAccess BIT,PrintAccess BIT)

			

				CREATE TABLE #TempC(
				FormId INT,UserID INT,ViewAccess BIT,InsertAccess BIT,UpdateAccess BIT,DeleteAccess BIT,PrintAccess BIT
				)

				INSERT INTO #TempC
				(
				    FormId,
				    UserID,
				    ViewAccess,
				    InsertAccess,
				    UpdateAccess,
				    DeleteAccess,
				    PrintAccess
				)
				SELECT 
				FormId,@UserID,InsertAccess,InsertAccess,UpdateAccess,DeleteAccess,PrintAccess
				FROM #TempD
				

				



				UPDATE dbo.AutoGenerateUserPrivileges SET IsViewAccess= T.InsertAccess, IsInsertAccess = T.InsertAccess, IsModifyAccess=T.InsertAccess,IsDeleteAccess=T.InsertAccess,IsPrintAccess=T.InsertAccess
			    FROM dbo.AutoGenerateUserPrivileges AS AT INNER JOIN #TempD AS T ON AT.FormID=T.FormId WHERE AT.UserMasterId=@UserId

				INSERT INTO AutoGenerateUserPrivileges (UserMasterId,
				AutoGenerateID,
				HasBrekdown,
				FormID,
				ModuleID,
				IsViewAccess,
				IsInsertAccess,
				IsModifyAccess,
				IsDeleteAccess,
				IsPrintAccess,
				CreatedUserID,
				LastModUserID,
				CreatedDate,
				LastModDate)
				SELECT
				@UserId,
				AF.Id,
				0,
				T.FormId,
				AF.ModuleType,
				T.ViewAccess,
				T.InsertAccess,
				T.UpdateAccess,
				T.DeleteAccess,
				T.PrintAccess,
				1,
				1 ,
				SYSDATETIME(),
				SYSDATETIME()
				FROM #TempC AS T LEFT JOIN AutoGenerateUserPrivileges AS AT ON  T.UserID=AT.UserMasterId AND T.FormId=AT.FormID INNER JOIN dbo.AutoGenerateInfoes AS 
				AF ON AF.FormId=T.FormId WHERE AT.FormID  IS NULL
				

				
				--End
				select 1 as 'output'
         COMMIT TRANSACTION
 END TRY
   BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 
    END

GO

