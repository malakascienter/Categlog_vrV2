-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_UpdateUserIsUploadStatus]
	@PropertyId INT,
	@UserId INT
AS
BEGIN

	SET NOCOUNT ON;

    UPDATE	Users 
	SET		IsUpload = 0
	WHERE	Id = @UserId AND PropertyId = @PropertyId

END

GO

