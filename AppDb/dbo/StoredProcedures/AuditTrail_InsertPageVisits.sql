-- =============================================
-- Author		:	Sachith Nuwan Kalehe Watta
-- Create date	:	02/11/2018
-- Description	:	To insert audit trail page visits
-- =============================================
CREATE PROCEDURE [dbo].[AuditTrail_InsertPageVisits]
	@UserId			INT, 
	@PropertyId		INT,
	@PageId			INT, 
	@ActionType		CHAR(1), 
	@Remark			NVARCHAR(250)
AS
BEGIN
	
	DECLARE @Code NVARCHAR(50)
	SELECT @Code = dbo.AuditTrail_GetNextDocNo('LSEQ')

	INSERT INTO [dbo].[AuditTrail_Log]
	([Code], [UserId], [PageId], [ActionType],[Remark])
	VALUES (@Code,@UserId,@PageId,@ActionType,@Remark)

	EXEC [dbo].[AuditTrail_UpdateDocNo] 'LSEQ'

	IF EXISTS (SELECT * FROM AuditTrail_UserWisePageVisitCount WHERE PageId = @PageId AND UserId = @UserId)
	BEGIN
		UPDATE[dbo].[AuditTrail_UserWisePageVisitCount]
		SET [NoOfVisits] = ISNULL(NoOfVisits,0) + 1
		WHERE PageId = @PageId AND UserId = @UserId
	END
	ELSE
	BEGIN
		INSERT INTO [dbo].[AuditTrail_UserWisePageVisitCount]
		([UserId], [PageId], [NoOfVisits])
		VALUES (@UserId, @PageId, 1)
	END

	
	

		  
END

GO

