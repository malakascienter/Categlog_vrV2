-- =============================================
-- Author:		chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[POSAccessCode_M_Save]
	@AccessCodes NVARCHAR(MAX),
	@PropertyId INT,
	@UserId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT * 
	INTO #TempAccess	
	FROM OPENJSON(@AccessCodes,N'$.AccessCodeLst')  
	WITH 
	(	
		AccessCodeId				INT			'$.AccessCodeId'
		
	) 


	DELETE FROM [POS_UserAccessTemp] WHERE PropertyId=@PropertyId AND UserId=@UserId
    INSERT INTO [dbo].[POS_UserAccessTemp](UserId, AccessCodeId, PropertyId, CreatedUserId, CreatedDateTime,IsUpload)
	SELECT @UserId,AccessCodeId, @PropertyId,@UserId,GETDATE(),0 FROM #TempAccess
	UPDATE Users SET IsUpload=0
	WHERE Id=@UserId AND PropertyId=@PropertyId
END

GO

