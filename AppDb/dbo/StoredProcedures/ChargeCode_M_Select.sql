
-- =============================================
-- Author:		Chiraj
-- Create date: 2020-10-8
-- Description:	Select Charge Codes
-- =============================================
--ChargeCode_M_Select 2
CREATE PROCEDURE [dbo].[ChargeCode_M_Select]
	@PropertyId INT
AS
BEGIN
	DECLARE @ServerIP NVARCHAR(MAX)
	DECLARE @DBName NVARCHAR(MAX)
	DECLARE @TableName NVARCHAR(MAX)
	DECLARE @Script NVARCHAR(max)

	SET NOCOUNT ON;
	SELECT @ServerIP=IPAddress,@DBName=HotelDataBase from [dbo].[Companies] WHERE CompanyID=@PropertyId
	SET @TableName='ChargeCodes'

	SET @Script='
		SELECT TOP (1000) [Id]
      ,[Name]
      ,[IsActive]
      ,[Prefix]
      ,[CreatedUserId]
      ,[CreatedDateTime]
      ,[LastEditedUserId]
      ,[LastEditedDateTime]
      ,[RevenueType]
	 FROM ['+@ServerIP+'].'+@DBName+'.dbo.'+@TableName+' WHERE RevenueType=''F'' AND IsActive=''1'''
     exec sp_executesql @script






END

GO

