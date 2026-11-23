
-- [dbo].[SP_UserWiseLocation]  4168,1,0
CREATE PROCEDURE [dbo].[SP_UserWiseLocation] 
	@userID INT,
	@comanyid INT,
	@isProduction BIT = 0

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
	,L.DefaultLocation,ISNULL(L.IsFranchise,0) IsFranchise, L.IsQuantityExceed
	FROM UserWise_Location AS UL
	INNER JOIN Locations AS L ON UL.LocationID = L.Id
	WHERE UL.UserID= CASE WHEN @userID = -999 THEN UL.UserID ELSE @userID END 
	AND UL.CompanyId =  CASE WHEN @comanyid = -999 THEN  UL.CompanyId ELSE @comanyid END
	AND L.CompanyID = CASE WHEN @comanyid = -999 THEN  L.CompanyId ELSE @comanyid END
	AND L.IsActive = 1 AND ISNULL(L.IsProductionLocation,0) = case when @isProduction=0 Then ISNULL(L.IsProductionLocation,0)  else @isProduction end 
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

