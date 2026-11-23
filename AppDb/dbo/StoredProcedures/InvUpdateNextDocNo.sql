-- =============================================
-- Author:		Nivesh
-- Create date: 2024-02-16
-- Last Modify by	: Nivesh
-- Last Modified date : 2026-01-09
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[InvUpdateNextDocNo]
	@Code VARCHAR(MAX)
AS
BEGIN
	
	DECLARE @NextNo BIGINT =0,
	@MaxNextNum BIGINT = 2147483647

	SELECT 
		@NextNo = NextNo 
	FROM
	[dbo].[DocumentNumbers]
	WHERE Code = @Code

	IF((@NextNo+1) > @MaxNextNum) 
	BEGIN
		SET @NextNo = 0
	END

	UPDATE [dbo].[DocumentNumbers]
	SET [NextNo] = @NextNo+1
	WHERE Code = @Code

END

GO

