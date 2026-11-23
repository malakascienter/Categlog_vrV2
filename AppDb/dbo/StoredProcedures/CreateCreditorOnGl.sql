
 
 --exec CreateCreditorOnGl 2
 --select * from Suppliers

CREATE PROCEDURE [dbo].[CreateCreditorOnGl](@SupplierID int)
as
DECLARE @Object AS INT;
DECLARE @ResponseTable AS TABLE(ResponseValue VARCHAR(MAX))
 
DECLARE @ResponseText AS VARCHAR(8000);
DECLARE @RequestLength AS INT, @RequestBody VARCHAR(1000), @description VARCHAR(255)

declare @BSPCode varchar(50),@email varchar(500), @Address1 varchar(500), @Address2 varchar(500),@Fname varchar(500),
		@Tele01 varchar(50),@Tele02 varchar(50),@Tele03 varchar(50)

Select  @BSPCode=code,@email=Email,@Address1=Address1,@Fname=Name,
		@Tele01= Telephone1, @Tele02=Telephone2, @Tele03 = Telephone1
from Suppliers c  
where c.ID=@SupplierID



if @bspCode is null
begin
	return 0
end 


set @RequestBody='{"UserID":"b490b26a-2886-4671-8253-a8644c76660f",
"Operation":"I",
"BPDataList":[{"Code":"'+@BSPCode+'",
               "DOB":"2000-10-28",
               "Occupation":"Occupation",
               "TaxFileNo":"TaxFileNo",
               "Title":"10",
               "CustType":"C",
               "Gender":"M",
               "NICNo":"951118947V",
               "PassportNumber":"",
               "BRNo":"AR54564",
               "DLNo":"gf41614",
               "Email":"'+ @email +'",
               "Addr1":"'+@Address1+'",
               "Addr2":"'+@Address1+'",
               "Addr3":"-",
               "Add4":"-",
               "UpLoad":true,
               "FirstName":"' + @Fname + '",
               "LastName":" ",
               "OtherNames":" ",
               "TelOffice":"'+@Tele01+'",
               "TellResidence":"'+@Tele03+'",
               "Mobile":"'+ @Tele02  +'",
               "Fax":"'+@Tele01+'",
               "CreditorType":"G",
               "CrPeriod":10,
               "Status":5,
               "APTypeID":2,
               "HoldSupplier":false,
               "TINno":"CR343465151",
               "ARTypeID":1}]}'
 
 --select   @RequestBody
 
--Code Snippet
Exec sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
Exec sp_OAMethod @Object, 'open', NULL, 'post','https://finance-api.pms.jetwinghotels.com/api/PopulateBusinessPartner','false'
EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json'
EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Accept', 'application/json'

EXEC sp_OAMethod @Object, 'send', NULL, @RequestBody
EXEC sp_OAGetErrorInfo @object, NULL, @ResponseText OUT
INSERT INTO @ResponseTable( ResponseValue ) 
EXEC sp_OAMethod @Object, 'responseText'

EXEC sp_OAGetErrorInfo @object, NULL, @description OUT


select @object,@description, * from @ResponseTable

GO

