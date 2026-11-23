-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-02-13
-- Description:	Loading User wise provinces ,Districts 
-- =============================================
CREATE PROCEDURE [dbo].[CUSDEC_Load_DistrictsAndProvinces]
@ProvinceID INT,
@UserID INT,
@DistrictID INT, -- DistrictID,
@PropertyID INT,
@Operation CHAR(2)
AS
BEGIN
	SET NOCOUNT ON;

    IF(@Operation = 'PR')
	BEGIN
		SELECT ID,Code, Name 
		FROM   Provinces
		WHERE IsActive = 1
		AND ID = CASE WHEN @ProvinceID = -999 THEN ID ELSE @ProvinceID END

	END

	IF(@Operation = 'DI')
	BEGIN
		
		SELECT LO.Id, LO.Code, LO.Name
		FROM Locations LO
		INNER JOIN UserWise_Location UL ON LO.ID = UL.LocationID
		WHERE LO.IsActive =1
		AND ISNULL(IsDistrict,0) = 1
		AND ISNULL(ProviceID,-999) = CASE WHEN @ProvinceID = -999 THEN ISNULL(ProviceID,-999) ELSE @ProvinceID END
		AND UL.UserID = @UserID
		AND LO.Id = CASE WHEN @DistrictID = -999 THEN LO.Id ELSE @DistrictID END 

	END

	IF(@Operation = 'DS')
	BEGIN
		SELECT LO.Id, LO.Code, LO.Name
		FROM Locations LO
		INNER JOIN UserWise_Location UL ON LO.ID = UL.LocationID
		WHERE LO.IsActive =1
		AND ISNULL(IsDistrict,0) = 0
		AND ISNULL(ProviceID,0) = CASE WHEN @ProvinceID = -999 THEN ISNULL(ProviceID,0) ELSE @ProvinceID END
		AND ISNULL(DistrictID,0) = CASE WHEN @DistrictID = -999 THEN ISNULL(DistrictID,0) ELSE @DistrictID END
		AND UL.UserID = @UserID
	END
END

GO

