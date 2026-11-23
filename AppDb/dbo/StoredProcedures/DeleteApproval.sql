-- [dbo].[DeleteApproval] 33,4168
CREATE Procedure [dbo].[DeleteApproval](@ID INT=5, @userID INT =1 , @result INT =0 OUTPUT)
AS


	declare @SQL Nvarchar(max),
	@IDColumn VARCHAR(50), 
	@FrindlyName Varchar(100),
	@DescriptiveColumn VARCHAR(200),
	@Description VARCHAR(200),
	@TableName VARCHAR(50) ='ApprovalTypes'

	set @result =0;
	IF NOT EXISTS (SELECT 1 FROM [dbo].[TransactionWiseApprovalTypes] WHERE ApprovalTypeID= @ID
	UNION ALL SELECT 1 FROM [dbo].[UserWiseApproveLevels] WHERE ApproveLevelID = @ID )
	BEGIN

	--select 'Delete' result
	 SET @result = 1
	

	SELECT @IDColumn=[IDColumnName],@FrindlyName=FrindlyName, @DescriptiveColumn= [DescriptiveColumnName]
	FROM TableInfo 
	WHERE TableName =@TableName



	SET @SQL='SELECT @Data='  + @DescriptiveColumn + ' FROM '+ @TableName + ' WHERE ' + @IDColumn + '=' + CONVERT(VARCHAR,@ID)
	print @SQL

	IF @SQL IS NOT NULL
	EXEC sp_executesql  @SQL, N'@Data VARCHAR(MAX) OUTPUT', @Data=@Description OUTPUT

	SEt @Description= @FrindlyName + ' - ' + @Description

	EXEC Inventry_AuditTail_WriteToLog 'ApprovalTypes', @ID, 'INV', 'APD', 'D', @userID,1, '', ''
	EXEC InsertMasterFileChangeLog @FrindlyName,@userID, 'D', @Description

	DELETE FROM ApprovalTypes WHERE ID=@ID;

	END
	ELSE
	BEGIN

	SET  @result =2
	
	--SELECT 'found' Result


	END

GO

