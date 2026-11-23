-- =============================================
-- Author		:	Chiraj
-- Create date	:	06/11/2018
-- Description	:	To genetate Menu Item doc nos
-- =============================================
CREATE FUNCTION [dbo].[ButtonCategory_GetNextDocNo] 
(
	@PropertyId INT
)
RETURNS NVARCHAR(50)
AS
BEGIN

	DECLARE @NextNoFormatted	NVARCHAR(50)
	DECLARE @NextNo				NVARCHAR(50)
	DECLARE @Prefix				NVARCHAR(50)
	DECLARE @Length				INT

	SELECT @NextNo = NextNo, @Prefix = Prefix, @Length = Length FROM ButtonCategoryCode_DocNos WHERE PropertyId=@PropertyId

	SELECT @NextNoFormatted = (@Prefix+RIGHT('000'+CONVERT(NVARCHAR(50),@NextNo), (@Length - LEN(@Prefix))))
	
	RETURN @NextNoFormatted

END

GO

