
CREATE PROCEDURE ESMSLog_M_Save
	@Token VARCHAR(MAX),
	@RequestBody VARCHAR(MAX),
	@Response VARCHAR(MAX),
	@IsSent BIT,
	@IsFail BIT,
	@TransactionId INT,
	@OrderNo VARCHAR(10),
	@Outlet VARCHAR(5),
	@OrderDate DATETIME,
	@PropertyId INT,
	@UniqueId VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [dbo].[ESMSLog]
           ([OrderNo]
           ,[OrderDate]
           ,[Outlet]
           ,[PropertyId]
           ,[Token]
           ,[Request]
           ,[Response]
           ,[IsSent]
           ,[IsFail]
           ,[TransactionId]
		   ,[UniqueId]
           ,[SysDate])
     VALUES
           (@OrderNo
           ,@OrderDate
           ,@Outlet
           ,@PropertyId
           ,@Token
           ,@RequestBody
           ,@Response
           ,@IsSent
           ,@IsFail
           ,@TransactionId
		   ,@UniqueId
           ,GETDATE())
END

GO

