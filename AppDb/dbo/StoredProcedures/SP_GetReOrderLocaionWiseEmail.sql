-- =============================================
-- Author:		Nivesh
-- Create date: 2026-01-13
-- Description:	Get reorder location-wise email
-- =============================================
CREATE     PROCEDURE [dbo].[SP_GetReOrderLocaionWiseEmail] 
	@CompanyId INT,
	@LocaionId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		Id,
		LTRIM(RTRIM(value)) AS Email,
		LastDocNo,
		LastSentStatus,
		CONVERT(DATE,LastSentDate) AS LastSentDate,
		IsActive
	FROM
	[dbo].[ReOrderLocationWiseEmail] ROL
	CROSS APPLY STRING_SPLIT(EmailList, ',')
	WHERE ROL.LocationID = @LocaionId
		AND ROL.CompanyID = @CompanyId
END

GO

