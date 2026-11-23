
--select * from MRNITemregistries
--[dbo].[SPP_InsertMRNItemReg] '<MRNItemRegistry><IPAddress>192.168.1.2</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-07-31T05:19:48.624Z</CreatedDate><LastModDate>2019-07-31T05:19:48.624Z</LastModDate><ID>0</ID><ItemId>474</ItemId><BOQId>49</BOQId><DepId>1</DepId><UnitID>3</UnitID><BOQQuantity>3</BOQQuantity><RequestQuantity>0</RequestQuantity><IssueQuantity>0</IssueQuantity><BalanceQuantity>0</BalanceQuantity><SuspendedQuantity>0</SuspendedQuantity><ProjectID>2</ProjectID></MRNItemRegistry>'

CREATE PROCEDURE [dbo].[SPP_InsertMRNItemReg] (@XMLDetails as XML)
as
declare @iDocID int


BEGIN TRY
	BEGIN TRANSACTION


declare @IPAddress varchar(max), @CreatedUserID int,@LastModUserID int,@ItemId int,@BOQId int,@DepId int,@UnitID int,@BOQQuantity decimal,@ProjectID Int



EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails


SELECT  @IPAddress=IPAddress,@CreatedUserID =CreatedUserID,
@LastModUserID=LastModUserID,@ItemId=ItemId,@BOQId=BOQId,@DepId=DepId,
@UnitID=UnitID,@BOQQuantity=BOQQuantity,@ProjectID=ProjectID
FROM     OPENXML (@iDocID,'/MRNItemRegistry',2)
WITH    (IPAddress varchar(max),CreatedUserID INT,LastModUserID INT,ItemId INT,BOQId INT,DepId INT,UnitID INT,BOQQuantity decimal,ProjectID INT)


select  @IPAddress,@CreatedUserID,
@LastModUserID,@ItemId,@BOQId,@DepId,
@UnitID,@BOQQuantity,@ProjectID



INSERT INTO [dbo].[MRNItemRegistries]
           ([ItemId]
           ,[BOQId]
           ,[DepId]
           ,[BOQQuantity]
           ,[RequestQuantity]
           ,[IssueQuantity]
           ,[BalanceQuantity]
           ,[SuspendedQuantity]
           ,[IPAddress]
           ,[CreatedUserID]
           ,[LastModUserID]
           ,[CreatedDate]
           ,[LastModDate]
           ,[ProjectID]
           ,[UnitID]
           ,[Source])
     VALUES
           (@ItemId, 
             @BOQId, 
             @DepId,
             @BOQQuantity,
             0,
             0, 
             @BOQQuantity, 
             0, 
             '192.168.1.1', 
             1, 
             1, 
             GETDATE(), 
             GETDATE(),
             @ProjectID, 
             @UnitID, 
             'BOQ')





	COMMIT TRAN -- Transaction Success!
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH

GO

