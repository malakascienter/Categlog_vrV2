
-- =============================================
-- Author		:	Sachith Nuwan Kalehe Watta
-- Create date	:	02/11/2018
-- Description	:	To genetate audit trail doc nos
-- =============================================
CREATE FUNCTION  [dbo].[AuditTrail_GetNextDocNo] 
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

	SELECT @NextNo = NextNo, @Prefix = Prefix, @Length = Length FROM AuditTrail_DocNos WHERE Code = 'LSEQ'

	SELECT @NextNoFormatted = (@Prefix+RIGHT('00000000000000000000000'+CONVERT(NVARCHAR(50),@NextNo), (@Length - LEN(@Prefix))))
	
	RETURN @NextNoFormatted

END

GO

