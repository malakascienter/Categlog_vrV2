
-- =============================================
-- Author:		chiraj
-- Create date: 2020-10-1
-- Description:	SELECT POSTING Types
-- =============================================
--exec PostingTypes_M_Select 2
CREATE PROCEDURE [dbo].[PostingTypes_M_Select]
 @PropertyId INT
AS
BEGIN
	DECLARE @ServerIP NVARCHAR(MAX)
	DECLARE @DBName NVARCHAR(MAX)
	DECLARE @TableName NVARCHAR(MAX)
	DECLARE @Script NVARCHAR(max)

	SET @TableName='PostingTypes'

	SELECT @ServerIP=IPAddress,@DBName=HotelDataBase from [dbo].[Companies] WHERE CompanyID=@PropertyId
	SET NOCOUNT ON;
	SELECT * FROM HotelResWeb.dbo.PostingTypes where Specialposting=1 AND IsActive=1
	END

GO

