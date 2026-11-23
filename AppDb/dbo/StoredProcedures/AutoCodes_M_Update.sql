-- =============================================
-- Author:		Chamathka Sooriyapalaa
-- Create date: 2021-05-24
-- Description:	Update auto codes
-- =============================================
CREATE PROCEDURE [dbo].[AutoCodes_M_Update] 
	@FileType	VARCHAR(10),
	@CompanyId	INT
AS
BEGIN
	DECLARE @AutoCodeId			INT

	SELECT	@AutoCodeId = Id
	FROM	AutoCodes
	WHERE	FileType = @FileType

	UPDATE	LocationWiseAutoCodes
	SET		NextNo = NextNo + 1	
	WHERE	AutoCodeId = @AutoCodeId AND CompanyID = @CompanyId
END

GO

