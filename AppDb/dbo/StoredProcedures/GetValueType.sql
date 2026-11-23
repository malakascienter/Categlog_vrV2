-- =============================================
-- Author:		Nivesh
-- Create date: 2025-01-02
-- Description:	Get Period types
-- =============================================
-- GetValueType
CREATE PROCEDURE [dbo].[GetValueType]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT Id id,ValueType text FROM ValueType
END

GO

