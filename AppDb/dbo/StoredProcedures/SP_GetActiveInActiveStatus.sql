-- =============================================
-- Author:		Nivesh
-- Create date: 2026-06-01
-- Description:	Get Active Inactive Status
-- =============================================
CREATE     PROCEDURE [dbo].[SP_GetActiveInActiveStatus] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @TempActiveInActive TABLE(
		id INT,
		text VARCHAR(20)
	)

	INSERT INTO @TempActiveInActive(id, text)
	VALUES (1 , 'Active')
	INSERT INTO @TempActiveInActive(id, text)
	VALUES (0 , 'In Active')
	INSERT INTO @TempActiveInActive(id, text)
	VALUES (-999 , 'All')

	SELECT 
	* 
	FROM @TempActiveInActive
	ORDER BY id
END

GO

