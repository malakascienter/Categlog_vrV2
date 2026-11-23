--SP_GetSignatureImage 476,'ss'
--select * from CustomerSignatures
CREATE PROCEDURE [dbo].[SP_GetSignatureImage]
@Id INT, @Name VARCHAR(max) 
AS
BEGIN

declare @Filename VARCHAR(max) 

SELECT @Filename=c.ImageFileName FROM dbo.CustomerSignatures AS c WHERE CustomerId=@Id


SELECT @Filename



END

GO

