
-- =============================================
-- Author		:	Chiraj
-- Create date	:	06/11/2018
-- Description	:	Get_DocumentNo_By_Code] 
-- =============================================
CREATE FUNCTION  [dbo].[Get_DocumentNo_By_Code] 
(
	@Code	NVARCHAR(5)
)
RETURNS NVARCHAR(50)
AS
BEGIN

	DECLARE @NextNoFormatted	NVARCHAR(50)
	DECLARE @NextNo				NVARCHAR(50)
	DECLARE @Prefix				NVARCHAR(50)
	DECLARE @Length				INT

	SELECT @NextNo = NextNo, @Prefix = Prefix, @Length = Length FROM DocTypes WHERE Code = @Code

	SELECT @NextNoFormatted = (@Prefix+RIGHT('000000000000'+CONVERT(NVARCHAR(50),@NextNo), (@Length - LEN(@Prefix))))
	
	RETURN @NextNoFormatted

END

GO

