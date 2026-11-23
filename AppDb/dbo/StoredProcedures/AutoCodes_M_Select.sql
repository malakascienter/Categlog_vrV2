-- =============================================
-- Author:		Chamathka Sooriyapala
-- Create date: 2021-05-24
-- Description:	Get company wise file codes
-- =============================================
--AutoCodes_M_Select 'ITMWASTAGE', 1
CREATE PROCEDURE [dbo].[AutoCodes_M_Select] 
	@FileType	VARCHAR(10),
	@CompanyId	INT
AS
BEGIN
	
	DECLARE @AutoCodeId			INT,
			@CodeLenth			INT,
			@Prefix				VARCHAR(5),
			@IsPrefixAllowed	BIT,
			@NextNo				INT,
			@CalcCodeLength		INT

	SELECT	@AutoCodeId = Id, @CodeLenth = CodeLength, @Prefix = Prefix, @IsPrefixAllowed = IsPrefixAllowed
	FROM	AutoCodes
	WHERE	FileType = @FileType

	SELECT	@NextNo = NextNo
	FROM	LocationWiseAutoCodes
	WHERE	AutoCodeId = @AutoCodeId AND CompanyID = @CompanyId

	--UPDATE LocationWiseAutoCodes
	--SET NextNo = NextNo + 1
	--WHERE	AutoCodeId = @AutoCodeId AND CompanyID = @CompanyId

	SET @CalcCodeLength = @CodeLenth - LEN(RTRIM(@NextNo)) - (CASE WHEN @IsPrefixAllowed = 1 THEN LEN(RTRIM(@Prefix)) ELSE 0 END)

	SELECT CASE WHEN @IsPrefixAllowed = 1 THEN @Prefix ELSE '' END + REPLICATE('0',@CalcCodeLength) + RTRIM(@NextNo) AS Code
END

GO

