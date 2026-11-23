-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,> 
-- Description:	<Description,,>
-- [dbo].[sp_GetSupplierCategories] -999

-- =============================================
CREATE PROCEDURE [dbo].[sp_GetSupplierCategories]
@ID INT,
@Mode CHAR(4)
AS
BEGIN
	SET NOCOUNT ON;

	IF(@Mode = 'A')
	BEGIN
	SELECT ID,SupplierCategoryCode,SupplierCategoryName,IsActive,CreatedUserID,LastModUserID,CreatedDate,LastModDate
	FROM SupplierCategory SU
	WHERE SU.ID = CASE WHEN @ID = -999 THEN ID ELSE @ID END
	END

	IF(@Mode = 'S')
	BEGIN
	SELECT ID,SupplierCategoryCode,SupplierCategoryName,IsActive,CreatedUserID,LastModUserID,CreatedDate,LastModDate
	FROM SupplierCategory SU
	WHERE SU.ID = CASE WHEN @ID = -999 THEN ID ELSE @ID END
	AND IsActive =1

	END

END

GO

