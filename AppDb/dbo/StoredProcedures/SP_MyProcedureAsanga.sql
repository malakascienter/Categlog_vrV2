

--SP_MyProcedureAsanga 10
--select * from Banks

CREATE PROCEDURE SP_MyProcedureAsanga 
	@Age int
AS
BEGIN
BEGIN TRY
begin tran


INSERT INTO [dbo].[Banks]
           ([Bank_Code]
           ,[Bank_Name]
           ,[IPAddress]
           ,[CreatedUserID]
           ,[LastModUserID]
           ,[CreatedDate]
           ,[LastModDate])
     VALUES
           ('Code0','Apath Bank','192.168.1.120',1,1,GETDATE() , GETDATE())
select SCOPE_IDENTITY()


INSERT INTO [dbo].[Banks]
           ([Bank_Code]
           ,[Bank_Name]
           ,[IPAddress]
           ,[CreatedUserID]
           ,[LastModUserID]
           ,[CreatedDate]
           ,[LastModDate])
     VALUES
           ('Code0','Sapatha Bank','192.168.1.120',1,1,GETDATE() , GETDATE())
select SCOPE_IDENTITY()

commit tran

end try
BEGIN CATCH

rollback tran
select ERROR_MESSAGE()

END CATCH

END

GO

