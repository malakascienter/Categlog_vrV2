-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-09-26
-- Description:	Loading Tour Guide Type

-- [dbo].[INV_TourGuideType_Select] -999,1

-- =============================================
create PROCEDURE [dbo].[INV_TourGuideType_Select]
@ID INT,
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT  ID, Name
	FROM     TourGuideType
	WHERE ID = CASE WHEN @ID = -999 THEN ID ELSE @ID END
	AND IsActive = 1

END

GO

