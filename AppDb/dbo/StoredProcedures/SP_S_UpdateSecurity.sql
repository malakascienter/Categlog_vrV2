
--[dbo].[SP_S_UpdateSecurity] '<SecurityTemplateViewModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>1</Id><TemplateName>ccccc</TemplateName><GroupId>1</GroupId><GroupName>xxxx</GroupName><UserId>1</UserId><IpAddress>192.168.1.160</IpAddress><Details><SecuritySet><FormId>101</FormId><ViewAccess>true</ViewAccess><InsertAccess>true</InsertAccess><UpdateAccess>true</UpdateAccess><DeleteAccess>true</DeleteAccess><PrintAccess>true</PrintAccess><OverridedDefault>true</OverridedDefault></SecuritySet><SecuritySet><FormId>102</FormId><ViewAccess>true</ViewAccess><InsertAccess>true</InsertAccess><UpdateAccess>true</UpdateAccess><DeleteAccess>true</DeleteAccess><PrintAccess>true</PrintAccess><OverridedDefault>true</OverridedDefault></SecuritySet></Details></SecurityTemplateViewModel>',2
CREATE procedure [dbo].[SP_S_UpdateSecurity] @XMLDetails AS XML,@Action INT
AS
    DECLARE @iDocID INT 
    BEGIN
       BEGIN TRY
         BEGIN TRANSACTION
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        Declare @TemplateId INT,@TemplateName varchar(max),@DetailID INT,@FormID INT,@moduleID INT,@ViewAccess INT,@InsertAccess INT,@UpdateAccess INT,@DeleteAccess INT,@PrintAccess INT,@IPAddress varchar(max)

		SELECT  *
				INTO    #TEMP1
				FROM    OPENXML (@iDocID,'SecurityTemplateViewModel',2)	
				WITH (Id INT , TemplateName varchar(max),GroupId INT,GroupName varchar(max),IpAddress varchar(max))
				Select top(1) @TemplateId=Id,@TemplateName=TemplateName from #Temp1

					--get the template details
				Select *
				INTO #Temp2
				FROM    OPENXML (@iDocID,'SecurityTemplateViewModel/Details/SecuritySet',2)
				With (FormId INT,ViewAccess BIT,InsertAccess BIT,UpdateAccess BIT,DeleteAccess BIT,PrintAccess BIT)

		if @Action=1 --update the header and detail both from given data
			BEGIN
					--set the name of the template in case user changed
				update AutoGenerateTemplatebases SET name= @TemplateName where Id=@TemplateId
				
				update TM set 
				TM.DefaultViewAccess = T.ViewAccess, 
				TM.DefaultInsertAccess = T.InsertAccess,
				TM.DefaultModifyAccess = T.UpdateAccess,
				TM.DefaultDeleteAccess = T.DeleteAccess,
				TM.DefaultPrintAccess = T.PrintAccess
				from #Temp2 as T
				inner join AutoGenerateTemplates as TM on T.FormID = TM.FormID and TM.templatebaseid = @TemplateId

				delete from #Temp2 where FormID=@FormID

					
				END
			ELSE IF @Action=2
				BEGIN

				Declare @headerID INT,@Count INT=0

				
			    Select top(1) @TemplateId=Id,@TemplateName=TemplateName,@IPAddress=IPAddress from #Temp1

				

				insert into AutoGenerateTemplatebases (Name,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate)
				values(@TemplateName,@IPAddress,1,1,SYSDATETIME(),SYSDATETIME())

				SET @headerID= SCOPE_IDENTITY()
				
				
				insert into AutoGenerateTemplates(
				Name,
				IPAddress,
				CreatedUserID,
				LastModUserID,
				CreatedDate,
				LastModDate,
				AutoGenerateID,
				FormID,
				ModuleID,
				DefaultViewAccess,
				DefaultInsertAccess,
				DefaultModifyAccess,
				DefaultDeleteAccess,
				DefaultPrintAccess,
				TemplateBaseId)
				select 
				@TemplateName,
				@IPAddress,
				1,
				1,
				SYSDATETIME(),
				SYSDATETIME(),
				TM.id,
				T.FormID,
				TM.ModuleType,
				T.ViewAccess,
				T.InsertAccess,
				T.UpdateAccess,
				T.DeleteAccess,
				T.PrintAccess,
				@headerID
				from #Temp2 as T
				inner join AutoGenerateInfoes as TM on T.FormID = TM.FormID 
			
				END

            COMMIT TRANSACTION


 END TRY
   BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 





    END

GO

