-- =============================================
-- Author		:	Chiraj
-- Create date	:	06/11/2018
-- Description	:	To genetate Menu Item doc nos
-- =============================================
CREATE FUNCTION [dbo].[MainMenu_GetNextDocNo] 
(
	@Code	NVARCHAR(5),
	@PropertyId INT
)
RETURNS NVARCHAR(50)
AS
BEGIN

	DECLARE @NextNoFormatted	NVARCHAR(50)
	DECLARE @NextNo				NVARCHAR(50)
	DECLARE @Prefix				NVARCHAR(50)
	DECLARE @Length				INT
	DECLARE @ClassificationWiseCategoryEnable BIT
	DECLARE @IsCentralMenuCodeEnable BIT

	SELECT @ClassificationWiseCategoryEnable = ClassificationWiseCategoryEnable,@IsCentralMenuCodeEnable = IsCentralMenuCodeEnable
	FROM Companies WHERE CompanyID = @PropertyId

	DECLARE @Classification01Id	INT


		IF( @IsCentralMenuCodeEnable = 0 )
		BEGIN


			IF( @ClassificationWiseCategoryEnable = 1)
			BEGIN

				SELECT @Classification01Id = Classification01Id FROM Category WHERE Code = @Code AND PropertyId = @PropertyId
				SELECT @NextNo = NextNo, @Prefix = Prefix, @Length = Length FROM POS_Classification01 WHERE Id = @Classification01Id


			END
			ELSE
			BEGIN

				SELECT @NextNo = NextNo, @Prefix = Prefix, @Length = Length FROM MainMenuItemCode_DocNos WHERE Code = @Code AND PropertyId=@PropertyId

			END 

		END
		ELSE
		BEGIN

				SELECT @NextNo = NextMenuNo, @Prefix = MenuPrefix, @Length = MenuLength FROM Companies WHERE CompanyID=@PropertyId

		END


	SELECT @NextNoFormatted = (@Prefix+RIGHT('000'+CONVERT(NVARCHAR(50),@NextNo), (@Length - LEN(@Prefix))))
	
	RETURN @NextNoFormatted

END

GO

