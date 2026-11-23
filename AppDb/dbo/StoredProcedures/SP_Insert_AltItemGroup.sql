CREATE PROCEDURE 
[dbo].[SP_Insert_AltItemGroup]--'<AltItemGroup xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><IPAddress>192.168.0.0</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-02-28T18:01:26.21</CreatedDate><LastModDate>2018-02-28T18:01:26.21</LastModDate><Id>1</Id><GropCOde>G003</GropCOde><GropName>aaa</GropName><AltItemGroupDetailList><AltItemGroupDetails><IPAddress>192.168.0.0</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-02-28T18:01:26.21</CreatedDate><LastModDate>2018-02-28T18:01:26.21</LastModDate><ID>1</ID><GroupID>1</GroupID><ItemId>1</ItemId></AltItemGroupDetails><AltItemGroupDetails><IPAddress>1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-02-28T18:01:26.21</CreatedDate><LastModDate>2018-02-28T18:01:26.21</LastModDate><ID>2</ID><GroupID>1</GroupID><ItemId>2</ItemId></AltItemGroupDetails></AltItemGroupDetailList></AltItemGroup>',1
(
	@XMLDetails XML,
	@Operation INT
)
AS
declare @iDocID int


BEGIN



BEGIN TRY
	BEGIN TRANSACTION
--insert into mhpxml(data, opration) values(@XMLDetails,@Operation)

declare					
						@Id int ,
						@GropCOde varchar(max),
						@GropName varchar(max),
						@IPAddress varchar(max),
						@CreatedUserID int,
						@LastModUserID int,
						@CreatedDate datetime,
						@LastModDate datetime,
						@GroupID int,
						@ItemId int,
						@AltItemGroupsIDIntern int,
						@AltItmGrID int,
						@PropertyID int,
						@LocationID int,
						@DepartmentID int

Create table #ItemList
						(Id int ,
						GropCOde varchar(max),
						GropName varchar(max),
						IPAddress varchar(max),
						CreatedUserID int,
						LastModUserID int,
						CreatedDate datetime,
						LastModDate datetime,
						GroupID int,
						ItemId int
						)

EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails


SELECT  @GropCOde=GropCOde,@GropName =GropName , @IPAddress=IPAddress,@CreatedUserID=CreatedUserID, @LastModUserID=LastModUserID, @CreatedDate=CreatedDate, @LastModDate=LastModDate, @PropertyID=PropertyID,@LocationID= LocationID, @DepartmentID=DepartmentID
FROM     OPENXML (@iDocID,'/AltItemGroup',2)
WITH    ( GropCOde varchar(max), GropName varchar(max) , IPAddress varchar(max),CreatedUserID int , LastModUserID int , CreatedDate datetime , LastModDate datetime , PropertyID int , LocationID int , DepartmentID int)


SELECT @AltItemGroupsIDIntern=GroupID,@ItemId=ItemId
FROM     OPENXML (@iDocID,'/AltItemGroup/AltItemGroupDetailList/AltItemGroupDetails',2)
with   (GroupID int,ItemId int)


insert into #ItemList
SELECT   *
FROM     OPENXML (@iDocID,'/AltItemGroup',2)
WITH  #ItemList

/*SELECT * FROM #ItemList
SELECT   *
FROM     OPENXML (@iDocID,'/AltItemGroup',2)
*/

IF @Operation=1

BEGIN

--**********insert record to AltItemGroups ***************************************************************
/*insert into AltItemGroups
		(GropCOde,GropName,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate)
SELECT  GropCOde,GropName,IPAddress,1,1,GETDATE(),GETDATE()
FROM #ItemList
*/


insert into AltItemGroups 
		(GropCOde,GropName,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate,PropertyID,LocationID,DepartmentID)
SELECT  GropCOde,GropName,IPAddress,1,1,GETDATE(),GETDATE(),@PropertyID,@LocationID,@DepartmentID
FROM     OPENXML (@iDocID,'/AltItemGroup',2)
with AltItemGroups

--***** get inserted id 
SET @AltItemGroupsIDIntern =  SCOPE_IDENTITY()
Select @GropCOde=GropCOde , @GropName = GropName , @AltItmGrID = @AltItemGroupsIDIntern
FROM    #ItemList

--**********insert record to AltItemGroupDetails ***************************************************************
/*INSERT into AltItemGroupDetails(GroupID,ItemId,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate)
SELECT  @AltItemGroupsIDIntern,
					   #ItemList.ItemId,GroupID,1,1,GETDATE(),GETDATE()
FROM   #ItemList 
*/

insert into AltItemGroupDetails 
		(GroupID,ItemId,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate)
SELECT  @AltItemGroupsIDIntern,ItemId,IPAddress,@CreatedUserID,@LastModUserID,GETDATE(),GETDATE()
FROM     OPENXML (@iDocID,'/AltItemGroup/AltItemGroupDetailList/AltItemGroupDetails',2)
with AltItemGroupDetails
--inner Join Locations  ON #ItemList.GroupID  = Locations.CompanyID--have to check


/*--**********insert record to SupplierWiseItemDetails ***************************************************************
insert into SupplierWiseItemDetails(CompanyId,LocationId,SupplierID,StockItemID,PurchaseUnitID,CostPrice,IsDefaultSupplier,CreatedUserID,LastModUserID,CreatedDate,LastModDate,IPAddress)
					SELECT @PropertyID,@LocationID,SuppID,@StockItemID,UnitId,CostPrice,IsDefaultsupplier,1,1,GETDATE(),GETDATE(),''
FROM     OPENXML (@iDocID,'/ProductSaveModel/SupplierList/SupplierViewModel',2)
with (SuppID INT ,StockItemID INT, UnitId INT , CostPrice DECIMAL,IsDefaultsupplier bit)

--**********insert record to StockItemWiseClassificationDetails ***************************************************************

insert into StockItemWiseClassificationDetails(CompanyId,LocationId,StockItemHeaderID,ItemClassificationHeaderID,ItemClassificationDetailID,IsActive,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate)
					SELECT @PropertyID,@LocationID,@StockItemID,HeadID,DeatailID,1,'',1,1,GETDATE(),GETDATE()
FROM     OPENXML (@iDocID,'/ProductSaveModel/ReferencesList/ReferencesViewModel',2)
with (HeadID INT ,DeatailID INT)

--**********insert record to StockItemWiseAttributes **************************************************************************

insert into StockItemWiseAttributes(CompanyId,LocationId,StockItemHeaderID,StockItemAttributeID,Remarks,IsActive,CreatedUserID,LastModUserID,CreatedDate,LastModDate,IPAddress)
					SELECT @PropertyID,@LocationID,@StockItemID,AttributeID,Remarks,1,1,1,GETDATE(),GETDATE(),''
FROM     OPENXML (@iDocID,'/ProductSaveModel/AttributeList/AttributeViewModel',2)
with (AttributeID INT ,Remarks VARCHAR(MAX))

*/

END

ELSE 

BEGIN
         SELECT @AltItmGrID=Id,@GropCOde=GropCOde,@GropName=GropName,@IPAddress=IPAddress
		   FROM #ItemList

		   Select @AltItmGrID = Id
           FROM    #ItemList

		UPDATE dbo.AltItemGroups
	
		SET
			GropCOde					=	@GropCOde,
			GropName					=	@GropName,
			--GroupID					=	@GroupID,
			--ItemId					=	@ItemId,
			IPAddress					=	@IPAddress,
			CreatedUserID				=   @CreatedUserID,
			LastModUserID				=	@LastModUserID,
			CreatedDate					=   GETDATE(),
			LastModDate					=	GETDATE(),
			PropertyID					=	@PropertyID,
			LocationID					=	@LocationID,
			DepartmentID				=	@DepartmentID
			--LastModUserID				=	@LastModUserID,
			--IsExpiryDateApplicable      =   @IsExpiryDateApplicable
		
		WHERE Id				=	@AltItmGrID

		--DELETE FROM dbo.AltItemGroups WHERE Id=@AltItmGrID

		/*insert into SupplierWiseItemDetails(CompanyId,LocationId,SupplierID,StockItemID,PurchaseUnitID,CostPrice,IsDefaultSupplier,CreatedUserID,LastModUserID,CreatedDate,LastModDate,IPAddress)
					SELECT @PropertyID,@LocationID,SuppID,@StockItemID,UnitId,CostPrice,IsDefaultsupplier,1,1,GETDATE(),GETDATE(),''
        FROM     OPENXML (@iDocID,'/ProductSaveModel/SupplierList/SupplierViewModel',2)
        WITH (SuppID INT ,StockItemID INT, UnitId INT , CostPrice DECIMAL,IsDefaultsupplier bit)

		DELETE FROM dbo.StockItemWiseClassificationDetails WHERE StockItemHeaderID=@StockItemID

		insert into StockItemWiseClassificationDetails(CompanyId,LocationId,StockItemHeaderID,ItemClassificationHeaderID,ItemClassificationDetailID,IsActive,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate)
					SELECT @PropertyID,@LocationID,@StockItemID,HeadID,DeatailID,1,'',1,1,GETDATE(),GETDATE()
        FROM     OPENXML (@iDocID,'/ProductSaveModel/ReferencesList/ReferencesViewModel',2)
        WITH (HeadID INT ,DeatailID INT)

		DELETE FROM dbo.StockItemWiseAttributes WHERE StockItemHeaderID=@StockItemID
		insert into StockItemWiseAttributes(CompanyId,LocationId,StockItemHeaderID,StockItemAttributeID,Remarks,IsActive,CreatedUserID,LastModUserID,CreatedDate,LastModDate,IPAddress)
	    SELECT @PropertyID,@LocationID,@StockItemID,AttributeID,Remarks,1,1,1,GETDATE(),GETDATE(),''
        FROM     OPENXML (@iDocID,'/ProductSaveModel/AttributeList/AttributeViewModel',2)
        WITH (AttributeID INT ,Remarks VARCHAR(MAX)) 

*/

--delete  from AltItemGroupDetails where GroupID = @AltItmGrID

insert into AltItemGroupDetails 
		(GroupID,ItemId,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate)
SELECT  @AltItmGrID,ItemId,IPAddress,@CreatedUserID,@LastModUserID,GETDATE(),GETDATE()
FROM     OPENXML (@iDocID,'/AltItemGroup/AltItemGroupDetailList/AltItemGroupDetails',2)
with AltItemGroupDetails
		
END




	COMMIT TRAN -- Transaction Success!
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH




END









--select * from SupplierWiseItemDetails

GO

