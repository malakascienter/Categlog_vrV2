-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Active templates as TemplateId + Name, for a dropdown.
--
--              Named LTYC_Template_Lookup to sit with the rest of the template
--              set (LTYC_Template_SelectAll, _Select, _Save, _Publish...), which
--              uses LTYC_{Entity}_{Action} rather than the LTY_{Action}{Entity}
--              the older admin procedures use.
--
--              ONE ROW PER CODE, not per version. LTYC_Template holds every
--              version of a code, so selecting the table directly would put the
--              same template in the list several times over. The newest version
--              of each code wins.
--
--              @Status is worth passing as 'PUBLISHED' wherever the chosen
--              template will actually be sent - a DRAFT is selectable here but
--              LTYC_Dispatch_Queue will not send it. Left open by default so the
--              same procedure can fill an editing list.
-- =============================================
-- EXEC [dbo].[LTYC_Template_Lookup] @PropertyId = 1
-- EXEC [dbo].[LTYC_Template_Lookup] @PropertyId = 1, @Channel = 'EMAIL', @Status = 'PUBLISHED'
CREATE   PROCEDURE [dbo].[LTYC_Template_Lookup]
	@PropertyId INT,
	@Channel VARCHAR(20) = NULL,
	@Status VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SET @Channel = NULLIF(LTRIM(RTRIM(@Channel)), '');
		SET @Status  = NULLIF(LTRIM(RTRIM(@Status)), '');

		SELECT
			t.TemplateId,
			t.Name
			FROM
			LTYC_Template as t
			WHERE PropertyId = @PropertyId
			  AND IsActive   = 1

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

