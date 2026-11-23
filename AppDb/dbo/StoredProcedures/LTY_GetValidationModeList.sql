-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Resolve a field's lookup source to its selectable list.
-- =============================================
-- EXEC [dbo].[LTY_GetValidationModeList] @Source = 'ITM', @PropertyId = 1
-- EXEC [dbo].[LTY_GetValidationModeList] @Source = 'ITM', @PropertyId = 1, @SearchText = 'OB17'
CREATE   PROCEDURE [dbo].[LTY_GetValidationModeList]
	@Source VARCHAR(50),
	@PropertyId INT,
	@SearchText NVARCHAR(200) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		-- Built once so every branch shares the same behaviour. NULL means no filter.
		DECLARE @Pattern NVARCHAR(202) =
			CASE WHEN NULLIF(LTRIM(RTRIM(@SearchText)), '') IS NULL
				 THEN NULL
				 ELSE '%' + LTRIM(RTRIM(@SearchText)) + '%' END;

		IF (@Source = 'ITM')
		BEGIN
			SELECT TOP (100)
				m.ItemCode    AS Code,
				m.Description AS Description
			FROM [dbo].[MainMenu] AS m
			WHERE m.PropertyId = @PropertyId
			  AND m.Active     = 1
			  AND (@Pattern IS NULL
				   OR m.ItemCode    LIKE @Pattern
				   OR m.Description LIKE @Pattern)
			ORDER BY m.Description;
		END
		ELSE IF (@Source = 'CAT')
		BEGIN
			SELECT TOP (100)
				c.Code        AS Code,
				c.Description AS Description
			FROM [dbo].[Category] AS c
			WHERE c.PropertyId = @PropertyId
			  AND c.Active     = 1
			  AND (@Pattern IS NULL
				   OR c.Code        LIKE @Pattern
				   OR c.Description LIKE @Pattern)
			ORDER BY c.Description;
		END
		IF (@Source = 'FREEITEM')
		BEGIN
			SELECT TOP (100)
				m.ItemCode    AS Code,
				m.Description AS Description
			FROM [dbo].[MainMenu] AS m
			WHERE m.PropertyId = @PropertyId
			  AND m.Active     = 1
			  AND (@Pattern IS NULL
				   OR m.ItemCode    LIKE @Pattern
				   OR m.Description LIKE @Pattern)
			ORDER BY m.Description;
		END
		IF (@Source = 'POINTITEM')
		BEGIN
			SELECT TOP (100)
				m.ItemCode    AS Code,
				m.Description AS Description
			FROM [dbo].[MainMenu] AS m
			WHERE m.PropertyId = @PropertyId
			  AND m.Active     = 1
			  AND (@Pattern IS NULL
				   OR m.ItemCode    LIKE @Pattern
				   OR m.Description LIKE @Pattern)
			ORDER BY m.Description;
		END
		ELSE
		BEGIN
			-- Unknown source, or a field that needs no list. Correct columns, no rows.
			SELECT CONVERT(VARCHAR(50), NULL)   AS Code,
			       CONVERT(NVARCHAR(200), NULL) AS Description
			WHERE 1 = 0;
		END

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

