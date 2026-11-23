-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-08-23
-- Description:	GRN type select
-- [dbo].[SP_Select_GRNTypes] -999
-- =============================================
CREATE PROCEDURE [dbo].[SP_Select_GRNTypes]
	@ID INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT ID id, Name text, IsActive
	FROM     GRNTypes
	WHERE ID = CASE WHEN @ID = -999 THEN ID ELSE @ID END
END

GO

