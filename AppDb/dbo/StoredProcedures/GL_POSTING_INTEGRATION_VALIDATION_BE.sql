-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE GL_POSTING_INTEGRATION_VALIDATION_BE 
	@XMLDATA AS XML
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @OUTPUTREQ VARCHAR(MAX)

	EXEC  [eFinancials_Accounting]..[GL_POSTING_INTEGRATION_VALIDATION] @XMLDATA,@OUTPUTREQ OUTPUT

	
	IF( @OUTPUTREQ = 'PASS' )
	BEGIN
	SELECT 1
	END
	ELSE
	BEGIN
	SELECT 0
	END

   
END

GO

