-- =============================================
-- Author:		Chiraj
-- Create date: 2020-6-17
-- Description:	POSAccessCode_M_Select
--  [dbo].[RT_POSAccessCode_M_Select] 1
-- =============================================
create PROCEDURE [dbo].[RT_POSAccessCode_M_Select]-- 1
@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    SELECT 
	Id,
	LTRIM(RTRIM(AccessCode))AS AccessCode,DisplayName,0 IsCheck
	FROM RT_POS_AccessCodes
	WHERE Active=1 AND PropertyId=@PropertyId order by SortOrder
END

GO

