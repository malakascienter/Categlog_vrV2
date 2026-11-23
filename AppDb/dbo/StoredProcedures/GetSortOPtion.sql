-- =============================================
-- Author:		Isuru Pramodya
-- Create date:	2025-05-18
-- Description:	Loading Sort Option for Reports
-- [dbo].[GetSortOPtion] -999
-- =============================================
CREATE PROCEDURE [dbo].[GetSortOPtion]
@ID int
AS
BEGIN
	SET NOCOUNT ON;

   SELECT ID id,Name text 
   FROM ReportSortOption
   WHERE IsActive = 1
   AND ID = CASE WHEN @ID = -999 THEN ID ELSE @ID END
END

GO

