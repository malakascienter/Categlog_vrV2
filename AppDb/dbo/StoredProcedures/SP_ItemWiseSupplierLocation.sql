
-- [dbo].[SP_ItemWiseSupplierLocation]  4168,1,1,1,37
CREATE PROCEDURE [dbo].[SP_ItemWiseSupplierLocation] 
	@userID INT,
	@comanyid INT,
	@SupplierID INT,
	@ItemID INT,
	@UnitID INT
AS
BEGIN
------------------------------------------------------------------
BEGIN TRY 
-----------------------
	IF(@userID = 0)
	BEGIN
		RAISERROR('Property ID Invalid, Please Log In Again',16,1)
		ROLLBACK TRANSACTION
	END
-----------------------
	SELECT DISTINCT UL.LocationID AS 'id', L.name AS 'text', L.IsMainStore
	,L.DefaultLocation,case when swid.PurchaseUnitID is null then sid.MasterUnitID else swid.PurchaseUnitID end as UnitId,case when swid.LocationId is not null then 0 else 1 end  isActive
	FROM StockItemHeaders AS SIH 
	INNER JOIN StockItemDetails AS SID ON SID.StockItemHeaderID = SIH.Id AND SIH.Id = @ItemID
	INNER JOIN  UserWise_Location AS UL ON UL.LocationID =SID.LocationID
	INNER JOIN Locations AS L ON UL.LocationID = L.Id AND SID.LocationID = l.Id
	LEFT JOIN SupplierWiseItemDetails SWID ON SWID.StockItemID = @ItemID AND SWID.SupplierID = @SupplierID AND SWID.CompanyId = @comanyid and swid.LocationId = sid.LocationID
	WHERE UL.UserID= CASE WHEN @userID = -999 THEN UL.UserID ELSE @userID END 
	AND UL.CompanyId =  CASE WHEN @comanyid = -999 THEN  UL.CompanyId ELSE @comanyid END
	AND L.IsActive = 1 AND SIH.Id = @ItemID 
	ORDER BY L.Name
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
------------------------------------------------------------------

END

GO

