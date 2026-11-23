
CREATE PROCEDURE [dbo].[SP_AutoGenerateSupplierCode] (@Prefix VARCHAR(20), @CompanyId INT,@Code VARCHAR(10) OUTPUT)

AS
BEGIN
	DECLARE @NextSuppNumber INT
	SELECT @NextSuppNumber = NextSupplierNumber FROM dbo.CommonSettings 

	UPDATE  [dbo].[CommonSettings] SET NextSupplierNumber = NextSupplierNumber + 1 

	SET @Code =  (SELECT right('00000000'+convert(varchar(max),@NextSuppNumber),8))

	SELECT @Code = @Prefix + @Code


END

GO

