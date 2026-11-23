CREATE Procedure [dbo].[PrepareDataForDeletelogAndDelete_New]( @TableName varchar(100)='Categories', @ID INT=5, @UserID INT =1)
AS


declare @SQL Nvarchar(max), @IDColumn VARCHAR(50), @FrindlyName Varchar(100), @DescriptiveColumn VARCHAR(200), @Description VARCHAR(200)

SELECT @IDColumn=[IDColumnName],@FrindlyName=FrindlyName, @DescriptiveColumn= [DescriptiveColumnName]
FROM TableInfo 
WHERE TableName =@TableName


SET @SQL='SELECT @Data='  + @DescriptiveColumn + ' FROM '+ @TableName + ' WHERE ' + @IDColumn + '=' + CONVERT(VARCHAR,@ID)
print @SQL

IF @SQL IS NOT NULL
EXEC sp_executesql  @SQL, N'@Data VARCHAR(MAX) OUTPUT', @Data=@Description OUTPUT

SEt @Description= @FrindlyName + ' - ' + @Description

EXEC InsertMasterFileChangeLog @FrindlyName,@UserID, 'D', @Description


EXEC Inventry_AuditTail_WriteToLog 'Suppliers', @ID, 'INV', 'SUD', 'D', @UserID,1, '', ''
DELETE 
FROM 
Suppliers 
WHERE Suppliers.ID =@ID

GO

