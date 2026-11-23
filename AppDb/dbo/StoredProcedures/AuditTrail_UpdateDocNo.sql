
-- =============================================
-- Author		:		Sachith Nuwan Kalehe Watta
-- Create date	:		02/11/2018	
-- Description	:		To update autit trail doc nos
-- =============================================
CREATE PROCEDURE [dbo].[AuditTrail_UpdateDocNo]
	@Code	NVARCHAR(5)
AS
BEGIN
	UPDATE AuditTrail_DocNos
	SET NextNo = NextNo + 1
	WHERE Code = @Code
END

GO

