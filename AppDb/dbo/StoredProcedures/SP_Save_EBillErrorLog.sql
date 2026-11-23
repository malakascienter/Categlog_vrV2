
CREATE PROCEDURE SP_Save_EBillErrorLog
@OrderNo varchar(6),
@OrderDate DATETIME,
@Outlet VARCHAR(3),
@PropertyId INT,
@Msg VARCHAR(max)
AS
BEGIN


	INSERT INTO [dbo].[EBillErrorLog]
           ([OrderNo]
           ,[OrderDate]
           ,[Outlet]
           ,[ErrorMassage]
           ,[SysDate]
		   ,PropertyId)
     VALUES
           (@OrderNo
           ,@OrderDate
           ,@Outlet
           ,@Msg
           ,GETDATE()
		   ,@PropertyId)
	
	



END

GO

