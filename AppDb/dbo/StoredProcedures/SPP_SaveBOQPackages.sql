

--[dbo].[SPP_SaveBOQPackages] '<BOQPackagesViewModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>0</Id><Description>test </Description><length>200</length><BOQPackagesDetails><BOQPackagesDetails><Id>-1</Id><PackageHeaderId>-1</PackageHeaderId><StockItemId>56</StockItemId><NoOfItems>2</NoOfItems><Average>100</Average></BOQPackagesDetails></BOQPackagesDetails></BOQPackagesViewModel>'
 --select * from boqpackages
 --select * from boqpackagesdetails

 --[dbo].[SPP_SaveBOQPackages] '<BOQPackagesViewModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>0</Id><Description>test</Description><length>1222</length><BOQPackagesDetails><BOQPackagesDetails><Id>-1</Id><PackageHeaderId>-1</PackageHeaderId><StockItemId>56</StockItemId><NoOfItems>22</NoOfItems><Average>55.54545454545455</Average></BOQPackagesDetails></BOQPackagesDetails></BOQPackagesViewModel>'


  --[dbo].[SPP_SaveBOQPackages] '<BOQPackagesViewModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>0</Id><ProjectId>20</ProjectId><Description>test</Description><length>100</length><BOQPackagesDetails><BOQPackagesDetails><Id>-1</Id><PackageHeaderId>-1</PackageHeaderId><StockItemId>56</StockItemId><NoOfItems>2</NoOfItems><Average>50</Average></BOQPackagesDetails></BOQPackagesDetails></BOQPackagesViewModel>'



  --[dbo].[SPP_SaveBOQPackages] '<BOQPackagesViewModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>0</Id><ProjectId>1</ProjectId><Description>BOQ Packages test 123</Description><length>5</length><BOQPackagesDetails><BOQPackagesDetails><Id>-1</Id><PackageHeaderId>-1</PackageHeaderId><StockItemId>349</StockItemId><NoOfItems>34</NoOfItems><Average>0.08823529411764706</Average><LocationId>5</LocationId></BOQPackagesDetails><BOQPackagesDetails><Id>-1</Id><PackageHeaderId>-1</PackageHeaderId><StockItemId>449</StockItemId><NoOfItems>25</NoOfItems><Average>0.2</Average><LocationId>5</LocationId></BOQPackagesDetails></BOQPackagesDetails></BOQPackagesViewModel>'

CREATE PROCEDURE [dbo].[SPP_SaveBOQPackages] @XMLDetails AS XML
AS
    DECLARE @iDocID INT 
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION
            EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

			
            SELECT  *
            INTO    #TEMP1
            FROM    OPENXML (@iDocID,'BOQPackagesViewModel',2)
			WITH (Id INT , ProjectId INT, Description varchar(max),length decimal,LocationId INT )


			Declare @Id INT, @ProjectID INT

			Select top(1) @Id=Id, @ProjectID=ProjectID from #TEMP1



			Select * 
			INTO #TEMP2
			From OPENXML (@iDocID,'BOQPackagesViewModel/BOQPackagesDetails/BOQPackagesDetails',2)
			With(Id INT, PackageHeaderId INT, StockItemId INT, NoOfItems INT, Average DECIMAL(18,2),LocationId INT)





			IF ((Select count(Id) from BOQPackagesDetails Where PackageHeaderId= @Id)>0)
			BEGIN

			delete from BOQPackagesDetails where PackageHeaderId=@Id

			Insert into BOQPackagesDetails ( PackageHeaderId , StockItemId , NoOfItems , Average,LocationId)
		
			select @Id , StockItemId , NoOfItems , Average,LocationId  from #TEMP2


			END

			Else
			BEGIN

			insert into [dbo].[BOQPackages] (ProjectID,Description,length,LocationId)
			select  ProjectID, Description,length,LocationId from #TEMP1 



			Insert into BOQPackagesDetails ( PackageHeaderId , StockItemId , NoOfItems , Average,LocationId)
		
			select SCOPE_IDENTITY(), StockItemId , NoOfItems , Average,LocationId  from #TEMP2


			

			END
           
			























            COMMIT TRANSACTION


        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 





    END

GO

