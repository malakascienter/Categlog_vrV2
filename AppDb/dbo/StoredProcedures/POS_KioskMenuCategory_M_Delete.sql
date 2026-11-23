
CREATE PROCEDURE [dbo].[POS_KioskMenuCategory_M_Delete]
(
	@CategoryID INT ,
	@PropertyId INT
)
AS
BEGIN	
	SET NOCOUNT ON;
	IF EXISTS (SELECT 1 FROM POS_KioskMenuCategory WHERE CategoryID = @CategoryID)
	BEGIN

	IF EXISTS (SELECT 1 FROM MainMenu WHERE KioskCatId = @CategoryID)
	BEGIN
		RAISERROR('Kisk category cannot be delete .it is already assigned to menu item.',16,1)
	END
	ELSE
	BEGIN
		DELETE FROM POS_KioskMenuCategory WHERE CategoryID = @CategoryID

		 --TRANSFER FROM HO TO OUTLET SYNC
		 INSERT INTO Sync_MasterDataTransferStatus
		 SELECT @PropertyId,A.CategoryID, B.code, 'KioskCat', 0
		 FROM (SELECT @CategoryID AS CategoryID) A
		 CROSS JOIN Location_Ref B WHERE B.Active = 1
	END
		

	END
	ELSE
	BEGIN
		RAISERROR('No record exists.',16,1)
	END	
END

GO

