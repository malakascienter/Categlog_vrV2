-- =============================================
-- Author		:	Nivesh
-- Create date	:	2024-02-16
-- Description	:	
-- =============================================
CREATE FUNCTION [dbo].[InvGetNextDocNo]  --'TIBE'
(
	@Code VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN
	
	DECLARE @DocNo	VARCHAR(50)
	DECLARE @NextNo INT
	DECLARE @Length INT
	DECLARE @Prefix NVARCHAR(10)

	SELECT TOP 1 @Prefix = [Prefix],@NextNo=[NextNo],@Length=[Length] FROM [dbo].[DocumentNumbers] WHERE Code = @Code
	SET @DocNo = @Prefix+RIGHT('000000000',  @Length-LEN(@Prefix)-LEN(@NextNo))+ CONVERT(VARCHAR(10), @NextNo)
	
	RETURN @DocNo

END

GO

